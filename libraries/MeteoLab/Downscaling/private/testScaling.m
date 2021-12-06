function Ypred=testScaling(ptrData,ptnData,indsTrain,indsTest,method,model,XDataCluster)

disp('Applying model...');

clustering = [];
clustering.NumberCenters = 1;
Xcluster = ones(size(ptrData,1),1);
[prdType,ncps,nnns] = getPredictorType(method);

[days,I1,I2]=unique(model.obsMeta.dailyList(:,5:8),'rows');
window={[1:size(ptrData,1)]',[1:length(indsTest)]'};
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
		[indsTestW,I1,I2]=intersect(window{i},indsTest);
		ptrMean=nanmean(ptrData(indsTestW,:));
		ptnMean=nanmean(ptnData(indsTestW,:));
		switch lower(method.properties.CorrectionFunction)
			case 'additive',
				Ypred(intersect(I2,window{i,2}),:)=Ypred(intersect(I2,window{i,2}),:)+repmat(model.MODEL{i},length(intersect(I2,window{i,2})),1);
			case 'multiplicative',
				Ypred(intersect(I2,window{i,2}),:)=Ypred(intersect(I2,window{i,2}),:).*repmat(model.MODEL{i},length(intersect(I2,window{i,2})),1);
			case 'logarithmic',
				Ypred(intersect(I2,window{i,2}),:)=Ypred(intersect(I2,window{i,2}),:).^repmat(model.MODEL{i},length(intersect(I2,window{i,2})),1);
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
		indsTestW=intersect(window{i},indsTest);
		for c=1:prod(clustering.NumberCenters)
			if prod(clustering.NumberCenters)>1,disp(sprintf('   ...cluster %d de %d',c,prod(clustering.NumberCenters))),end
			ii = find(Xcluster==c);
			[ii,I1,I2]=intersect(ii,indsTestW);
			if ~isempty(ii)
				switch lower(method.properties.CorrectionFunction)
					case 'additive',
						Ypred(intersect(I2,window{i,2}),:)=Ypred(intersect(I2,window{i,2}),:)+repmat(model.MODEL{i}(c,:),length(intersect(I2,window{i,2})),1);
					case 'multiplicative',
						Ypred(intersect(I2,window{i,2}),:)=Ypred(intersect(I2,window{i,2}),:).*repmat(model.MODEL{i}(c,:),length(intersect(I2,window{i,2})),1);
					case 'logarithmic',
						Ypred(intersect(I2,window{i,2}),:)=Ypred(intersect(I2,window{i,2}),:).^repmat(model.MODEL{i}(c,:),length(intersect(I2,window{i,2})),1);
				end
			end
		end
	end
end
