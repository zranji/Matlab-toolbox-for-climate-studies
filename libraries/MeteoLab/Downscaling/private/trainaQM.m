function MODEL=trainaQM(ptrData,ptnData,indsTrain,indsTest,method,model,XDataCluster)

disp('Training model...');

clustering = [];
clustering.NumberCenters = 1;
Xcluster = ones(size(ptrData,1),1);

[prdType,ncps,nnns] = getPredictorType(method);
[ndata,Nest]=size(ptnData);
window={[1:ndata]};	variable=0;threshold=0;normFun='unknown';freqCorr=0;
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
            elseif ismember(lower(method.properties.Variable),{'2t';'tas';'tmean';'temperature';'temperatura';'mx2t';'tasmax';'tmax';'maximum temperature';'temperatura maxima';'mn2t';'tasmin';'tmin';'minimum temperature';'temperatura minima'})
				variable=2;
            end
		end
	else
		method.properties.Variable='unknown';
	end
	if isfield(method.properties,'normFun')
		if ~isempty(method.properties.normFun)
			normFun=method.properties.normFun;
		else
			method.properties.normFun='unknown';
		end
	else
		method.properties.normFun='unknown';
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

Beta=cell(length(window),1);
if isempty(XDataCluster)
	Beta=cell(length(window),1);
	for i=1:length(window)
		indsTrainW=intersect(window{i},indsTrain);
		fg=[nanstd(ptnData(indsTrainW,:))./nanstd(ptrData(indsTrainW,:));nanmean(ptnData(indsTrainW,:))./nanmean(ptrData(indsTrainW,:));repmat(threshold,1,Nest)];
		switch variable
			case 1,
				auxO=ptnData(indsTrainW,:);auxO(ptnData(indsTrainW,:)<threshold)=NaN;
				auxP=ptrData(indsTrainW,:);
				for j=1:Nest
					nP=nansum(double(ptnData(indsTrainW,j)<threshold & ~isnan(ptnData(indsTrainW,j))));
					if nP<length(indsTrainW)
						fg(end,j)=prctile(ptrData(indsTrainW,j),100*nP/sum(~isnan(ptnData(indsTrainW,j))));
					else
						fg(end,j)=max(ptrData(indsTrainW,j));
					end
					if freqCorr==1,% 2013 Renate et al. Multivariable_error_correction_of_RCMs
						if fg(end,j)<=threshold
							indWet=find(ptrData(indsTrainW,j)>=threshold & ~isnan(ptrData(indsTrainW,j)));
							if ~isempty(indWet)
								[paramEsts]=gamfit(ptrData(indsTrainW(indWet),j));% [Shape parameter  Scale parameter]
							else
								nP1=nansum(double(ptrData(indsTrainW,j)<fg(end,j) & ~isnan(ptrData(indsTrainW,j))));
								aux1=prctile(ptnData(indsTrainW,j),100*nP1/sum(~isnan(ptrData(indsTrainW,j))));
								[paramEsts]=gamfit(ptnData(indsTrainW(intersect(find(ptnData(indsTrainW,j)>=threshold & ptnData(indsTrainW,j)<aux1),find(~isnan(ptnData(indsTrainW,j))))),j));% [Shape parameter  Scale parameter]
							end
							indWet=intersect(find(ptrData(indsTrainW,j)>fg(end,j) & ptrData(indsTrainW,j)<threshold),find(~isnan(ptrData(indsTrainW,j))));
							if ~isempty(indWet)
								ptrData(indsTrainW(indWet),j)=gamrnd(paramEsts(1),paramEsts(2),[length(indWet) 1]);
								if ~isempty(find(isinf(ptrData(indsTrainW,j)))),ptrData(indsTrainW(find(isinf(ptrData(indsTrainW,j)))),j)=threshold;end,
							end
						end
						if nP<length(indsTrainW)
							fg(end,j)=prctile(ptrData(indsTrainW,j),100*nP/sum(~isnan(ptnData(indsTrainW,j))));
						else
							fg(end,j)=max(ptrData(indsTrainW,j));
						end
					end
					auxP(ptrData(indsTrainW,j)<fg(end,j),j)=NaN;
				end
				switch lower(normFun)
					case {'prctile'},
						fg(1,:)=(prctile(auxO,90)-prctile(auxO,10))./(prctile(auxP,90)-prctile(auxP,10));
					otherwise
						fg(1,:)=nanstd(auxO)./nanstd(auxP);
				end
			case 2,
				fg(2,:)=ones(1,Nest);
				if strcmp(normFun,'prctile')
					fg(1,:)=(prctile(ptnData(indsTrainW,:),75)-prctile(ptnData(indsTrainW,:),25))./(prctile(ptrData(indsTrainW,:),75)-prctile(ptrData(indsTrainW,:),25));
				end
			otherwise,
				if strcmp(normFun,'prctile')
					fg(1,:)=(prctile(ptnData(indsTrainW,:),75)-prctile(ptnData(indsTrainW,:),25))./(prctile(ptrData(indsTrainW,:),75)-prctile(ptrData(indsTrainW,:),25));
				end
		end
		Beta{i}=fg;
	end
else
	if isfield(model,'clustering')
		if ~isempty(model.clustering)
			clustering = model.clustering;
			Xcluster = projectClustering(XDataCluster,clustering);
		end
	end
	Beta=cell(length(window),prod(clustering.NumberCenters));
	for i=1:length(window)
		indsTrainW=intersect(window{i},indsTrain);
		for c=1:prod(clustering.NumberCenters)
			if prod(clustering.NumberCenters)>1,disp(sprintf('   ...cluster %d de %d',c,prod(clustering.NumberCenters))),end
			ii = find(Xcluster==c);
			ii = intersect(ii,indsTrainW);
			if ~isempty(ii)
				fg=[nanstd(ptnData(ii,:))./nanstd(ptrData(ii,:));nanmean(ptnData(ii,:))./nanmean(ptrData(ii,:));repmat(threshold,1,Nest)];
				switch variable
					case 1,
						auxO=ptnData(ii,:);auxO(ptnData(ii,:)<threshold)=NaN;
						auxP=ptrData(ii,:);
						for j=1:Nest
							nP=nansum(double(ptnData(ii,j)<threshold & ~isnan(ptnData(ii,j))));
							if nP<length(ii)
								fg(end,j)=prctile(ptrData(ii,j),100*nP/sum(~isnan(ptnData(ii,j))));
							else
								fg(end,j)=max(ptrData(ii,j));
							end
							if freqCorr==1,% 2013 Renate et al. Multivariable_error_correction_of_RCMs
								if fg(end,j)<=threshold
									indWet=find(ptrData(ii,j)>=threshold & ~isnan(ptrData(ii,j)));
									if ~isempty(indWet)
										[paramEsts]=gamfit(ptrData(ii(indWet),j));% [Shape parameter  Scale parameter]
									else
										nP1=nansum(double(ptrData(ii,j)<fg(end,j) & ~isnan(ptrData(ii,j))));
										aux1=prctile(ptnData(ii,j),100*nP1/sum(~isnan(ptrData(ii,j))));
										[paramEsts]=gamfit(ptnData(ii(intersect(find(ptnData(ii,j)>=threshold & ptnData(ii,j)<aux1),find(~isnan(ptnData(ii,j))))),j));% [Shape parameter  Scale parameter]
									end
									indWet=intersect(find(ptrData(ii,j)>fg(end,j) & ptrData(ii,j)<threshold),find(~isnan(ptrData(ii,j))));
									if ~isempty(indWet)
										ptrData(ii(indWet),j)=gamrnd(paramEsts(1),paramEsts(2),[length(indWet) 1]);
										if ~isempty(find(isinf(ptrData(ii,j)))),ptrData(ii(find(isinf(ptrData(ii,j)))),j)=threshold;end,
									end
								end
								if nP<length(ii)
									fg(end,j)=prctile(ptrData(ii,j),100*nP/sum(~isnan(ptnData(ii,j))));
								else
									fg(end,j)=max(ptrData(ii,j));
								end
							end
							auxP(ptrData(ii,j)<fg(end,j))=NaN;
						end
						switch lower(normFun)
							case {'prctile'},
								fg(1,:)=(prctile(auxO,90)-prctile(auxO,10))./(prctile(auxP,90)-prctile(auxP,10));
							otherwise
								fg(1,:)=nanstd(auxO)./nanstd(auxP);
						end
					case 2,
						fg(2,:)=ones(1,Nest);
						if strcmp(normFun,'prctile')
							fg(1,:)=(prctile(ptnData(ii,:),75)-prctile(ptnData(ii,:),25))./(prctile(ptrData(ii,:),75)-prctile(ptrData(ii,:),25));
						end
					otherwise,
						if strcmp(normFun,'prctile')
							fg(1,:)=(prctile(ptnData(ii,:),75)-prctile(ptnData(ii,:),25))./(prctile(ptrData(ii,:),75)-prctile(ptrData(ii,:),25));
						end
				end
				Beta{i,c}=fg;
			end
		end
	end
end
MODEL.coefs = Beta;
MODEL.obs = ptnData(indsTrain,:);
