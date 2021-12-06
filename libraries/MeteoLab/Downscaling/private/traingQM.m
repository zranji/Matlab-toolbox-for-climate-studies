function MODEL=traingQM(ptrData,ptnData,indsTrain,indsTest,method,model,XDataCluster)

disp('Training model...');

clustering = [];
clustering.NumberCenters = 1;
Xcluster = ones(size(ptrData,1),1);
if isfield(model,'clustering')
    if ~isempty(model.clustering)
        clustering = model.clustering;
        Xcluster = projectClustering(XDataCluster,clustering);
    end
end

[prdType,ncps,nnns] = getPredictorType(method);
[ndata,Nest]=size(ptnData);
window={[1:ndata]};variable=1;threshold=0;freqCorr=0;
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
	if isfield(method.properties,'Variable')
		if ~isempty(method.properties.Variable)
            if ismember(lower(method.properties.Variable),{'tp';'pr';'precip';'precipitation';'precipitacion'})
				variable=1;
            else
				error('Piani method is only appropriate for precipitation.')
            end
		else
			method.properties.Variable='unknown';
			warning('Piani method is appropriate only for precipitation. The variable property has not been included in the method definition.')
			
		end
	else
		method.properties.Variable='unknown';
		warning('Piani method is appropriate only for precipitation. The variable property has not been included in the method definition.')		
	end
	if isfield(method.properties,'FreqCorrection')
		if ~isempty(method.properties.FreqCorrection)
             if ismember(lower(method.properties.FreqCorrection),{'true';'yes';'1'}) & variable==1
				 freqCorr=1;
             else
				 freqCorr=0;
             end
		 else
			 method.properties.FreqCorrection=freqCorr;
		end
	end
	if isfield(method.properties,'threshold')
		if ~isempty(method.properties.threshold)
            if isnumeric(method.properties.threshold)
				threshold=method.properties.threshold;
            else
				threshold=str2num(method.properties.threshold);
            end
		elseif variable==1
			method.properties.threshold=0;
		end
	elseif variable==1
		method.properties.threshold=0;
	end
end

if clustering.NumberCenters==1
	Beta=cell(length(window),1);
	for i=1:length(window)
		indsTrainW=intersect(window{i},indsTrain);
		aux=repmat(NaN,5,Nest);% [wet day threshold for the model; Shape and scale parameters for observations and model]
		aux(1,:)=threshold;
		for j=1:Nest
			nP=nansum(double(ptnData(indsTrainW,j)<threshold & ~isnan(ptnData(indsTrainW,j))));
			if nP<length(indsTrainW)
				aux(1,j)=prctile(ptrData(indsTrainW,j),100*nP/sum(~isnan(ptnData(indsTrainW,j))));
				wetObs=find(ptnData(indsTrainW,j)>=threshold & ~isnan(ptnData(indsTrainW,j)));
				wetPrd=find(ptrData(indsTrainW,j)>=aux(1,j) & ~isnan(ptrData(indsTrainW,j)));
				[paramEstsOBS]=gamfit(ptnData(indsTrainW(wetObs),j));
				[paramEstsRCM]=gamfit(ptrData(indsTrainW(wetPrd),j));
				aux(2:end,j)=[paramEstsOBS(:);paramEstsRCM(:)];
			else
				aux(1,j)=max(ptrData(indsTrainW,j));
			end
			if freqCorr==1,% 2013 Renate et al. Multivariable_error_correction_of_RCMs
				if aux(1,j)<=threshold
					indWet=find(ptrData(indsTrainW,j)>=threshold & ~isnan(ptrData(indsTrainW,j)));
					if ~isempty(indWet)
						[paramEsts]=gamfit(ptrData(indsTrainW(indWet),j));% [Shape parameter  Scale parameter]
					else
						nP1=nansum(double(ptrData(indsTrainW,j)<aux(1,j) & ~isnan(ptrData(indsTrainW,j))));
						aux1=prctile(ptnData(indsTrainW,j),100*nP1/sum(~isnan(ptrData(indsTrainW,j))));
						[paramEsts]=gamfit(ptnData(indsTrainW(intersect(find(ptnData(indsTrainW,j)>=threshold & ptnData(indsTrainW,j)<aux1),find(~isnan(ptnData(indsTrainW,j))))),j));% [Shape parameter  Scale parameter]
					end
					indWet=intersect(find(ptrData(indsTrainW,j)>aux(1,j) & ptrData(indsTrainW,j)<threshold),find(~isnan(ptrData(indsTrainW,j))));
					if ~isempty(indWet)
						ptrData(indsTrainW(indWet),j)=gamrnd(paramEsts(1),paramEsts(2),[length(indWet) 1]);
						if ~isempty(find(isinf(ptrData(indsTrainW,j)))),ptrData(indsTrainW(find(isinf(ptrData(indsTrainW,j)))),j)=threshold;end,
					end
				end
				if nP<length(indsTrainW)
					aux(1,j)=prctile(ptrData(indsTrainW,j),100*nP/sum(~isnan(ptnData(indsTrainW,j))));
				else
					aux(1,j)=max(ptrData(indsTrainW,j));
				end
			end
		end
		Beta{i}=aux;
	end
else
	Beta=cell(length(window),prod(clustering.NumberCenters));
	for i=1:length(window)
		indsTrainW=intersect(window{i},indsTrain);
		for c=1:prod(clustering.NumberCenters)
			if prod(clustering.NumberCenters)>1,disp(sprintf('   ...cluster %d de %d',c,prod(clustering.NumberCenters))),end
			ii = find(Xcluster==c);
			ii = intersect(ii,indsTrainW);
			if ~isempty(ii)
				aux=repmat(NaN,5,Nest);% [wet day threshold for the model; Shape and scale parameters for observations and model]
				aux(1,:)=threshold;
				for j=1:Nest
					nP=nansum(double(ptnData(ii,j)<threshold & ~isnan(ptnData(ii,j))));
					if nP<length(ii)
						aux(1,j)=prctile(ptrData(ii,j),100*nP/sum(~isnan(ptnData(ii,j))));
						wetObs=find(ptnData(ii,j)>=threshold & ~isnan(ptnData(ii,j)));
						wetPrd=find(ptrData(ii,j)>=aux(1,j) & ~isnan(ptrData(ii,j)));
						[paramEstsOBS]=gamfit(ptnData(ii(wetObs),j));
						[paramEstsRCM]=gamfit(ptrData(ii(wetPrd),j));
						aux(2:end,j)=[paramEstsOBS(:);paramEstsRCM(:)];
					else
						aux(1,j)=max(ptrData(ii,j));
					end
					if freqCorr==1,% 2013 Renate et al. Multivariable_error_correction_of_RCMs
						if aux(1,j)<=threshold
							indWet=find(ptrData(ii,j)>=threshold & ~isnan(ptrData(ii,j)));
							if ~isempty(indWet)
								[paramEsts]=gamfit(ptrData(ii(indWet),j));% [Shape parameter  Scale parameter]
							else
								nP1=nansum(double(ptrData(ii,j)<aux(1,j) & ~isnan(ptrData(ii,j))));
								aux1=prctile(ptnData(ii,j),100*nP1/sum(~isnan(ptrData(ii,j))));
								[paramEsts]=gamfit(ptnData(ii(intersect(find(ptnData(ii,j)>=threshold & ptnData(ii,j)<aux1),find(~isnan(ptnData(ii,j))))),j));% [Shape parameter  Scale parameter]
							end
							indWet=intersect(find(ptrData(ii,j)>aux(1,j) & ptrData(ii,j)<threshold),find(~isnan(ptrData(ii,j))));
							if ~isempty(indWet)
								ptrData(ii(indWet),j)=gamrnd(paramEsts(1),paramEsts(2),[length(indWet) 1]);
								if ~isempty(find(isinf(ptrData(ii,j)))),ptrData(ii(find(isinf(ptrData(ii,j)))),j)=threshold;end,
							end
						end
						if nP<length(ii)
							aux(1,j)=prctile(ptrData(ii,j),100*nP/sum(~isnan(ptnData(ii,j))));
							wetObs=find(ptnData(ii,j)>=threshold & ~isnan(ptnData(ii,j)));
							wetPrd=find(ptrData(ii,j)>=aux(1,j) & ~isnan(ptrData(ii,j)));
							[paramEstsOBS]=gamfit(ptnData(ii(wetObs),j));
							[paramEstsRCM]=gamfit(ptrData(ii(wetPrd),j));
							aux(2:end,j)=[paramEstsOBS(:);paramEstsRCM(:)];
						else
							aux(1,j)=max(ptrData(ii,j));
						end
					end
				end
				Beta{i,c}=aux;
			end
		end
	end
end
MODEL = Beta;
