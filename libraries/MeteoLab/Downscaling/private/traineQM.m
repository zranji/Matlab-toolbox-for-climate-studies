function MODEL=traineQM(ptrData,ptnData,indsTrain,indsTest,method,model,XDataCluster)

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

[ndata,Nest]=size(ptnData);
window={[1:ndata]};variable=0;threshold=0;extrapolation='false';freqCorr=0;pct=[];%pct=1:99;
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
	if isfield(method.properties,'extrapolation')
		if ~isempty(method.properties.extrapolation)
			extrapolation=method.properties.extrapolation;
		else
			method.properties.extrapolation='constant';
		end
	else
		method.properties.extrapolation='constant';
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
end

if clustering.NumberCenters==1
	Beta=cell(length(window),1,Nest,2);% Window, Cluster, [Obs, Prd]
	for i=1:length(window)
		indsTrainW=intersect(window{i},indsTrain);
		for j=1:Nest
			if variable==1
				auxT=threshold;
				nP=nansum(double(ptnData(indsTrainW,j)<threshold & ~isnan(ptnData(indsTrainW,j))));
				if nP<length(indsTrainW)
					auxT=prctile(ptrData(indsTrainW,j),100*nP/sum(~isnan(ptnData(indsTrainW,j))));
				else
					auxT=max(ptrData(indsTrainW,j));
				end
				if freqCorr==1,% 2013 Renate et al. Multivariable_error_correction_of_RCMs
					if auxT<=threshold
						indWet=find(ptrData(indsTrainW,j)>=threshold & ~isnan(ptrData(indsTrainW,j)));
						if ~isempty(indWet)
							[paramEsts]=gamfit(ptrData(indsTrainW(indWet),j));% [Shape parameter  Scale parameter]
						else
							nP1=nansum(double(ptrData(indsTrainW,j)<auxT & ~isnan(ptrData(indsTrainW,j))));
							aux1=prctile(ptnData(indsTrainW,j),100*nP1/sum(~isnan(ptrData(indsTrainW,j))));
							[paramEsts]=gamfit(ptnData(indsTrainW(intersect(find(ptnData(indsTrainW,j)>=threshold & ptnData(indsTrainW,j)<aux1),find(~isnan(ptnData(indsTrainW,j))))),j));% [Shape parameter  Scale parameter]
						end
						indWet=intersect(find(ptrData(indsTrainW,j)>=auxT & ptrData(indsTrainW,j)<threshold),find(~isnan(ptrData(indsTrainW,j))));
						if ~isempty(indWet)
							ptrData(indsTrainW(indWet),j)=gamrnd(paramEsts(1),paramEsts(2),[length(indWet) 1]);
							if ~isempty(find(isinf(ptrData(indsTrainW,j)))),ptrData(indsTrainW(find(isinf(ptrData(indsTrainW,j)))),j)=threshold;end,
						end
					end
					if nP<length(indsTrainW)
						auxT=prctile(ptrData(indsTrainW,j),100*nP/sum(~isnan(ptnData(indsTrainW,j))));
					else
						auxT=max(ptrData(indsTrainW,j));
					end
				end
				wetObs=find(ptnData(indsTrainW,j)>=threshold & ~isnan(ptnData(indsTrainW,j)));
				wetPrd=find(ptrData(indsTrainW,j)>=auxT & ~isnan(ptrData(indsTrainW,j)));
				if ~isempty(wetObs) & ~isempty(wetPrd)
					if isempty(pct)
						pctObs=unique(ptnData(indsTrainW(wetObs),j));
						pctPrd=unique(ptrData(indsTrainW(wetPrd),j));
					else
						pctObs=prctile(ptnData(indsTrainW(wetObs),j),pct);
						pctPrd=prctile(ptrData(indsTrainW(wetPrd),j),pct);
					end
					if size(pctObs,1)>1, pctObs=pctObs'; end
					if size(pctPrd,1)>1, pctPrd=pctPrd'; end
					NSim=100;
				    if length(pctObs)>1
						NSim=hist(ptnData(indsTrainW(wetObs),j),pctObs);NSim=100*cumsum(NSim)/sum(NSim);
					end
					[aux, Ia, Ib]=unique(pctObs);
					auxObs=[pctObs(Ia);NSim(Ia)]'; clear aux Ia Ib
					%auxObs=[pctObs(:) NSim(:)];
					auxObs=auxObs([find(diff(auxObs(:,2))>eps);size(auxObs,1)],:);
					Beta{i,1,j,1}=[auxObs;threshold NaN];
					NSim=100;
					if length(pctPrd)>1
						NSim=hist(ptrData(indsTrainW(wetPrd),j),pctPrd);NSim=100*cumsum(NSim)/sum(NSim);
					end
					[aux, Ia, Ib]=unique(pctPrd);
					auxPrd=[pctPrd(Ia);NSim(Ia)]'; clear aux Ia Ib
					%auxPrd=[pctPrd(:) NSim(:)];
					auxPrd=auxPrd([find(diff(auxPrd(:,2))>eps);size(auxPrd,1)],:);Beta{i,1,j,2}=[auxPrd;auxT NaN];
%					pctObs=prctile(ptnData(indsTrainW(wetObs),j),pct);
%					pctPrd=prctile(ptrData(indsTrainW(wetPrd),j),pct);
%					aux(1:length(pct),j)=pctObs-pctPrd;
				end
			else
				indsTrainWObs=find(~isnan(ptnData(indsTrainW,j)));
				indsTrainWPrd=find(~isnan(ptrData(indsTrainW,j)));
				if ~isempty(indsTrainWObs) & ~isempty(indsTrainWPrd)
					if isempty(pct)
						pctObs=unique(ptnData(indsTrainW(indsTrainWObs),j));
						pctPrd=unique(ptrData(indsTrainW(indsTrainWPrd),j));
					else
						pctObs=prctile(ptnData(indsTrainW(indsTrainWObs),j),pct);
						pctPrd=prctile(ptrData(indsTrainW(indsTrainWPrd),j),pct);
					end
					if size(pctObs,1)>1, pctObs=pctObs'; end
					if size(pctPrd,1)>1, pctPrd=pctPrd'; end
					NSim=100;
				    if length(pctObs)>1
						NSim=hist(ptnData(indsTrainW(indsTrainWObs),j),pctObs);NSim=100*cumsum(NSim)/sum(NSim);
					end
					[aux, Ia, Ib]=unique(pctObs);
					auxObs=[pctObs(Ia);NSim(Ia)]'; clear aux Ia Ib
					%auxObs=[pctObs(:) NSim(:)];
					auxObs=auxObs([find(diff(auxObs(:,2))>eps);size(auxObs,1)],:);Beta{i,1,j,1}=[auxObs;threshold NaN];
					NSim=100;
					if length(pctPrd)>1
						NSim=hist(ptrData(indsTrainW(indsTrainWPrd),j),pctPrd);NSim=100*cumsum(NSim)/sum(NSim);
					end
					[aux, Ia, Ib]=unique(pctPrd);
					auxPrd=[pctPrd(Ia);NSim(Ia)]'; clear aux Ia Ib
					%auxPrd=[pctPrd(:) NSim(:)];
					auxPrd=auxPrd([find(diff(auxPrd(:,2))>eps);size(auxPrd,1)],:);Beta{i,1,j,2}=[auxPrd;threshold NaN];
%					pctObs=prctile(ptnData(indsTrainW,j),pct);
%					pctPrd=prctile(ptrData(indsTrainW,j),pct);
%					aux(1:length(pct),j)=pctObs-pctPrd;
				end
			end
		end
%		Beta{i}=aux;
	end
else
	Beta=cell(length(window),prod(clustering.NumberCenters),Nest,2);
	for i=1:length(window)
		indsTrainW=intersect(window{i},indsTrain);
		for c=1:prod(clustering.NumberCenters)
			if prod(clustering.NumberCenters)>1,disp(sprintf('   ...cluster %d de %d',c,prod(clustering.NumberCenters))),end
			ii = find(Xcluster==c);
			ii = intersect(ii,indsTrainW);
			if ~isempty(ii)
				for j=1:Nest
					if variable==1
						auxT=threshold;
						nP=nansum(double(ptnData(ii,j)<threshold & ~isnan(ptnData(ii,j))));
						if nP<length(ii)
							auxT=prctile(ptrData(ii,j),100*nP/sum(~isnan(ptnData(ii,j))));
						else
							auxT=max(ptrData(ii,j));
						end
						if freqCorr==1,% 2013 Renate et al. Multivariable_error_correction_of_RCMs
							if auxT<=threshold
								indWet=find(ptrData(ii,j)>=threshold & ~isnan(ptrData(ii,j)));
								if ~isempty(indWet)
									[paramEsts]=gamfit(ptrData(ii(indWet),j));% [Shape parameter  Scale parameter]
								else
									nP1=nansum(double(ptrData(ii,j)<auxT & ~isnan(ptrData(ii,j))));
									aux1=prctile(ptnData(ii,j),100*nP1/sum(~isnan(ptrData(ii,j))));
									[paramEsts]=gamfit(ptnData(ii(intersect(find(ptnData(ii,j)>=threshold & ptnData(ii,j)<aux1),find(~isnan(ptnData(ii,j))))),j));% [Shape parameter  Scale parameter]
								end
								indWet=intersect(find(ptrData(ii,j)>=auxT & ptrData(ii,j)<threshold),find(~isnan(ptrData(ii,j))));
								if ~isempty(indWet)
									ptrData(ii(indWet),j)=gamrnd(paramEsts(1),paramEsts(2),[length(indWet) 1]);
									if ~isempty(find(isinf(ptrData(ii,j)))),ptrData(ii(find(isinf(ptrData(ii,j)))),j)=threshold;end,
								end
							end
							if nP<length(ii)
								auxT=prctile(ptrData(ii,j),100*nP/sum(~isnan(ptnData(ii,j))));
							else
								auxT=max(ptrData(ii,j));
							end
                        end
                        wetObs=find(ptnData(ii,j)>=threshold & ~isnan(ptnData(ii,j)));
                        wetPrd=find(ptrData(ii,j)>=auxT & ~isnan(ptrData(ii,j)));
                        Beta{i,c,j,1}=[threshold NaN];Beta{i,c,j,2}=[auxT NaN];
                        if auxT>0
                            if ~isempty(wetObs) & ~isempty(wetPrd)
                                if isempty(pct)
                                    pctObs=unique(ptnData(ii(wetObs),j));
                                    pctPrd=unique(ptrData(ii(wetPrd),j));
                                else
                                    pctObs=prctile(ptnData(ii(wetObs),j),pct);
                                    pctPrd=prctile(ptrData(ii(wetPrd),j),pct);
                                end
								if size(pctObs,1)>1, pctObs=pctObs'; end
								if size(pctPrd,1)>1, pctPrd=pctPrd'; end
                                NSim=100;
                                if length(pctObs)>1
                                    NSim=hist(ptnData(ii(wetObs),j),pctObs);NSim=100*cumsum(NSim)/sum(NSim);
                                end
								[aux, Ia, Ib]=unique(pctObs);
								auxObs=[pctObs(Ia);NSim(Ia)]'; clear aux Ia Ib
                                %auxObs=[pctObs(:) NSim(:)];
                                auxObs=auxObs([find(diff(auxObs(:,2))>eps);size(auxObs,1)],:);Beta{i,c,j,1}=[auxObs;threshold NaN];
                                NSim=100;
                                if length(pctPrd)>1
                                    NSim=hist(ptrData(ii(wetPrd),j),pctPrd);NSim=100*cumsum(NSim)/sum(NSim);
                                end
								[aux, Ia, Ib]=unique(pctPrd);
								auxPrd=[pctPrd(Ia);NSim(Ia)]'; clear aux Ia Ib
                                %auxPrd=[pctPrd(:) NSim(:)];
                                auxPrd=auxPrd([find(diff(auxPrd(:,2))>eps);size(auxPrd,1)],:);Beta{i,c,j,2}=[auxPrd;auxT NaN];
                            end
                        end
					else
						indsTrainWObs=find(~isnan(ptnData(ii,j)));
						indsTrainWPrd=find(~isnan(ptrData(ii,j)));
						if ~isempty(indsTrainWObs) & ~isempty(indsTrainWPrd)
							if isempty(pct)
								pctObs=unique(ptnData(ii(indsTrainWObs),j));
								pctPrd=unique(ptrData(ii(indsTrainWPrd),j));
							else
								pctObs=prctile(ptnData(ii(indsTrainWObs),j),pct);
								pctPrd=prctile(ptrData(ii(indsTrainWPrd),j),pct);
							end
							if size(pctObs,1)>1, pctObs=pctObs'; end
							if size(pctPrd,1)>1, pctPrd=pctPrd'; end
							NSim=100;
							if length(pctObs)>1
								NSim=hist(ptnData(ii(indsTrainWObs),j),pctObs);NSim=100*cumsum(NSim)/sum(NSim);
							end
							[aux, Ia, Ib]=unique(pctObs);
							auxObs=[pctObs(Ia);NSim(Ia)]'; clear aux Ia Ib
							%auxObs=[pctObs(:) NSim(:)];
							auxObs=auxObs([find(diff(auxObs(:,2))>eps);size(auxObs,1)],:);Beta{i,c,j,1}=[auxObs;threshold NaN];
							NSim=100;
							if length(pctPrd)>1
								NSim=hist(ptrData(ii(indsTrainWPrd),j),pctPrd);NSim=100*cumsum(NSim)/sum(NSim);
							end
							[aux, Ia, Ib]=unique(pctPrd);
							auxPrd=[pctPrd(Ia);NSim(Ia)]'; clear aux Ia Ib
							%auxPrd=[pctPrd(:) NSim(:)];
							auxPrd=auxPrd([find(diff(auxPrd(:,2))>eps);size(auxPrd,1)],:);Beta{i,c,j,2}=[auxPrd;threshold NaN];
                        end
					end
				end
			end
		end
	end
end
MODEL = Beta;

% if clustering.NumberCenters==1
% 	Beta=cell(length(window),1);
% 	for i=1:length(window)
% 		indsTrainW=intersect(window{i},indsTrain);
% 		aux=repmat(NaN,length(pct)+1,Nest);aux(end,:)=threshold;
% 		for j=1:Nest
% 			if variable==1
% 				nP=nansum(double(ptnData(indsTrainW,j)<threshold & ~isnan(ptnData(indsTrainW,j))));
% 				if nP<length(indsTrainW)
% 					aux(end,j)=prctile(ptrData(indsTrainW,j),100*nP/sum(~isnan(ptnData(indsTrainW,j))));
% 				else
% 					aux(end,j)=max(ptrData(indsTrainW,j));
% 				end
% 				if freqCorr==1,% 2013 Renate et al. Multivariable_error_correction_of_RCMs
% 					if aux(end,j)<=threshold
% 						indWet=find(ptrData(indsTrainW,j)>=threshold & ~isnan(ptrData(indsTrainW,j)));
% 						if ~isempty(indWet)
% 							[paramEsts]=gamfit(ptrData(indsTrainW(indWet),j));% [Shape parameter  Scale parameter]
% 						else
% 							nP1=nansum(double(ptrData(indsTrainW,j)<aux(end,j) & ~isnan(ptrData(indsTrainW,j))));
% 							aux1=prctile(ptnData(indsTrainW,j),100*nP1/sum(~isnan(ptrData(indsTrainW,j))));
% 							[paramEsts]=gamfit(ptnData(indsTrainW(intersect(find(ptnData(indsTrainW,j)>=threshold & ptnData(indsTrainW,j)<aux1),find(~isnan(ptnData(indsTrainW,j))))),j));% [Shape parameter  Scale parameter]
% 						end
% 						indWet=intersect(find(ptrData(indsTrainW,j)>aux(end,j) & ptrData(indsTrainW,j)<threshold),find(~isnan(ptrData(indsTrainW,j))));
% 						if ~isempty(indWet)
% 							ptrData(indsTrainW(indWet),j)=gamrnd(paramEsts(1),paramEsts(2),[length(indWet) 1]);
% 							if ~isempty(find(isinf(ptrData(indsTrainW,j)))),ptrData(indsTrainW(find(isinf(ptrData(indsTrainW,j)))),j)=threshold;end,
% 						end
% 					end
% 					if nP<length(indsTrainW)
% 						aux(end,j)=prctile(ptrData(indsTrainW,j),100*nP/sum(~isnan(ptnData(indsTrainW,j))));
% 					else
% 						aux(end,j)=max(ptrData(indsTrainW,j));
% 					end
% 				end
% 				wetObs=find(ptnData(indsTrainW,j)>=threshold & ~isnan(ptnData(indsTrainW,j)));
% 				wetPrd=find(ptrData(indsTrainW,j)>=aux(end,j) & ~isnan(ptrData(indsTrainW,j)));
% 				if ~isempty(wetObs) & ~isempty(wetPrd)
% 					pctObs=prctile(ptnData(indsTrainW(wetObs),j),pct);
% 					pctPrd=prctile(ptrData(indsTrainW(wetPrd),j),pct);
% 					aux(1:length(pct),j)=pctObs-pctPrd;
% 				end
% 			else
% 				pctObs=prctile(ptnData(indsTrainW,j),pct);
% 				pctPrd=prctile(ptrData(indsTrainW,j),pct);
% 				aux(1:length(pct),j)=pctObs-pctPrd;
% 			end
% 		end
% 		Beta{i}=aux;
% 	end
% else
% 	Beta=cell(length(window),prod(clustering.NumberCenters));
% 	for i=1:length(window)
% 		indsTrainW=intersect(window{i},indsTrain);
% 		for c=1:prod(clustering.NumberCenters)
% 			if prod(clustering.NumberCenters)>1,disp(sprintf('   ...cluster %d de %d',c,prod(clustering.NumberCenters))),end
% 			ii = find(Xcluster==c);
% 			ii = intersect(ii,indsTrainW);
% 			if ~isempty(ii)
% 				aux=repmat(NaN,length(pct)+1,Nest);aux(end,:)=threshold;
% 				for j=1:Nest
% 					if variable==1
% 						nP=nansum(double(ptnData(ii,j)<threshold & ~isnan(ptnData(ii,j))));
% 						if nP<length(ii)
% 							aux(end,j)=prctile(ptrData(ii,j),100*nP/sum(~isnan(ptnData(ii,j))));
% 						else
% 							aux(end,j)=max(ptrData(ii,j));
% 						end
% 						if freqCorr==1,% 2013 Renate et al. Multivariable_error_correction_of_RCMs
% 							if aux(end,j)<=threshold
% 								indWet=find(ptrData(ii,j)>=threshold & ~isnan(ptrData(ii,j)));
% 								if ~isempty(indWet)
% 									[paramEsts]=gamfit(ptrData(ii(indWet),j));% [Shape parameter  Scale parameter]
% 								else
% 									nP1=nansum(double(ptrData(ii,j)<aux(end,j) & ~isnan(ptrData(ii,j))));
% 									aux1=prctile(ptnData(ii,j),100*nP1/sum(~isnan(ptrData(ii,j))));
% 									[paramEsts]=gamfit(ptnData(ii(intersect(find(ptnData(ii,j)>=threshold & ptnData(ii,j)<aux1),find(~isnan(ptnData(ii,j))))),j));% [Shape parameter  Scale parameter]
% 								end
% 								indWet=intersect(find(ptrData(ii,j)>aux(end,j) & ptrData(ii,j)<threshold),find(~isnan(ptrData(ii,j))));
% 								if ~isempty(indWet)
% 									ptrData(ii(indWet),j)=gamrnd(paramEsts(1),paramEsts(2),[length(indWet) 1]);
% 									if ~isempty(find(isinf(ptrData(ii,j)))),ptrData(ii(find(isinf(ptrData(ii,j)))),j)=threshold;end,
% 								end
% 							end
% 							if nP<length(ii)
% 								aux(end,j)=prctile(ptrData(ii,j),100*nP/sum(~isnan(ptnData(ii,j))));
% 							else
% 								aux(end,j)=max(ptrData(ii,j));
% 							end
% 						end
% 						wetObs=find(ptnData(ii,j)>=threshold & ~isnan(ptnData(ii,j)));
% 						wetPrd=find(ptrData(ii,j)>=aux(end,j) & ~isnan(ptrData(ii,j)));
% 						if ~isempty(wetObs) & ~isempty(wetPrd)
% 							pctObs=prctile(ptnData(ii(wetObs),j),pct);
% 							pctPrd=prctile(ptrData(ii(wetPrd),j),pct);
% 							aux(1:length(pct),j)=pctObs-pctPrd;
% 						end
% 					else
% 						pctObs=prctile(ptnData(ii,j),pct);
% 						pctPrd=prctile(ptrData(ii,j),pct);
% 						aux(1:length(pct),j)=pctObs-pctPrd;
% 					end
% 				end
% 				Beta{i,c}=aux;
% 			end
% 		end
% 	end
% end
% MODEL = Beta;
