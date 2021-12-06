function Ypred=testeQM(ptrData,ptnData,indsTrain,indsTest,method,model,XDataCluster)

disp('Applying model...');

clustering = [];
clustering.NumberCenters = 1;
Xcluster = ones(size(ptrData,1),1);
if isfield(model,'clustering')
    if ~isempty(model.clustering)
        clustering = model.clustering;
        Xcluster = projectClustering(XDataCluster,clustering);
    end
end
[ndata,Nest]=size(ptnData);
[days,I1,I2]=unique(model.obsMeta.dailyList(:,5:8),'rows');
% window={[1:size(ptrData,1)]',[1:length(indsTest)]'};
window={[1:size(ptrData,1)]',indsTest(:)};
dateTest=datesym([1:size(ptrData,1)]','yyyymmdd');
if isfield(model,'dateTest')
    dateTest=model.dateTest;
else
    if isfield(model.dmn,'dailyList')
        dateTest=model.dmn.dailyList;
    elseif isfield(model.dmn,'dateList')
        dateTest=model.dmn.dateList;
    end
    dateTest=dateTest(indsTest,:);
end
threshold=0;pct=[];extrapolation='constant';freqCorr=0;
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
	if isfield(method.properties,'Variable')
		if ~isempty(method.properties.Variable)
            if ismember(lower(method.properties.Variable),{'tp';'pr';'precip';'precipitation';'precipitacion'})
				variable=1;
            elseif ismember(lower(method.properties.Variable),{'2t';'tas';'tmean';'temperature';'temperatura';'mx2t';'tasmax';'tmax';'maximum temperature';'temperatura maxima';'mn2t';'tasmin';'tmin';'minimum temperature';'temperatura minima'})
				variable=2;
			else
				variable=0;
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
			method.properties.threshold=0;threshold=0;
		end
	elseif variable==1
		method.properties.threshold=0;threshold=0;
	end
	if isfield(method.properties,'quantiles')
		if ~isempty(method.properties.quantiles)
            if isnumeric(method.properties.quantiles)
				pct=method.properties.quantiles;
            else
				pct=str2num(method.properties.quantiles);
            end
		else
			method.properties.quantiles=pct;
		end
	else
		method.properties.quantiles=pct;
	end
	if isfield(method.properties,'extrapolation')
		if ~isempty(method.properties.extrapolation)
			extrapolation=method.properties.extrapolation;
		else
			method.properties.extrapolation='constant';
		end
	else
		method.properties.extrapolation='constant';
	end
end

Ypred=ptrData(indsTest,:);
if clustering.NumberCenters==1
    for i=1:size(window,1)
        [indsTestW,I1,I2]=intersect(window{i,1},indsTest);
        for j=1:Nest
            if (size(model.MODEL{i,1,j,1},1)>=3 & size(model.MODEL{i,1,j,2},1)>=3)
                if variable==1
                    if freqCorr==1,% 2013 Renate et al. Multivariable_error_correction_of_RCMs
                        if model.MODEL{i,1,j,2}(end,1)<=threshold
                            indWet=find(ptrData(indsTestW,j)>=threshold & ~isnan(ptrData(indsTestW,j)));
                            if ~isempty(indWet)
                                [paramEsts]=gamfit(ptrData(indsTestW(indWet),j));% [Shape parameter  Scale parameter]
                                indWet=intersect(find(ptrData(indsTestW,j)>=model.MODEL{i,1,j,2}(end,1) & ptrData(indsTestW,j)<threshold),find(~isnan(ptrData(indsTestW,j))));
                                if ~isempty(indWet)
                                    ptrData(indsTestW(indWet),j)=gamrnd(paramEsts(1),paramEsts(2),[length(indWet) 1]);
                                end
                                if ~isempty(find(isinf(ptrData(indsTestW,j)))),ptrData(indsTestW(find(isinf(ptrData(indsTestW,j)))),j)=threshold;end,
                            end
                        end
                    end
                    drySim=find(ptrData(indsTestW,j)<model.MODEL{i,1,j,2}(end,1) & ~isnan(ptrData(indsTestW,j)));Ypred(I2(drySim),j)=0;
                    wetSim=find(ptrData(indsTestW,j)>=model.MODEL{i,1,j,2}(end,1) & ~isnan(ptrData(indsTestW,j)));
                    if ~isempty(wetSim)
                        switch lower(extrapolation)
                            case {'no';'false'},
                                warning('Without extrapolation all the out of range values will be defined as NaNs')
                                prbSim=interp1(model.MODEL{i,1,j,2}(1:end-1,1),model.MODEL{i,1,j,2}(1:end-1,2),ptrData(indsTestW(wetSim),j),'linear');
                                aux=interp1(model.MODEL{i,1,j,1}(1:end-1,2),model.MODEL{i,1,j,1}(1:end-1,1),prbSim,'linear');
                            case {'linear';'lineal'},
                                prbSim=interp1(model.MODEL{i,1,j,2}(1:end-1,1),model.MODEL{i,1,j,2}(1:end-1,2),ptrData(indsTestW(wetSim),j),'linear','extrap');
                                aux=interp1(model.MODEL{i,1,j,1}(1:end-1,2),model.MODEL{i,1,j,1}(1:end-1,1),prbSim,'linear','extrap');
                            case {'constant';'constante'},
                                prbSim=interp1(model.MODEL{i,1,j,2}(1:end-1,1),model.MODEL{i,1,j,2}(1:end-1,2),ptrData(indsTestW(wetSim),j),'linear','extrap');
                                aux=interp1(model.MODEL{i,1,j,1}(1:end-1,2),model.MODEL{i,1,j,1}(1:end-1,1),prbSim,'linear','extrap');
                                % Extrapolacion valores por debajo del limite inferior:
                                indNSim=find(prbSim<0 & ~isnan(aux));
                                if ~isempty(indNSim)
                                    aux(indNSim)=ptrData(indsTestW(wetSim(indNSim)),j)+model.MODEL{i,1,j,1}(1,1)-model.MODEL{i,1,j,2}(1,1);
                                end
                                % Extrapolacion valores por encima del limite superior:
                                indNSim=find(prbSim>100 & ~isnan(aux));
                                if ~isempty(indNSim)
                                    aux(indNSim)=ptrData(indsTestW(wetSim(indNSim)),j)+model.MODEL{i,1,j,1}(end-1,1)-model.MODEL{i,1,j,2}(end-1,1);
                                end
                            otherwise,
                                warning(['The extrapolation method: ' extrapolation ' is not available. No extrapolation has been applied and all the out of range values have been defined as NaNs'])
                                prbSim=interp1(model.MODEL{i,1,j,2}(1:end-1,1),model.MODEL{i,1,j,2}(1:end-1,2),ptrData(indsTestW(wetSim),j),'linear');
                                aux=interp1(model.MODEL{i,1,j,1}(1:end-1,2),model.MODEL{i,1,j,1}(1:end-1,1),prbSim,'linear');
                        end
                        % [w1,w2,w3]=intersect(window{i,2},I2(wetSim));
                        % Ypred(w2,j)=aux(w3);
                        Ypred(I2(wetSim),j)=aux;
                    end
                else
                    switch lower(extrapolation)
                        case {'no';'false'},
                            warning('Without extrapolation all the out of range values will be defined as NaNs')
                            prbSim=interp1(model.MODEL{i,1,j,2}(1:end-1,1),model.MODEL{i,1,j,2}(1:end-1,2),ptrData(indsTestW,j),'linear');
                            aux=interp1(model.MODEL{i,1,j,1}(1:end-1,2),model.MODEL{i,1,j,1}(1:end-1,1),prbSim,'linear');
                        case {'linear';'lineal'},
                            prbSim=interp1(model.MODEL{i,1,j,2}(1:end-1,1),model.MODEL{i,1,j,2}(1:end-1,2),ptrData(indsTestW,j),'linear','extrap');
                            aux=interp1(model.MODEL{i,1,j,1}(1:end-1,2),model.MODEL{i,1,j,1}(1:end-1,1),prbSim,'linear','extrap');
                        case {'constant';'constante'},
                            prbSim=interp1(model.MODEL{i,1,j,2}(1:end-1,1),model.MODEL{i,1,j,2}(1:end-1,2),ptrData(indsTestW,j),'linear','extrap');
                            aux=interp1(model.MODEL{i,1,j,1}(1:end-1,2),model.MODEL{i,1,j,1}(1:end-1,1),prbSim,'linear','extrap');
                            % Extrapolacion valores por debajo del limite inferior:
                            indNSim=find(prbSim<0 & ~isnan(aux));
                            if ~isempty(indNSim)
                                aux(indNSim)=ptrData(indsTestW(indNSim),j)+model.MODEL{i,1,j,1}(1,1)-model.MODEL{i,1,j,2}(1,1);
                            end
                            % Extrapolacion valores por encima del limite superior:
                            indNSim=find(prbSim>100 & ~isnan(aux));
                            if ~isempty(indNSim)
                                aux(indNSim)=ptrData(indsTestW(indNSim),j)+model.MODEL{i,1,j,1}(end-1,1)-model.MODEL{i,1,j,2}(end-1,1);
                            end
                        otherwise,
                            warning(['The extrapolation method: ' extrapolation ' is not available. No extrapolation has been applied and all the out of range values have been defined as NaNs'])
                            prbSim=interp1(model.MODEL{i,1,j,2}(1:end-1,1),model.MODEL{i,1,j,2}(1:end-1,2),ptrData(indsTestW,j),'linear');
                            aux=interp1(model.MODEL{i,1,j,1}(1:end-1,2),model.MODEL{i,1,j,1}(1:end-1,1),prbSim,'linear');
                    end
%                    [w1,w2,w3]=intersect(window{i,2},I2);
%                    Ypred(w2,j)=aux(w3);
                    Ypred(I2,j)=aux;
                end
            end
        end
    end
else
	for i=1:size(window,1)
		[indsTestW,I1,I2]=intersect(window{i,1},indsTest);
		for c=1:prod(clustering.NumberCenters)
            if prod(clustering.NumberCenters)>1,disp(sprintf('   ...cluster %d de %d',c,prod(clustering.NumberCenters))),end
            ii = find(Xcluster==c);
            [ii,J1,J2] = intersect(ii,indsTestW);
            if ~isempty(ii)
                for j=1:Nest
                    if (size(model.MODEL{i,c,j,1},1)>=3 & size(model.MODEL{i,c,j,2},1)>=3)
                        if variable==1
                            if freqCorr==1,% 2013 Renate et al. Multivariable_error_correction_of_RCMs
                                if model.MODEL{i,c,j,2}(end,1)<=threshold
                                    indWet=find(ptrData(ii,j)>=threshold & ~isnan(ptrData(ii,j)));
                                    if ~isempty(indWet)
                                        [paramEsts]=gamfit(ptrData(ii(indWet),j));% [Shape parameter  Scale parameter]
                                        indWet=intersect(find(ptrData(ii,j)>=model.MODEL{i,c,j,2}(end,1) & ptrData(ii,j)<threshold),find(~isnan(ptrData(ii,j))));
                                        if ~isempty(indWet)
                                            ptrData(ii(indWet),j)=gamrnd(paramEsts(1),paramEsts(2),[length(indWet) 1]);
                                        end
                                        if ~isempty(find(isinf(ptrData(ii,j)))),ptrData(ii(find(isinf(ptrData(ii,j)))),j)=threshold;end,
                                    end
                                end
                            end
%                            drySim=find(ptrData(ii,j)<model.MODEL{i,c,j,2}(end,1) & ~isnan(ptrData(ii,j)));Ypred(I2(drySim),j)=0;
                            drySim=find(ptrData(ii,j)<model.MODEL{i,c,j,2}(end,1) & ~isnan(ptrData(ii,j)));Ypred(I2(J2(drySim)),j)=0;
                            wetSim=find(ptrData(ii,j)>=model.MODEL{i,c,j,2}(end,1) & ~isnan(ptrData(ii,j)));
                            if ~isempty(wetSim)
                                switch lower(extrapolation)
                                    case {'no';'false'},
                                        warning('Without extrapolation all the out of range values will be defined as NaNs')
                                        prbSim=interp1(model.MODEL{i,c,j,2}(1:end-1,1),model.MODEL{i,c,j,2}(1:end-1,2),ptrData(ii(wetSim),j),'linear');
                                        aux=interp1(model.MODEL{i,c,j,1}(1:end-1,2),model.MODEL{i,c,j,1}(1:end-1,1),prbSim,'linear');
                                    case {'linear';'lineal'},
                                        prbSim=interp1(model.MODEL{i,c,j,2}(1:end-1,1),model.MODEL{i,c,j,2}(1:end-1,2),ptrData(ii(wetSim),j),'linear','extrap');
                                        aux=interp1(model.MODEL{i,c,j,1}(1:end-1,2),model.MODEL{i,c,j,1}(1:end-1,1),prbSim,'linear','extrap');
                                    case {'constant';'constante'},
                                        prbSim=interp1(model.MODEL{i,c,j,2}(1:end-1,1),model.MODEL{i,c,j,2}(1:end-1,2),ptrData(ii(wetSim),j),'linear','extrap');
                                        aux=interp1(model.MODEL{i,c,j,1}(1:end-1,2),model.MODEL{i,c,j,1}(1:end-1,1),prbSim,'linear','extrap');
                                        indNSim=find(prbSim<0 & ~isnan(aux));
                                        if ~isempty(indNSim)
                                            aux(indNSim)=ptrData(ii(wetSim(indNSim)),j)+model.MODEL{i,c,j,1}(1,1)-model.MODEL{i,c,j,2}(1,1);
                                        end
                                        indNSim=find(prbSim>100 & ~isnan(aux));
                                        if ~isempty(indNSim)
                                            aux(indNSim)=ptrData(ii(wetSim(indNSim)),j)+model.MODEL{i,c,j,1}(end-1,1)-model.MODEL{i,c,j,2}(end-1,1);
                                        end
                                    otherwise,
                                        warning(['The extrapolation method: ' extrapolation ' is not available. No extrapolation has been applied and all the out of range values have been defined as NaNs'])
                                        prbSim=interp1(model.MODEL{i,c,j,2}(1:end-1,1),model.MODEL{i,c,j,2}(1:end-1,2),ptrData(ii(wetSim),j),'linear');
                                        aux=interp1(model.MODEL{i,c,j,1}(1:end-1,2),model.MODEL{i,c,j,1}(1:end-1,1),prbSim,'linear');
                                end
%                                [w1,w2,w3]=intersect(window{i,2},I2(wetSim));
                                % [w1,w2,w3]=intersect(window{i,2},I2(J2(wetSim)));
                                % Ypred(w2,j)=aux(w3);
                                Ypred(I2(J2(wetSim)),j)=aux;
                            end
                        else
                            switch lower(extrapolation)
                                case {'no';'false'},
                                    warning('Without extrapolation all the out of range values will be defined as NaNs')
                                    prbSim=interp1(model.MODEL{i,c,j,2}(1:end-1,1),model.MODEL{i,c,j,2}(1:end-1,2),ptrData(ii,j),'linear');
                                    aux=interp1(model.MODEL{i,c,j,1}(1:end-1,2),model.MODEL{i,c,j,1}(1:end-1,1),prbSim,'linear');
                                case {'linear';'lineal'},
                                    prbSim=interp1(model.MODEL{i,c,j,2}(1:end-1,1),model.MODEL{i,c,j,2}(1:end-1,2),ptrData(ii,j),'linear','extrap');
                                    aux=interp1(model.MODEL{i,c,j,1}(1:end-1,2),model.MODEL{i,c,j,1}(1:end-1,1),prbSim,'linear','extrap');
                                case {'constant';'constante'},
                                    prbSim=interp1(model.MODEL{i,c,j,2}(1:end-1,1),model.MODEL{i,c,j,2}(1:end-1,2),ptrData(ii,j),'linear','extrap');
                                    aux=interp1(model.MODEL{i,c,j,1}(1:end-1,2),model.MODEL{i,c,j,1}(1:end-1,1),prbSim,'linear','extrap');
                                    % Extrapolacion valores por debajo del limite inferior:
                                    indNSim=find(prbSim<0 & ~isnan(aux));
                                    if ~isempty(indNSim)
                                        aux(indNSim)=ptrData(ii(indNSim),j)+model.MODEL{i,c,j,1}(1,1)-model.MODEL{i,c,j,2}(1,1);
                                    end
                                    % Extrapolacion valores por encima del limite superior:
                                    indNSim=find(prbSim>100 & ~isnan(aux));
                                    if ~isempty(indNSim)
                                        aux(indNSim)=ptrData(ii(indNSim),j)+model.MODEL{i,c,j,1}(end-1,1)-model.MODEL{i,c,j,2}(end-1,1);
                                    end
                                otherwise,
                                    warning(['The extrapolation method: ' extrapolation ' is not available. No extrapolation has been applied and all the out of range values have been defined as NaNs'])
                                    prbSim=interp1(model.MODEL{i,c,j,2}(1:end-1,1),model.MODEL{i,c,j,2}(1:end-1,2),ptrData(ii,j),'linear');
                                    aux=interp1(model.MODEL{i,c,j,1}(1:end-1,2),model.MODEL{i,c,j,1}(1:end-1,1),prbSim,'linear');
                            end
                            [w1,w2,w3]=intersect(window{i,2},ii);
%                            Ypred(w1,j)=aux(w3);
                            Ypred(w2,j)=aux(w3);
                        end
                    end
				end
			end
		end
	end
end
if variable==1;Ypred(find(Ypred<threshold))=0;end

% Ypred=ptrData(indsTest,:);
% if clustering.NumberCenters==1
% 	for i=1:size(window,1)
% 		[indsTestW,I1,I2]=intersect(window{i},indsTest);
% 		for j=1:Nest
% 			if variable==1
% 				if freqCorr==1,% 2013 Renate et al. Multivariable_error_correction_of_RCMs
% 					if model.MODEL{i}(end,j)<=threshold
% 						indWet=find(ptrData(indsTestW,j)>=threshold & ~isnan(ptrData(indsTestW,j)));
% 						if ~isempty(indWet)
% 							[paramEsts]=gamfit(ptrData(indsTestW(indWet),j));% [Shape parameter  Scale parameter]
% 							indWet=intersect(find(ptrData(indsTestW,j)>model.MODEL{i}(end,j) & ptrData(indsTestW,j)<threshold),find(~isnan(ptrData(indsTestW,j))));
% 							if ~isempty(indWet)
% 								ptrData(indsTestW(indWet),j)=gamrnd(paramEsts(1),paramEsts(2),[length(indWet) 1]);
% 							end
% 							if ~isempty(find(isinf(ptrData(indsTestW,j)))),ptrData(indsTestW(find(isinf(ptrData(indsTestW,j)))),j)=threshold;end,
% 						end
% 					end
% 				end
% 				drySim=find(ptrData(indsTestW,j)<model.MODEL{i}(end,j) & ~isnan(ptrData(indsTestW,j)));Ypred(I2(drySim),j)=0;
% 				wetSim=find(ptrData(indsTestW,j)>=model.MODEL{i}(end,j) & ~isnan(ptrData(indsTestW,j)));
% 				if ~isempty(wetSim)
% 					pctSim=prctile(ptrData(indsTestW(wetSim),j),pct);
% 					pctSimCor=pctSim(:)+model.MODEL{i}(1:length(pct),j);
% 					[Qsim,Ia,Ib]=unique(ptrData(indsTestW(wetSim),j));NSim=100;
% 					if length(Qsim)>1
% 						NSim=hist(ptrData(indsTestW(wetSim),j),Qsim);NSim=100*cumsum(NSim)/sum(NSim);
% 					end
% 					switch lower(extrapolation)
% 						case {'no';'false'},
% 							warning('Without extrapolation all the out of range values will be defined as NaNs')
% 							aux=interp1(pct,pctSimCor,NSim,'linear');
% 							[w1,w2,w3]=intersect(window{i,2},I2(wetSim));
% 							Ypred(w1,j)=aux(Ib(w3));
% 						case {'linear';'lineal'},
% 							aux = interp1(pct,pctSimCor,NSim,'linear','extrap');
% 							[w1,w2,w3]=intersect(window{i,2},I2(wetSim));
% 							Ypred(w1,j)=aux(Ib(w3));
% 						case {'constant';'constante'},
% 							aux = interp1(pct,pctSimCor,NSim,'linear');
% 							% Extrapolacion valores por debajo del limite inferior:
% 							indNSim=find(NSim<pct(1) & isnan(aux));
% 							if ~isempty(indNSim)
% 								aux(indNSim)=Qsim(indNSim)+model.MODEL{i}(1,j);
% 							end
% 							% Extrapolacion valores por encima del limite superior:
% 							indNSim=find(NSim>pct(end) & isnan(aux));
% 							if ~isempty(indNSim)
% 								aux(indNSim)=Qsim(indNSim)+model.MODEL{i}(length(pct),j);
% 							end
% 							[w1,w2,w3]=intersect(window{i,2},I2(wetSim));
% 							Ypred(w1,j)=aux(Ib(w3));
% 						otherwise,
% 							warning(['The extrapolation method: ' extrapolation ' is not available. No extrapolation has been applied and all the out of range values have been defined as NaNs'])
% 							aux=interp1(pct,pctSimCor,NSim,'linear');
% 							[w1,w2,w3]=intersect(window{i,2},I2(wetSim));
% 							Ypred(w1,j)=aux(Ib(w3));
% 					end
% 				end
% 			else
% 				pctSim=prctile(ptrData(indsTestW,j),pct);
% 				pctSimCor=pctSim(:)+model.MODEL{i}(1:length(pct),j);
% 				[Qsim,Ia,Ib]=unique(ptrData(indsTestW,j));NSim=100;
% 				if length(Qsim)>1
% 					NSim=hist(ptrData(indsTestW,j),Qsim);NSim=100*cumsum(NSim)/sum(NSim);
% 				end
% 				switch lower(extrapolation)
% 					case {'no';'false'},
% 						warning('Without extrapolation all the out of range values will be defined as NaNs')
% 						aux=interp1(pct,pctSimCor,NSim,'linear');
% 						[w1,w2,w3]=intersect(window{i,2},I2);
% 						Ypred(w1,j)=aux(Ib(w3));
% 					case {'linear';'lineal'},
% 						aux = interp1(pct,pctSimCor,NSim,'linear','extrap');
% 						[w1,w2,w3]=intersect(window{i,2},I2);
% 						Ypred(w1,j)=aux(Ib(w3));
% 					case {'constant';'constante'},
% 						aux = interp1(pct,pctSimCor,NSim,'linear');
% 						% Extrapolacion valores por debajo del limite inferior:
% 						indNSim=find(NSim<pct(1) & isnan(aux));
% 						if ~isempty(indNSim)
% 							aux(indNSim)=Qsim(indNSim)+model.MODEL{i}(1,j);
% 						end
% 						% Extrapolacion valores por encima del limite superior:
% 						indNSim=find(NSim>pct(end) & isnan(aux));
% 						if ~isempty(indNSim)
% 							aux(indNSim)=Qsim(indNSim)+model.MODEL{i}(length(pct),j);
% 						end
% 						[w1,w2,w3]=intersect(window{i,2},I2);
% 						Ypred(w1,j)=aux(Ib(w3));
% 					otherwise,
% 						warning(['The extrapolation method: ' extrapolation ' is not available. No extrapolation has been applied and all the out of range values have been defined as NaNs'])
% 						aux=interp1(pct,pctSimCor,NSim,'linear');
% 						[w1,w2,w3]=intersect(window{i,2},I2);
% 						Ypred(w1,j)=aux(Ib(w3));
% 				end
% 			end
% 		end
% 	end
% else
% 	for i=1:size(window,1)
% 		[indsTestW,I1,I2]=intersect(window{i},indsTest);
% 		for c=1:prod(clustering.NumberCenters)
% 			if prod(clustering.NumberCenters)>1,disp(sprintf('   ...cluster %d de %d',c,prod(clustering.NumberCenters))),end
% 			ii = find(Xcluster==c);
% 			[ii,J1,J2] = intersect(ii,indsTestW);
% 			if ~isempty(ii)
% 				for j=1:Nest
% 					if variable==1
% 						if freqCorr==1,% 2013 Renate et al. Multivariable_error_correction_of_RCMs
% 							if model.MODEL{i,c}(end,j)<=threshold
% 								indWet=find(ptrData(ii,j)>=threshold & ~isnan(ptrData(ii,j)));
% 								if ~isempty(indWet)
% 									[paramEsts]=gamfit(ptrData(ii(indWet),j));% [Shape parameter  Scale parameter]
% 									indWet=intersect(find(ptrData(ii,j)>model.MODEL{i,c}(end,j) & ptrData(ii,j)<threshold),find(~isnan(ptrData(ii,j))));
% 									if ~isempty(indWet)
% 										ptrData(ii(indWet),j)=gamrnd(paramEsts(1),paramEsts(2),[length(indWet) 1]);
% 									end
% 									if ~isempty(find(isinf(ptrData(ii,j)))),ptrData(ii(find(isinf(ptrData(ii,j)))),j)=threshold;end,
% 								end
% 							end
% 						end
% 						drySim=find(ptrData(ii,j)<model.MODEL{i,c}(end,j) & ~isnan(ptrData(ii,j)));Ypred(I2(J2(drySim)),j)=0;
% 						wetSim=find(ptrData(ii,j)>=model.MODEL{i,c}(end,j) & ~isnan(ptrData(ii,j)));
% 						if ~isempty(wetSim)
% 							pctSim=prctile(ptrData(ii(wetSim),j),pct);
% 							pctSimCor=pctSim(:)+model.MODEL{i,c}(1:length(pct),j);
% 							[Qsim,Ia,Ib]=unique(ptrData(ii(wetSim),j));NSim=100;
% 							if length(Qsim)>1
% 								NSim=hist(ptrData(ii(wetSim),j),Qsim);NSim=100*cumsum(NSim)/sum(NSim);
% 							end
% 							switch lower(extrapolation)
% 								case {'no';'false'},
% 									warning('Without extrapolation all the out of range values will be defined as NaNs')
% 									aux=interp1(pct,pctSimCor,NSim,'linear');
% 									[w1,w2,w3]=intersect(window{i,2},I2(J2(wetSim)));
% 									Ypred(w1,j)=aux(Ib(w3));
% 								case {'linear';'lineal'},
% 									aux = interp1(pct,pctSimCor,NSim,'linear','extrap');
% 									[w1,w2,w3]=intersect(window{i,2},I2(J2(wetSim)));
% 									Ypred(w1,j)=aux(Ib(w3));
% 								case {'constant';'constante'},
% 									aux = interp1(pct,pctSimCor,NSim,'linear');
% 									% Extrapolacion valores por debajo del limite inferior:
% 									indNSim=find(NSim<pct(1) & isnan(aux));
% 									if ~isempty(indNSim)
% 										aux(indNSim)=Qsim(indNSim)+model.MODEL{i}(1,j);
% 									end
% 									% Extrapolacion valores por encima del limite superior:
% 									indNSim=find(NSim>pct(end) & isnan(aux));
% 									if ~isempty(indNSim)
% 										aux(indNSim)=Qsim(indNSim)+model.MODEL{i}(length(pct),j);
% 									end
% 									[w1,w2,w3]=intersect(window{i,2},I2(J2(wetSim)));
% 									Ypred(w1,j)=aux(Ib(w3));
% 								otherwise,
% 									warning(['The extrapolation method: ' extrapolation ' is not available. No extrapolation has been applied and all the out of range values have been defined as NaNs'])
% 									aux=interp1(pct,pctSimCor,NSim,'linear');
% 									[w1,w2,w3]=intersect(window{i,2},I2(J2(wetSim)));
% 									Ypred(w1,j)=aux(Ib(w3));
% 							end
% 						end
% 					else
% 						pctSim=prctile(ptrData(ii,j),pct);
% 						pctSimCor=pctSim(:)+model.MODEL{i,c}(1:length(pct),j);
% 						[Qsim,Ia,Ib]=unique(ptrData(ii,j));NSim=100;
% 						if length(Qsim)>1
% 							NSim=hist(ptrData(ii,j),Qsim);NSim=100*cumsum(NSim)/sum(NSim);
% 						end
% 						switch lower(extrapolation)
% 							case {'no';'false'},
% 								warning('Without extrapolation all the out of range values will be defined as NaNs')
% 								aux=interp1(pct,pctSimCor,NSim,'linear');
% 								[w1,w2,w3]=intersect(window{i,2},I2(J2));
% 								Ypred(w1,j)=aux(Ib(w3));
% 							case {'linear';'lineal'},
% 								aux = interp1(pct,pctSimCor,NSim,'linear','extrap');
% 								[w1,w2,w3]=intersect(window{i,2},I2(J2));
% 								Ypred(w1,j)=aux(Ib(w3));
% 							case {'constant';'constante'},
% 								aux = interp1(pct,pctSimCor,NSim,'linear');
% 								% Extrapolacion valores por debajo del limite inferior:
% 								indNSim=find(NSim<pct(1) & isnan(aux));
% 								if ~isempty(indNSim)
% 									aux(indNSim)=Qsim(indNSim)+model.MODEL{i}(1,j);
% 								end
% 								% Extrapolacion valores por encima del limite superior:
% 								indNSim=find(NSim>pct(end) & isnan(aux));
% 								if ~isempty(indNSim)
% 									aux(indNSim)=Qsim(indNSim)+model.MODEL{i}(length(pct),j);
% 								end
% 								[w1,w2,w3]=intersect(window{i,2},I2(J2));
% 								Ypred(w1,j)=aux(Ib(w3));
% 							otherwise,
% 								warning(['The extrapolation method: ' extrapolation ' is not available. No extrapolation has been applied and all the out of range values have been defined as NaNs'])
% 								aux=interp1(pct,pctSimCor,NSim,'linear');
% 								[w1,w2,w3]=intersect(window{i,2},I2(J2));
% 								Ypred(w1,j)=aux(Ib(w3));
% 						end
% 					end
% 				end
% 			end
% 		end
% 	end
% end
% if variable==1;Ypred(find(Ypred<threshold))=0;end
