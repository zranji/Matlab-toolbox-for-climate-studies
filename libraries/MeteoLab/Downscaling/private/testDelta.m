function Ypred=testDelta(ptrData,ptnData,indsTrain,indsTest,method,model,XDataCluster)

disp('Applying model...');

clustering = [];
clustering.NumberCenters = 1;
Xcluster = ones(size(ptrData,1),1);
[prdType,ncps,nnns] = getPredictorType(method);
[ndata,Nest]=size(ptnData);
[days,I1,I2]=unique(model.obsMeta.dailyList(:,5:8),'rows');
window={[1:size(ptrData,1)]',[1:length(indsTest)]'};
dateTest=datesym([1:size(ptrData,1)]','yyyymmdd');
if isfield(model,'dateTest')
    dateTest=model.dateTest;dateList=dateTest;
else
    if isfield(model.dmn,'dailyList')
        dateTest=model.dmn.dailyList;
    elseif isfield(model.dmn,'dateList')
        dateTest=model.dmn.dateList;
    end
    dateList=dateTest;dateTest=dateTest(indsTest,:);
end
if isstruct(method.properties)
	if isfield(method.properties,'CorrectionWindow')
		if ~isempty(method.properties.CorrectionWindow)
			if isnumeric(method.properties.CorrectionWindow)
				w=method.properties.CorrectionWindow;
			else
				w=str2num(method.properties.CorrectionWindow);
			end
			[days,I1,I2]=unique(model.obsMeta.dailyList(:,5:8),'rows');
			ndays=size(days,1);
			window=cell(ndays,2);
			indices=[ndays-(floor(w/2)-1):ndays 1:ndays 1:floor(w/2)];
			for doy=1:ndays
				window{doy,1}=find(ismember(I2,indices(doy:doy+w-1)));
				window{doy,2}=strmatch(days(doy,:),dateTest(:,5:8));
			end
		end
	end
end

Ypred=ptrData(indsTest,:);
if isempty(XDataCluster)
	for i=1:size(window,1)
		[indsTestW,I1,I2]=intersect(window{i,1},indsTest);
		[indsTrainW,J1,J2]=intersect(window{i,1},indsTrain);
		for j=1:Nest
			delta=ptrData(indsTestW,j);N=100;
			[Faux,FI,FJ]=unique(delta(~isnan(delta)));
			if length(Faux)>1
				N=hist(delta(~isnan(delta)),Faux);N=100*cumsum(N)/sum(N);
			end
			auxQ=N(FJ);
			switch lower(method.properties.CorrectionFunction)
				case 'additive',
					auxSim=prctile(model.MODEL.obs(J2,j),auxQ)'+model.MODEL.coefs{i}(j);
				case 'multiplicative',
					auxSim=prctile(model.MODEL.obs(J2,j),auxQ)'*model.MODEL.coefs{i}(j);
			end
			Ypred(window{i,2},j)=auxSim(find(ismember(dateList(indsTestW,5:8),unique(dateList(indsTest(window{i,2}),5:8),'rows'),'rows')));			
		end
	end
else
	if isfield(model,'clustering')
		if ~isempty(model.clustering)
			clustering = model.clustering;
			Xcluster = projectClustering(XDataCluster,clustering);
		end
	end
	for i=1:size(window,1)
		indsTestW=intersect(window{i,1},indsTest);
		indsTrainW=intersect(window{i,1},indsTrain);
		for c=1:prod(clustering.NumberCenters)
			if prod(clustering.NumberCenters)>1,disp(sprintf('   ...cluster %d de %d',c,prod(clustering.NumberCenters))),end
			ii = find(Xcluster==c);
			[jj,J1,J2] = intersect(ii,indsTrainW);
			[ii,I1,I2] = intersect(ii,indsTestW);
			if ~isempty(ii)
				for j=1:Nest
					delta=ptrData(ii,j);N=100;
					[Faux,FI,FJ]=unique(delta(~isnan(delta)));
					if length(Faux)>1
						N=hist(delta(~isnan(delta)),Faux);N=100*cumsum(N)/sum(N);
					end
					auxQ=N(FJ);
					switch lower(method.properties.CorrectionFunction)
						case 'additive',
							auxSim=prctile(model.MODEL.obs(J2,j),auxQ)'+model.MODEL.coefs{i,c}(j);
						case 'multiplicative',
							auxSim=prctile(model.MODEL.obs(J2,j),auxQ)'*model.MODEL.coefs{i,c}(j);
					end
					Ypred(window{i,2},j)=auxSim(find(ismember(dateList(ii,5:8),unique(dateList(indsTest(window{i,2}),5:8),'rows'),'rows')));
				end
			end
		end
	end
end
