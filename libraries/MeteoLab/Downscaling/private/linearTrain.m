function MODEL = linearTrain(X,Y,indsTrain,indsTest,method,model,XDataCluster)

disp('Training model...');

clustering = [];
clustering.NumberCenters = 1;
Xcluster = ones(size(X,1),1);

[prdType,ncps,nnns] = getPredictorType(method);
if ncps==-1
	if strcmp(prdType,'PC')
		ncps = size(X,2);
	elseif strcmp(prdType,'PCFIELDS')
		ncps = size(X,2)-size(model.dmn.par,1)*size(model.dmn.nod,2);
	else
		ncps = 0;
	end
else
	if strcmp(prdType,'PCFIELDS')
		ncps = min(ncps,size(X,2)-size(model.dmn.par,1)*size(model.dmn.nod,2));
	elseif strcmp(prdType,'PC')
		ncps = min(ncps,size(X,2));
	end
end
nnAve=0;
if isfield(method.properties,'nnAverage')
	if strcmp(method.properties.nnAverage,'true')
		nnAve=1;
	end
end
if isfield(model,'clustering')
	if ~isempty(model.clustering)
		clustering = model.clustering;
		Xcluster = projectClustering(XDataCluster,clustering);
	end
end

featsNum = -1;
featInc = 0;
if isfield(method.properties,'FeatureSelection')
	featMethod = getfield(method.properties,'FeatureSelection');
	if strcmp(featMethod,'lars') | strcmp(featMethod,'lasso')
		featsNum = str2num(getfield(method.properties,'Features'));
		ncols = featsNum;
	elseif ~strcmp(featMethod,'none')
		error(['Invalid feature selection method: ' featMethod]);
	end
	if isfield(method.properties,'FeatureIncremental')
		if strcmp(method.properties.FeatureIncremental,'true')
			featInc = 1;
		end
	end
end
Feats = {}; FeatsOrder = {};
if featsNum>0
    FeatsOrder = cell(prod(clustering.NumberCenters),size(Y,2));
    Feats = cell(prod(clustering.NumberCenters),size(Y,2));
end
resStats=repmat(NaN,[2,size(Y,2)]);
if strcmp(prdType,'PC')
	X = X(:,1:ncps);
	ncols = ncps;
	if featsNum>0
		ncols = featsNum;
	end
	Beta = repmat(NaN,[prod(clustering.NumberCenters),ncols+1,size(Y,2)]);
	for c=1:prod(clustering.NumberCenters)
		if prod(clustering.NumberCenters)>1,disp(sprintf('   ...%d de %d',c,prod(clustering.NumberCenters))),end
		ii = find(Xcluster==c);
		ii = intersect(ii,indsTrain);
		for ss=1:size(Y,2)
			inonan = find(~isnan(Y(:,ss)));
			iinew = intersect(ii,inonan);
			ixCols = [1:size(X,2)];
			if featsNum>0
				cols = lars(X(iinew,:),Y(iinew,ss),featMethod,-featsNum);
				ixCols = find(cols(end,:)~=0);
				FeatsOrder{c,ss} = size(cols,1)-sum(cols(:,ixCols)~=0);
				Feats{c,ss} = ixCols;
			end
			[Beta(c,:,ss), zz, res] = regression(Y(iinew,ss),[ones(length(iinew),1) X(iinew,ixCols)]);
			% % The following line only works for R2013 and later
			% [Beta(c,:,ss), ~, res] = regression(Y(iinew,ss),[ones(length(iinew),1) X(iinew,ixCols)]);
			resStats(:,ss)=[res.mean;res.std];
		end
	end
else
	if nnAve
		ncols = ncps + size(model.dmn.par,1);
	else
		ncols = ncps + nnns*size(model.dmn.par,1);
	end
	if featsNum>0
		if featInc
			if nnAve
				ncols = ncps + min(featsNum,size(model.dmn.par,1));
			else
				ncols = ncps + featsNum;
			end
		else
			ncols = featsNum;
        end
	end
	Beta = repmat(NaN,[prod(clustering.NumberCenters),ncols+1,size(Y,2)]);
	for c=1:prod(clustering.NumberCenters)
		if prod(clustering.NumberCenters)>1,disp(sprintf('   ...cluster %d de %d',c,prod(clustering.NumberCenters))),end
		ii = find(Xcluster==c);
		ii = intersect(ii,indsTrain);
		for k=1:size(Y,2)
			if mod(k,100)==0
				disp(sprintf('       ...%d de %d',k,size(Y,2)));
			end
			inonan = find(~isnan(Y(:,k)));
			iinew = intersect(ii,inonan);
			if(isempty(iinew))
				continue;
			end
			vecinos = MLknn(model.obsMeta.Info.Location(k,:),model.dmn.nod',nnns,'Norm-2');
			indsVecinos = [1:ncps];
			for i=1:size(model.dmn.par,1)
				indsVecinos = [indsVecinos (ncps+vecinos+(i-1)*size(model.dmn.nod,2))];
			end
			indNN=setdiff(indsVecinos,[1:ncps]);
			colsAve=[];nnAverage=[];
			if nnAve
				nnAverage=repmat(NaN,length(iinew),size(model.dmn.par,1));
				for i=1:size(model.dmn.par,1)
					ind=findVarPosition(model.dmn.par{i,1},model.dmn.par{i,3},model.dmn.par{i,2},model.dmn);
					indNN_var=intersect(indNN,ind+ncps);
					nnAverage(:,i)=nanmean(X(iinew,indNN_var),2);
					clear ind indNN_var
				end
				colsAve=[1:size(nnAverage,2)];indsVecinos = [1:ncps];
			end
			if featsNum>0
				if ~featInc
					cols = lars([X(iinew,indsVecinos) nnAverage],Y(iinew,k),featMethod,-featsNum);
				else
					if (ncps==0)
						warning('You are using FeatureIncremental option with no PCs');
					end
					BETA_Y = regression(Y(iinew,k),[ones(length(iinew),1) X(iinew,1:ncps)]);
					RES = Y(iinew,k) - [ones(length(iinew),1) X(iinew,1:ncps)]*BETA_Y;
					cols = lars([X(iinew,setdiff(indsVecinos,[1:ncps])) nnAverage],RES,featMethod,-featsNum);
					cols = [repmat(1:ncps,size(cols,1),1) cols];
				end
				ixCols = find(cols(end,:)~=0);
				FeatsOrder{c,k} = size(cols,1)-sum(cols(:,ixCols)~=0);
				colsAve=ixCols(ixCols>ncps)-ncps;
				indsVecinos = indsVecinos(ixCols(ixCols<=length(indsVecinos)));
				Feats{c,k} = [indsVecinos colsAve+ncps];
			end
			[Beta(c,:,k), zz, res] = regression(Y(iinew,k),[ones(length(iinew),1) X(iinew,indsVecinos) nnAverage(:,colsAve)]);
			resStats(:,k)=[res.mean;res.std];
		end
	end
end

if ~isempty(Feats)
	MODEL.Model = Beta;
	MODEL.Feats = Feats;
	MODEL.FeatsOrder = FeatsOrder;
	MODEL.Stats = resStats;
else
	MODEL.Model = Beta;
	MODEL.Stats = resStats;
end
