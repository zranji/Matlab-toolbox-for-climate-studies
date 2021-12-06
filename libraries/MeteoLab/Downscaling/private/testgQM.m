function Ypred=testgQM(ptrData,ptnData,indsTrain,indsTest,method,model,XDataCluster)

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

[prdType,ncps,nnns] = getPredictorType(method);
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
threshold=0;variable=1;freqCorr=0;
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
			method.properties.threshold=0;threshold=0;
		end
	elseif variable==1
		method.properties.threshold=0;threshold=0;
	end
end

Ypred=ptrData(indsTest,:);
if clustering.NumberCenters==1
	for i=1:size(window,1)
		[indsTestW,I1,I2]=intersect(window{i,1},indsTest);
		for j=1:Nest
			if variable==1 & freqCorr==1,% 2013 Renate et al. Multivariable_error_correction_of_RCMs
				if model.MODEL{i}(1,j)<=threshold
					indWet=find(ptrData(indsTestW,j)>=threshold & ~isnan(ptrData(indsTestW,j)));
					if ~isempty(indWet)
						[paramEsts]=gamfit(ptrData(indsTestW(indWet),j));% [Shape parameter  Scale parameter]
						indWet=intersect(find(ptrData(indsTestW,j)>model.MODEL{i}(1,j) & ptrData(indsTestW,j)<threshold),find(~isnan(ptrData(indsTestW,j))));
						if ~isempty(indWet)
							ptrData(indsTestW(indWet),j)=gamrnd(paramEsts(1),paramEsts(2),[length(indWet) 1]);
						end
						if ~isempty(find(isinf(ptrData(indsTestW,j)))),ptrData(indsTestW(find(isinf(ptrData(indsTestW,j)))),j)=threshold;end,
					end
				end
			end
			drySim=find(ptrData(indsTestW,j)<model.MODEL{i}(1,j) & ~isnan(ptrData(indsTestW,j)));Ypred(I2(drySim),j)=0;
			wetSim=find(ptrData(indsTestW,j)>=model.MODEL{i}(1,j) & ~isnan(ptrData(indsTestW,j)));
			if (~isempty(wetSim) & sum(isnan(model.MODEL{i}(2:end,j)))==0)
%				Ypred(intersect(window{i,2},I2(wetSim)),j)=gaminv(gamcdf(Ypred(intersect(window{i,2},I2(wetSim)),j),model.MODEL{i}(4,j),model.MODEL{i}(5,j)),model.MODEL{i}(2,j),model.MODEL{i}(3,j));
				Ypred(I2(wetSim),j)=gaminv(gamcdf(Ypred(I2(wetSim),j),model.MODEL{i}(4,j),model.MODEL{i}(5,j)),model.MODEL{i}(2,j),model.MODEL{i}(3,j));
			end
			if ~isempty(find(isinf(Ypred(I2,j)) | Ypred(I2,j)>10^4)), %#ok<*EFIND>
				indInf=find(isinf(Ypred(I2,j)) | Ypred(I2,j)>10^4);
				Ypred(I2(indInf),j)=max(Ypred(setdiff(I2,I2(indInf)),j)); %#ok<*FNDSB>
			end
		end
	end
else
	for i=1:size(window,1)
		[indsTestW,I1,I2]=intersect(window{i},indsTest);
		for c=1:prod(clustering.NumberCenters)
			if prod(clustering.NumberCenters)>1,disp(sprintf('   ...cluster %d de %d',c,prod(clustering.NumberCenters))),end
			ii = find(Xcluster==c);
			[ii,J1,J2] = intersect(ii,indsTestW);
			if ~isempty(ii)
				for j=1:Nest
					if variable==1 & freqCorr==1,% 2013 Renate et al. Multivariable_error_correction_of_RCMs
						if model.MODEL{i}(1,j)<=threshold
							indWet=find(ptrData(ii,j)>=threshold & ~isnan(ptrData(ii,j)));
							if ~isempty(indWet)
								[paramEsts]=gamfit(ptrData(ii(indWet),j));% [Shape parameter  Scale parameter]
								indWet=intersect(find(ptrData(ii,j)>model.MODEL{i}(1,j) & ptrData(ii,j)<threshold),find(~isnan(ptrData(ii,j))));
								if ~isempty(indWet)
									ptrData(ii(indWet),j)=gamrnd(paramEsts(1),paramEsts(2),[length(indWet) 1]);
								end
								if ~isempty(find(isinf(ptrData(ii,j)))),ptrData(ii(find(isinf(ptrData(ii,j)))),j)=threshold;end,
							end
						end
					end
					drySim=find(ptrData(ii,j)<model.MODEL{i}(1,j) & ~isnan(ptrData(ii,j)));Ypred(I2(J2(drySim)),j)=0;
					wetSim=find(ptrData(ii,j)>=model.MODEL{i}(1,j) & ~isnan(ptrData(ii,j)));
					if (~isempty(wetSim) & sum(isnan(model.MODEL{i}(2:end,j)))==0)
%						Ypred(intersect(window{i,2},I2(J2(wetSim))),j)=gaminv(gamcdf(Ypred(intersect(window{i,2},I2(J2(wetSim))),j),model.MODEL{i}(4,j),model.MODEL{i}(5,j)),model.MODEL{i}(2,j),model.MODEL{i}(3,j));
						Ypred(I2(J2(wetSim)),j)=gaminv(gamcdf(Ypred(I2(J2(wetSim)),j),model.MODEL{i}(4,j),model.MODEL{i}(5,j)),model.MODEL{i}(2,j),model.MODEL{i}(3,j));
					end
					if ~isempty(find(isinf(Ypred(I2(J2),j)) | Ypred(I2(J2),j)>10^4)), %#ok<*EFIND>
						indInf=find(isinf(Ypred(I2(J2),j)) | Ypred(I2(J2),j)>10^4);
						Ypred(I2(J2(indInf)),j)=max(Ypred(setdiff(I2,I2(J2(indInf))),j)); %#ok<*FNDSB>
					end
				end
			end
		end
	end
end
