function MODEL=traingpQM(ptrData,ptnData,indsTrain,indsTest,method,model,XDataCluster)

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
window={[1:ndata]};variable=0;threshold=0;theta=[];freqCorr=0;
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
	if isfield(method.properties,'theta')
		if ~isempty(method.properties.theta)
            if isnumeric(method.properties.theta)
				theta=method.properties.theta;
            else
				theta=str2num(method.properties.theta);
            end
		end
	end
end

if isempty(theta)
	if variable==1
		theta=repmat(NaN,2,Nest);
		for i=1:Nest
			ind=find(ptnData(indsTrain,i)>=threshold & ~isnan(ptnData(indsTrain,i)));
			if ~isempty(ind)
				theta(1,i)=prctile(ptnData(indsTrain(ind),i),95);
			end
			ind=find(ptrData(indsTrain,i)>=threshold & ~isnan(ptrData(indsTrain,i)));
			if ~isempty(ind)
				theta(2,i)=prctile(ptrData(indsTrain(ind),i),95);
			end
		end
	else
		theta=repmat(NaN,4,Nest);
        for i=1:Nest
            theta(1,i)=prctile(ptnData(indsTrain,i),95);
            theta(2,i)=prctile(ptrData(indsTrain,i),95);
            theta(3,i)=prctile(ptnData(indsTrain,i),5);
            theta(4,i)=prctile(ptrData(indsTrain,i),5);
        end
	end
	method.properties.theta=theta;
end

if clustering.NumberCenters==1
	Beta=cell(length(window),1);
	for i=1:length(window)
		indsTrainW=intersect(window{i},indsTrain);
		if variable==1
			aux=repmat(NaN,11,Nest);% [wet day threshold for the model; mean regime parameters for observations and model; extreme regime parameters]
			aux(1,:)=threshold;
			for j=1:Nest
				nP=nansum(double(ptnData(indsTrainW,j)<threshold & ~isnan(ptnData(indsTrainW,j))));
				if nP<length(indsTrainW)
					aux(1,j)=prctile(ptrData(indsTrainW,j),100*nP/sum(~isnan(ptnData(indsTrainW,j))));
					% Mean precipitation regime:
					wetObs=intersect(find(ptnData(indsTrainW,j)>=threshold & ptnData(indsTrainW,j)<theta(1,j)),find(~isnan(ptnData(indsTrainW,j))));
					wetPrd=intersect(find(ptrData(indsTrainW,j)>=aux(1,j) & ptrData(indsTrainW,j)<theta(2,j)),find(~isnan(ptrData(indsTrainW,j))));
					[paramEstsOBS]=gamfit(ptnData(indsTrainW(wetObs),j));
					[paramEstsRCM]=gamfit(ptrData(indsTrainW(wetPrd),j));
					aux(2:5,j)=[paramEstsOBS(:);paramEstsRCM(:)];
					% Extreme precipitation regime:
					wetObs=find(ptnData(indsTrainW,j)>=theta(1,j) & ~isnan(ptnData(indsTrainW,j)));
					wetPrd=find(ptrData(indsTrainW,j)>=theta(2,j) & ~isnan(ptrData(indsTrainW,j)));
					try
						pdObs=fitdist(ptnData(indsTrainW(wetObs),j),'gp','theta',theta(1,j)-100*eps);
						pdPrd=fitdist(ptrData(indsTrainW(wetPrd),j),'gp','theta',theta(2,j)-100*eps);
						aux(6:end,j)=[pdObs.k;pdObs.sigma;pdObs.theta;pdPrd.k;pdPrd.sigma;pdPrd.theta];
					catch
						warning('Not enough data to fit the Generalized Pareto distribution.')
					end
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
		else
			aux=repmat(NaN,16,Nest);% [mean regime parameters for observations and model; upper/lower extreme regime parameters]
			for j=1:Nest
				% Mean regime:
				wetObs=intersect(find(ptnData(indsTrainW,j)>theta(3,j) & ptnData(indsTrainW,j)<theta(1,j)),find(~isnan(ptnData(indsTrainW,j))));
				wetPrd=intersect(find(ptrData(indsTrainW,j)>theta(4,j) & ptrData(indsTrainW,j)<theta(2,j)),find(~isnan(ptrData(indsTrainW,j))));
                [paramEstsOBS(1),paramEstsOBS(2)]=normfit(ptnData(indsTrainW(wetObs),j));% [Mu parameter  Sigma parameter]
                [paramEstsRCM(1),paramEstsRCM(2)]=normfit(ptrData(indsTrainW(wetPrd),j));% [Mu parameter  Sigma parameter]
				aux(1:4,j)=[paramEstsOBS(:);paramEstsRCM(:)];
				% Extreme regime (up):
				wetObs=find(ptnData(indsTrainW,j)>=theta(1,j) & ~isnan(ptnData(indsTrainW,j)));
				wetPrd=find(ptrData(indsTrainW,j)>=theta(2,j) & ~isnan(ptrData(indsTrainW,j)));
				try
					pdObs=fitdist(ptnData(indsTrainW(wetObs),j),'gp','theta',theta(1,j)-100*eps);
					pdPrd=fitdist(ptrData(indsTrainW(wetPrd),j),'gp','theta',theta(2,j)-100*eps);
					aux(5:10,j)=[pdObs.k;pdObs.sigma;pdObs.theta;pdPrd.k;pdPrd.sigma;pdPrd.theta];
				catch
					warning('Not enough data to fit the Generalized Pareto distribution.')
				end
				% Extreme regime (low):
				wetObs=find(ptnData(indsTrainW,j)<=theta(3,j) & ~isnan(ptnData(indsTrainW,j)));
				wetPrd=find(ptrData(indsTrainW,j)<=theta(4,j) & ~isnan(ptrData(indsTrainW,j)));
				try
					pdObs=fitdist(-ptnData(indsTrainW(wetObs),j),'gp','theta',-theta(3,j)-100*eps);
					pdPrd=fitdist(-ptrData(indsTrainW(wetPrd),j),'gp','theta',-theta(4,j)-100*eps);
					aux(11:16,j)=[pdObs.k;pdObs.sigma;pdObs.theta;pdPrd.k;pdPrd.sigma;pdPrd.theta];
				catch
					warning('Not enough data to fit the Generalized Pareto distribution.')
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
				if variable==1
					aux=repmat(NaN,11,Nest);% [wet day threshold for the model; mean regime parameters for observations and model; extreme regime parameters]
					aux(1,:)=threshold;
					for j=1:Nest
						nP=nansum(double(ptnData(ii,j)<threshold & ~isnan(ptnData(ii,j))));
						if nP<length(ii)
							aux(1,j)=prctile(ptrData(ii,j),100*nP/sum(~isnan(ptnData(ii,j))));
							% Mean precipitation regime:
							wetObs=intersect(find(ptnData(ii,j)>=threshold & ptnData(ii,j)<theta(1,j)),find(~isnan(ptnData(ii,j))));
							wetPrd=intersect(find(ptrData(ii,j)>=aux(1,j) & ptrData(ii,j)<theta(2,j)),find(~isnan(ptrData(ii,j))));
							[paramEstsOBS]=gamfit(ptnData(ii(wetObs),j));
							[paramEstsRCM]=gamfit(ptrData(ii(wetPrd),j));
							aux(2:5,j)=[paramEstsOBS(:);paramEstsRCM(:)];
							% Extreme precipitation regime:
							wetObs=find(ptnData(ii,j)>=theta(1,j) & ~isnan(ptnData(ii,j)));
							wetPrd=find(ptrData(ii,j)>=theta(2,j) & ~isnan(ptrData(ii,j)));
							try
								pdObs=fitdist(ptnData(ii(wetObs),j),'gp','theta',theta(1,j)-100*eps);
								pdPrd=fitdist(ptrData(ii(wetPrd),j),'gp','theta',theta(2,j)-100*eps);
								aux(6:end,j)=[pdObs.k;pdObs.sigma;pdObs.theta;pdPrd.k;pdPrd.sigma;pdPrd.theta];
							catch
								warning('Not enough data to fit the Generalized Pareto distribution.')
							end
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
									ptrData(indsTrainW(indWet),j)=gamrnd(paramEsts(1),paramEsts(2),[length(indWet) 1]);
									if ~isempty(find(isinf(ptrData(ii,j)))),ptrData(ii(find(isinf(ptrData(ii,j)))),j)=threshold;end,
								end
							end
							if nP<length(ii)
								aux(1,j)=prctile(ptrData(ii,j),100*nP/sum(~isnan(ptnData(ii,j))));
								% Mean precipitation regime:
								wetObs=intersect(find(ptnData(ii,j)>=threshold & ptnData(ii,j)<theta(1,j)),find(~isnan(ptnData(ii,j))));
								wetPrd=intersect(find(ptrData(ii,j)>=aux(1,j) & ptrData(ii,j)<theta(2,j)),find(~isnan(ptrData(ii,j))));
								[paramEstsOBS]=gamfit(ptnData(ii(wetObs),j));
								[paramEstsRCM]=gamfit(ptrData(ii(wetPrd),j));
								aux(2:5,j)=[paramEstsOBS(:);paramEstsRCM(:)];
								% Extreme precipitation regime:
								wetObs=find(ptnData(ii,j)>=theta(1,j) & ~isnan(ptnData(ii,j)));
								wetPrd=find(ptrData(ii,j)>=theta(2,j) & ~isnan(ptrData(ii,j)));
								try
									pdObs=fitdist(ptnData(ii(wetObs),j),'gp','theta',theta(1,j)-100*eps);
									pdPrd=fitdist(ptrData(ii(wetPrd),j),'gp','theta',theta(2,j)-100*eps);
									aux(6:end,j)=[pdObs.k;pdObs.sigma;pdObs.theta;pdPrd.k;pdPrd.sigma;pdPrd.theta];
								catch
									warning('Not enough data to fit the Generalized Pareto distribution.')
								end
							else
								aux(1,j)=max(ptrData(ii,j));
							end
						end
					end
				else
					aux=repmat(NaN,16,Nest);% [mean regime parameters for observations and model; upper/lower extreme regime parameters]
					for j=1:Nest
						% Mean regime:
						wetObs=intersect(find(ptnData(ii,j)>theta(3,j) & ptnData(ii,j)<theta(1,j)),find(~isnan(ptnData(ii,j))));
						wetPrd=intersect(find(ptrData(ii,j)>theta(4,j) & ptrData(ii,j)<theta(2,j)),find(~isnan(ptrData(ii,j))));
						[paramEstsOBS(1),paramEstsOBS(2)]=normfit(ptnData(ii(wetObs),j));% [Mu parameter  Sigma parameter]
						[paramEstsRCM(1),paramEstsRCM(2)]=normfit(ptrData(ii(wetPrd),j));% [Mu parameter  Sigma parameter]
						aux(1:4,j)=[paramEstsOBS(:);paramEstsRCM(:)];
						% Extreme regime (up):
						wetObs=find(ptnData(ii,j)>=theta(1,j) & ~isnan(ptnData(ii,j)));
						wetPrd=find(ptrData(ii,j)>=theta(2,j) & ~isnan(ptrData(ii,j)));
						try
							pdObs=fitdist(ptnData(ii(wetObs),j),'gp','theta',theta(1,j)-100*eps);
							pdPrd=fitdist(ptrData(ii(wetPrd),j),'gp','theta',theta(2,j)-100*eps);
							aux(5:10,j)=[pdObs.k;pdObs.sigma;pdObs.theta;pdPrd.k;pdPrd.sigma;pdPrd.theta];
						catch
							warning('Not enough data to fit the Generalized Pareto distribution.')
						end
						% Extreme regime (low):
						wetObs=find(ptnData(ii,j)<=theta(3,j) & ~isnan(ptnData(ii,j)));
						wetPrd=find(ptrData(ii,j)<=theta(4,j) & ~isnan(ptrData(ii,j)));
						try
							pdObs=fitdist(ptnData(ii(wetObs),j),'gp','theta',-theta(3,j)-100*eps);
							pdPrd=fitdist(ptrData(ii(wetPrd),j),'gp','theta',-theta(4,j)-100*eps);
							aux(11:16,j)=[pdObs.k;pdObs.sigma;pdObs.theta;pdPrd.k;pdPrd.sigma;pdPrd.theta];
						catch
							warning('Not enough data to fit the Generalized Pareto distribution.')
						end
					end
				end
				Beta{i,c}=aux;
			end
		end
	end
end
MODEL = Beta;
