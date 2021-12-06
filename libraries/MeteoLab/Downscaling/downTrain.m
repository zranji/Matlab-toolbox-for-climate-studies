function [model,Ypred,commonDates] = downTrain(ptr,ptn,method,varargin)

methodType = method.type;
if strcmp(methodType,'ANALOGES')
   %AnalogueNumber
   %InferenceMethod: wm,mean,median,rand,prc75,prc90
   trainFunction = @analogsTrain;
   testFunction = @analogsTest;
elseif strcmp(methodType,'LINEAR_REGRESSION')
   %NumberOfClusters
   %ClusteringMethod: none,k-means,som
   %NumberOfPCs
   %NumberOfNearestNeighbours
   trainFunction = @linearTrain;
   testFunction = @linearTest;
elseif strcmp(methodType,'ELM')
   %NumberOfPCs
   %NumberOfNearestNeighbours
   %NumberofHiddenNeurons
   %ActivationFunction sig,sin,hardlim
   %ClusteringMethod: none,k-means,som
   %NumberOfClusters
   trainFunction = @elmTrain;
   testFunction = @elmTest;
elseif strcmp(methodType,'GLM')
   %NumberOfPCs
   %NumberOfNearestNeighbours
   %Threshold
   %ClusteringMethod: none,k-means,som
   %NumberOfClusters
   trainFunction = @glmTrain;
   testFunction = @glmTest;
elseif strcmp(methodType,'WT')
   %ClusteringMethod: none,k-means,som
   %NumberOfClusters
   %InferenceMethod: wm,mean,median,rand,prc75,prc90
   trainFunction = @wtTrain;
   testFunction = @wtTest;
elseif strcmp(methodType,'NN')
   %NumberOfPCs
   %NumberOfHiddenLayers
   %TypeOfHiddenLayers tansig, purelin, logsig
   %ClusteringMethod: none,k-means,som
   %NumberOfClusters
   trainFunction = @nnTrain;
   testFunction = @nnTest;
elseif strcmp(methodType,'QUANTILE_REGRESSION')
   %NumberOfClusters
   %NumberOfPCs
   %NumberOfNearestNeighbours
   %Variable
   %ThresholdPrecip
   %Quantile
   trainFunction = @quantileTrain;
   testFunction = @quantileTest;
elseif strcmp(methodType,'SCALING')
   trainFunction = @trainScaling;
   testFunction = @testScaling;
elseif strcmp(methodType,'DELTA')
   trainFunction = @trainDelta;
   testFunction = @testDelta;
elseif strcmp(methodType,'GPQM')
   trainFunction = @traingpQM;
   testFunction = @testgpQM;
elseif strcmp(methodType,'AQM')
   trainFunction = @trainaQM;
   testFunction = @testaQM;
elseif strcmp(methodType,'GQM')
   trainFunction = @traingQM;
   testFunction = @testgQM;
elseif strcmp(methodType,'EQM')
   trainFunction = @traineQM;
   testFunction = @testeQM;
else
    error('Invalid downscaling method');
end

datesTrain = [];
datesTest = [];
verbose = 0;

i = 1;
while i<=length(varargin), 
  argok = 1;
  switch varargin{i},
     case 'datesTrain', i=i+1; datesTrain = varargin{i}; 
     case 'datesTest',  i=i+1; datesTest = varargin{i}; 
     case 'verbose',    i=i+1; verbose = varargin{i};
     otherwise argok=0;
  end
  if ~argok, 
    disp(['Ignoring invalid argument #' num2str(i+1)]); 
  end
  i = i+1; 
end

[methodType,ncps,nnns] = getPredictorType(method);
if ismember(upper(method.type),{'SCALING';'GPQM';'GQM';'EQM';'AQM';'DELTA'}) & (nnns==0)
	method.properties.NumberOfNearestNeighbours = 1;
	[methodType,ncps,nnns] = getPredictorType(method);
end

model = [];
model.dmn = ptr.meta;
if ~isfield(ptn.meta,'dailyList') & isfield(ptn.meta,'Dates') & ischar(ptn.meta.Dates)
	ptn.meta.dailyList = ptn.meta.Dates;
end
if ~isfield(ptn.meta,'dailyList') & isfield(ptn.meta,'dateList') & ischar(ptn.meta.dateList)
	ptn.meta.dailyList = ptn.meta.dateList;
end
model.obsMeta = ptn.meta;
clustering = [];
if ~isfield(method,'properties')
    method.properties = [];
end
if isfield(method.properties,'ClusteringMethod')
    clustering = method.properties.ClusteringMethod;
end
model.clustering = clustering;

if isfield(ptr.meta,'dates') & isnumeric(ptr.meta.dates)
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
    startDate=1;endDate=max(1,length(datesTrain)+length(datesTest));step=1;
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
if isfield(ptn.meta,'dates') & isnumeric(ptn.meta.dates)
	ptnDates = ptn.meta.dates;
elseif isfield(ptn.meta,'dailyList') & isfield(ptn.meta,'step')
	if ismember(ptn.meta.step,'Y','rows')
		formato='yyyy';
	elseif ismember(ptn.meta.step,'M','rows')
		formato='yyyymm';
	elseif ismember(ptn.meta.step,{'D';'24:00';'1D';'24h'})
		formato='yyyymmdd';
	else
		formato='yyyymmddhh';
	end
	ptnDates = datenum(ptn.meta.dailyList,formato);
elseif isfield(ptn.meta,'dailyList') & isfield(ptn.meta,'StepDate')
	if ismember(ptn.meta.StepDate,'Y','rows')
		formato='yyyy';
	elseif ismember(ptn.meta.StepDate,'M','rows')
		formato='yyyymm';
	elseif ismember(ptn.meta.StepDate,{'D';'24:00';'1D';'24h'})
		formato='yyyymmdd';
	else
		formato='yyyymmddhh';
	end
	ptnDates = datenum(ptn.meta.dailyList,formato);
else
    startDate=1;endDate=max(1,length(datesTrain)+length(datesTest));step=1;
    if isfield(ptn.meta,'StartDate')
        startDate=datenum(ptn.meta.StartDate);
    elseif isfield(ptn.meta,'startDate')
        startDate=datenum(ptn.meta.startDate);
    end
    if isfield(ptn.meta,'EndDate')
        endDate=datenum(ptn.meta.EndDate);
    elseif isfield(ptn.meta,'endDate')
        endDate=datenum(ptn.meta.endDate);
    end
    if isfield(ptn.meta,'step')
        step=datenum(stepvec(ptn.meta.step));
    elseif isfield(ptn.meta,'StepDate')
        step=datenum(stepvec(ptn.meta.StepDate));
    end
   ptnDates = startDate:step:endDate;
end

[commonDates,ptrIndex,ptnIndex] = intersect(ptrDates,ptnDates);
if strcmp(methodType,'PC')
	if(ncps==0 & isfield(method.properties,'ClusteringMethod'))
		ncps=size(clustering.Centers,2);
	end
   ptrData = ptr.pc(ptrIndex,1:min(ncps,size(ptr.pc,2)));
elseif strcmp(methodType,'FIELDS')
   ptrData = ptr.fields(ptrIndex,:);
else
   ptrData = [ptr.pc(ptrIndex,1:min(ncps,size(ptr.pc,2))) ptr.fields(ptrIndex,:)];
end

ptrClusterData = [];
if isfield(ptr,'clusteringData')
   ptrClusterData = ptr.clusteringData(ptrIndex,:);
end
clear ptr;
ptnData = ptn.data(ptnIndex,:);
clear ptn;

if isempty(datesTrain)
   datesTrain = commonDates;
end
if isempty(datesTest)
   datesTest = commonDates;
end

[dum1,indsTrain,dum2] = intersect(commonDates,datesTrain);
[dum1,indsTest,dum2] = intersect(commonDates,datesTest);
clear dum1;
clear dum2;

if isstruct(method.properties)
    properties = fields(method.properties);
    for p=1:length(properties)
        myvalue = getfield(method.properties,properties{p});
        if isnumeric(myvalue)
            method.properties = setfield(method.properties,properties{p},num2str(myvalue));
        end
    end
end

% if ismember(upper(method.type),{'SCALING';'GPQM';'GQM';'EQM';'AQM';'DELTA'}) 
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

[mymodel] = trainFunction(ptrData,ptnData,indsTrain,indsTest,method,model,ptrClusterData);
model.MODEL = mymodel;
model.method = method;
Ypred = [];

if nargout>=2
   Ypred = testFunction(ptrData,ptnData,indsTrain,indsTest,method,model,ptrClusterData);
end
commonDates = commonDates(indsTest);
