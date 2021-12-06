function [Ypred] = downSim(ptr,model,varargin)

methodType = model.method.type;
if strcmp(methodType,'ANALOGES')
   testFunction = @analogsTest;
elseif strcmp(methodType,'LINEAR_REGRESSION')
   testFunction = @linearTest;
elseif strcmp(methodType,'ELM')
   testFunction = @elmTest;
elseif strcmp(methodType,'GLM')
   testFunction = @glmTest;
elseif strcmp(methodType,'WT')
   testFunction = @wtTest;
elseif strcmp(methodType,'NN')
   testFunction = @nnTest;
elseif strcmp(methodType,'QUANTILE_REGRESSION')
   testFunction = @quantileTest;
elseif strcmp(methodType,'SCALING')
   testFunction = @testScaling;
elseif strcmp(methodType,'DELTA')
   testFunction = @testDelta;
elseif strcmp(methodType,'GPQM')
   testFunction = @testgpQM;
elseif strcmp(methodType,'AQM')
   testFunction = @testaQM;
elseif strcmp(methodType,'GQM')
   testFunction = @testgQM;
elseif strcmp(methodType,'EQM')
   testFunction = @testeQM;
else
    error('Invalid downscaling method');
end

datesTest = [];
verbose = 0;

i = 1;
while i<=length(varargin), 
  argok = 1;
  switch varargin{i},
     case 'datesTest',  i=i+1; datesTest = varargin{i}; 
     case 'verbose',    i=i+1; verbose = varargin{i};
     otherwise argok=0;
  end
  if ~argok, 
    disp(['Ignoring invalid argument #' num2str(i+1)]); 
  end
  i = i+1; 
end

[methodType,ncps,nnns] = getPredictorType(model.method);
if ismember(upper(model.method.type),{'SCALING';'GPQM';'GQM';'EQM';'AQM';'DELTA'}) & (nnns==0)
	model.method.properties.NumberOfNearestNeighbours = 1;
	[methodType,ncps,nnns] = getPredictorType(model.method);
end

if isfield(ptr.meta,'dates')
   ptrDates = ptr.meta.dates;
elseif isfield(ptr.meta,'dailyList') & isfield(ptr.meta,'step')
	if ismember(ptr.meta.step,'Y','rows')
		formato='yyyy';
	elseif ismember(ptr.meta.step,'M','rows')
		formato='yyyymm';
	elseif ismember(ptr.meta.step,{'D';'24:00';'1D';'24h'})
		formato='yyyymmdd';
	else
		formato='yyyymmddhh';
	end
	ptrDates = datenum(ptr.meta.dailyList,formato);
elseif isfield(ptr.meta,'dailyList') & isfield(ptr.meta,'StepDate')
	if ismember(ptr.meta.StepDate,'Y','rows')
		formato='yyyy';
	elseif ismember(ptr.meta.StepDate,'M','rows')
		formato='yyyymm';
	elseif ismember(ptr.meta.StepDate,{'D';'24:00';'1D';'24h'})
		formato='yyyymmdd';
	else
		formato='yyyymmddhh';
	end
	ptrDates = datenum(ptr.meta.dailyList,formato);
else
    startDate=1;endDate=max(1,length(datesTest));step=1;
    if isfield(ptr.meta,'StartDate')
        startDate=datenum(ptr.meta.StartDate);
    elseif isfield(ptr.meta,'startDate')
        startDate=datenum(ptr.meta.startDate);
    end
    if isfield(ptr.meta,'EndDate')
        endDate=datenum(ptr.meta.EndDate);
    elseif isfield(ptr.meta,'endDate')
        endDate=datenum(ptr.meta.endDate);
    end
    if isfield(ptr.meta,'step')
        step=datenum(stepvec(ptr.meta.step));
    elseif isfield(ptr.meta,'StepDate')
        step=datenum(stepvec(ptr.meta.StepDate));
    end
   ptrDates = startDate:step:endDate;
end

if strcmp(methodType,'PC')
	if(ncps==0 & isfield(model.method.properties,'ClusteringMethod'))
		ncps=size(model.clustering.Centers,2);
	end
	ptrData = ptr.pc(:,1:min(ncps,size(ptr.pc,2)));
elseif strcmp(methodType,'FIELDS')
   ptrData = ptr.fields;
else
   ptrData = [ptr.pc(:,1:min(ncps,size(ptr.pc,2))) ptr.fields];
end
ptrClusterData = [];
if isfield(ptr,'clusteringData')
   ptrClusterData = ptr.clusteringData;
end
clear ptr;

if isempty(datesTest)
   datesTest = ptrDates;
end

[dum1,indsTest,dum2] = intersect(ptrDates,datesTest);
clear dum1;
clear dum2;

% if ismember(upper(model.method.type),{'SCALING';'GPQM';'GQM';'EQM';'AQM';'DELTA'})
% 	Nest=length(model.obsMeta.Info.Id);
% 	if isfield(model.dmn,'nod')
% 		mod2obs = MLknn(model.obsMeta.Info.Location(:,1:2),model.dmn.nod(1:2,:)',nnns,'Norm-2');
% 	elseif isfield(model.dmn,'Info')
% 		mod2obs = MLknn(model.obsMeta.Info.Location(:,1:2),model.dmn.Info.Location,nnns,'Norm-2');
% 	else
% 		disp('Error: Invalid predictor metadata')
% 	end
% 	if nnns==1
% 		ptrData=ptrData(:,mod2obs);
% 	else
% 		ptrData1=repmat(NaN,size(ptrData,1),Nest);
% 		for k=1:Nest
% 			ptrData1(:,k)=nanmean(ptrData(:,mod2obs(k,:)),2);
% 		end
% 		ptrData=ptrData1;clear ptrData1
% 	end
% end

if strcmp(upper(model.method.type),'AQM') | strcmp(upper(model.method.type),'DELTA')
    model.dateTest=datesym(datesTest(:),'yyyymmdd');
%     Ypred = testFunction(ptrData,repmat(NaN,size(ptrData,1),length(model.obsMeta.Info.Id)),[1:size(model.MODEL.obs,1)],indsTest,model.method,model,ptrClusterData);
    Ypred = testFunction(ptrData,repmat(NaN,size(ptrData,1),1),[1:size(model.MODEL.obs,1)],indsTest,model.method,model,ptrClusterData);

elseif ismember(upper(model.method.type),{'SCALING';'GPQM';'GQM';'EQM'})
    model.dateTest=datesym(datesTest(:),'yyyymmdd');
%     Ypred = testFunction(ptrData,repmat(NaN,size(ptrData,1),length(model.obsMeta.Info.Id)),[1:size(ptrData,1)],indsTest,model.method,model,ptrClusterData);
    Ypred = testFunction(ptrData,repmat(NaN,size(ptrData,1),1),[1:size(ptrData,1)],indsTest,model.method,model,ptrClusterData);
else
%     Ypred = testFunction(ptrData,repmat(NaN,size(ptrData,1),length(model.obsMeta.Info.Id)),[1:size(ptrData,1)],indsTest,model.method,model,ptrClusterData);
Ypred = testFunction(ptrData,repmat(NaN,size(ptrData,1),1),[1:size(ptrData,1)],indsTest,model.method,model,ptrClusterData);
end
