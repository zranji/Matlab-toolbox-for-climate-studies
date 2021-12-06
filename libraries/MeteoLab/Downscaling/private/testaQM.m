function Ypred=testaQM(ptrData,ptnData,indsTrain,indsTest,method,model,XDataCluster)

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
threshold=0;freqCorr=0;
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
end
Ypred=ptrData(indsTest,:);
if isempty(XDataCluster)
	for i=1:size(window,1)
		[indsTestW,I1,I2]=intersect(window{i,1},indsTest);
		[indsTrainW,J1,J2]=intersect(window{i,1},indsTrain);
		deltaMean=nanmean(ptrData(indsTestW,:))-nanmean(ptrData(indsTrainW,:));
		for j=1:Nest
			delta=ptrData(indsTestW,j);N=100;
			auxSim=repmat(NaN,size(delta));
			if variable==1
				if freqCorr==1,% 2013 Renate et al. Multivariable_error_correction_of_RCMs
					if model.MODEL.coefs{i}(end,j)<=threshold
						indWet=find(ptrData(indsTestW,j)>=threshold & ~isnan(ptrData(indsTestW,j)));
						if ~isempty(indWet)
							[paramEsts]=gamfit(ptrData(indsTestW(indWet),j));% [Shape parameter  Scale parameter]
							indWet=intersect(find(ptrData(indsTestW,j)>model.MODEL.coefs{i}(end,j) & ptrData(indsTestW,j)<threshold),find(~isnan(ptrData(indsTestW,j))));
							if ~isempty(indWet)
								ptrData(indsTestW(indWet),j)=gamrnd(paramEsts(1),paramEsts(2),[length(indWet) 1]);
							end
							if ~isempty(find(isinf(ptrData(indsTestW,j)))),ptrData(indsTestW(find(isinf(ptrData(indsTestW,j)))),j)=threshold;end,
						end
					end
				end
				drySim=find(ptrData(indsTestW,j)<model.MODEL.coefs{i}(end,j) & ~isnan(ptrData(indsTestW,j)));delta(drySim)=0;
				wetSim=find(ptrData(indsTestW,j)>=model.MODEL.coefs{i}(end,j) & ~isnan(ptrData(indsTestW,j)));
				if ~isempty(wetSim)
					[Faux,FI,FJ]=unique(delta(~isnan(delta)));
					if length(Faux)>1
						N=hist(delta(~isnan(delta)),Faux);N=100*cumsum(N)/sum(N);
					end
					auxQ=N(FJ);
					ptrData(indsTrainW(ptrData(indsTrainW,j)<model.MODEL.coefs{i}(end,j)),j)=0; 
					delta=delta-prctile(ptrData(intersect(indsTrainW,find(~isnan(ptrData(indsTrainW,j)))),j),auxQ)';
					auxSim=prctile(model.MODEL.obs(J2,j),auxQ)'+model.MODEL.coefs{i}(2,j)*deltaMean(j)+model.MODEL.coefs{i}(1,j)*(delta-deltaMean(j));
				end
			else
				[Faux,FI,FJ]=unique(delta(~isnan(delta)));
				if length(Faux)>1
					N=hist(delta(~isnan(delta)),Faux);N=100*cumsum(N)/sum(N);
				end
				auxQ=N(FJ);
				delta(~isnan(delta))=delta(~isnan(delta))-prctile(ptrData(indsTrainW,j),auxQ)';
				auxSim=prctile(model.MODEL.obs(J2,j),auxQ)'+model.MODEL.coefs{i}(2,j)*deltaMean(j)+model.MODEL.coefs{i}(1,j)*(delta-deltaMean(j));
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
				deltaMean=nanmean(ptrData(ii,:))-nanmean(ptrData(jj,:));
				for j=1:Nest
					delta=ptrData(ii,j);N=100;
					auxSim=repmat(NaN,size(delta));
					if variable==1
						if freqCorr==1,% 2013 Renate et al. Multivariable_error_correction_of_RCMs
							if model.MODEL.coefs{i,c}(end,j)<=threshold
								indWet=find(ptrData(ii,j)>=threshold & ~isnan(ptrData(ii,j)));
								if ~isempty(indWet)
									[paramEsts]=gamfit(ptrData(ii(indWet),j));% [Shape parameter  Scale parameter]
									indWet=intersect(find(ptrData(ii,j)>model.MODEL.coefs{i,c}(end,j) & ptrData(ii,j)<threshold),find(~isnan(ptrData(ii,j))));
									if ~isempty(indWet)
										ptrData(ii(indWet),j)=gamrnd(paramEsts(1),paramEsts(2),[length(indWet) 1]);
									end
									if ~isempty(find(isinf(ptrData(ii,j)))),ptrData(ii(find(isinf(ptrData(ii,j)))),j)=threshold;end,
								end
							end
						end
						drySim=find(ptrData(ii,j)<model.MODEL.coefs{i,c}(end,j) & ~isnan(ptrData(ii,j)));delta(drySim)=0;
						wetSim=find(ptrData(ii,j)>=model.MODEL.coefs{i,c}(end,j) & ~isnan(ptrData(ii,j)));
						if ~isempty(wetSim)
							[Faux,FI,FJ]=unique(delta(~isnan(delta)));
							if length(Faux)>1
								N=hist(delta(~isnan(delta)),Faux);N=100*cumsum(N)/sum(N);
							end
							auxQ=N(FJ);
							ptrData(intersect(jj,find(ptrData(jj,j)<model.MODEL.coefs{i,c}(end,j) & ~isnan(ptrData(jj,j)))),j)=0;
							delta(~isnan(delta))=delta(~isnan(delta))-prctile(ptrData(jj(find(~isnan(ptrData(jj,j)))),j),auxQ)';
							auxSim=prctile(model.MODEL.obs(J2,j),auxQ)'+model.MODEL.coefs{i,c}(2,j)*deltaMean(j)+model.MODEL.coefs{i,c}(1,j)*(delta-deltaMean(j));
						end
						auxSim(drySim)=0;
					else
						[Faux,FI,FJ]=unique(delta(~isnan(delta)));
						if length(Faux)>1
							N=hist(delta(~isnan(delta)),Faux);N=100*cumsum(N)/sum(N);
						end
						auxQ=N(FJ);
						delta(~isnan(delta))=delta(~isnan(delta))-prctile(ptrData(jj,j),auxQ)';
						auxSim=prctile(model.MODEL.obs(J2,j),auxQ)'+model.MODEL.coefs{i,c}(2,j)*deltaMean(j)+model.MODEL.coefs{i,c}(1,j)*(delta-deltaMean(j));
					end
					Ypred(window{i,2},j)=auxSim(find(ismember(dateList(ii,5:8),unique(dateList(indsTest(window{i,2}),5:8),'rows'),'rows')));
				end
			end
		end
	end
end
if variable==1;Ypred(find(Ypred<threshold))=0;end
