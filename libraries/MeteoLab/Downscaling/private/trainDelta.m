function MODEL=trainDelta(ptrData,ptnData,indsTrain,indsTest,method,model,XDataCluster)

disp('Training model...');

clustering = [];
clustering.NumberCenters = 1;
Xcluster = ones(size(ptrData,1),1);

[prdType,ncps,nnns] = getPredictorType(method);

window={[1:size(ptrData,1)]};
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
			window=cell(ndays,1);
			indices=[ndays-(floor(w/2)-1):ndays 1:ndays 1:floor(w/2)];
			for doy=1:ndays
				window{doy}=find(ismember(I2,indices(doy:doy+w-1)));
			end
		end
	end
end

Beta=cell(length(window),1);
if isempty(XDataCluster)
	for i=1:length(window)
		indsTrainW=intersect(window{i},indsTrain);
		indsTestW=intersect(window{i},indsTest);
		prdMean=nanmean(ptrData(indsTrainW,:));
		simMean=nanmean(ptrData(indsTestW,:));
		switch lower(method.properties.CorrectionFunction)
			case 'additive',
				Beta{i}=simMean-prdMean;
			case 'multiplicative',
				Beta{i}=simMean./prdMean;
		end
	end
else
	if isfield(model,'clustering')
		if ~isempty(model.clustering)
			clustering = model.clustering;
			Xcluster = projectClustering(XDataCluster,clustering);
		end
	end
	for i=1:length(window)
		indsTrainW=intersect(window{i},indsTrain);
		indsTestW=intersect(window{i},indsTest);
		aux=repmat(NaN,prod(clustering.NumberCenters),size(ptrData,2));
		for c=1:prod(clustering.NumberCenters)
			if prod(clustering.NumberCenters)>1,disp(sprintf('   ...cluster %d de %d',c,prod(clustering.NumberCenters))),end
			ii = find(Xcluster==c);
			jj = intersect(ii,indsTestW);
			ii = intersect(ii,indsTrainW);
			if ~isempty(ii)
				prdMean=nanmean(ptrData(ii,:));
				simMean=nanmean(ptrData(jj,:));
				switch lower(method.properties.CorrectionFunction)
					case 'additive',
						aux(c,:)=simMean-prdMean;
					case 'multiplicative',
						aux(c,:)=simMean./prdMean;
				end
			end
		end
		Beta{i}=aux;
	end
end
MODEL.coefs = Beta;
MODEL.obs = ptnData(indsTrain,:);
