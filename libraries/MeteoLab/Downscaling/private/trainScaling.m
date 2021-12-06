function MODEL=trainScaling(ptrData,ptnData,indsTrain,indsTest,method,model,XDataCluster)

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
		ptrMean=nanmean(ptrData(indsTrainW,:));
		ptnMean=nanmean(ptnData(indsTrainW,:));
		switch lower(method.properties.CorrectionFunction)
			case 'additive',
				Beta{i}=(ptnMean-ptrMean);
			case 'multiplicative',
				Beta{i}=ptnMean./ptrMean;
			case 'logarithmic',
				aux=repmat(NaN,1,Nest);
				for j=1:Nest,
					OO=ptnData(indsTrainW,j);OO(ptnData(indsTrainW,j)<eps)=0;
					PP=ptrData(indsTrainW,j);PP(ptrData(indsTrainW,j)<eps)=0;
					aux(j)=(nanmean(log(OO))/nanmean(log(PP)));
				end
				Beta{i}=aux;
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
		aux=repmat(NaN,prod(clustering.NumberCenters),size(ptrData,2));
		for c=1:prod(clustering.NumberCenters)
			if prod(clustering.NumberCenters)>1,disp(sprintf('   ...cluster %d de %d',c,prod(clustering.NumberCenters))),end
			ii = find(Xcluster==c);
			ii = intersect(ii,indsTrainW);
			if ~isempty(ii)
				ptrMean=nanmean(ptrData(ii,:));
				ptnMean=nanmean(ptnData(ii,:));
				switch lower(method.properties.CorrectionFunction)
					case 'additive',
						aux(c,:)=(ptnMean-ptrMean);
					case 'multiplicative',
						aux(c,:)=ptnMean./ptrMean;
					case 'logarithmic',
						for j=1:Nest,
							OO=ptnData(ii,j);OO(ptnData(ii,j)<eps)=0;
							PP=ptrData(ii,j);PP(ptrData(ii,j)<eps)=0;
							aux(c,j)=(nanmean(log(OO))/nanmean(log(PP)));
						end
				end
			end
		end
		Beta{i}=aux;
	end
end
MODEL = Beta;
