function Ypred = linearTest(X,Y,indsTrain,indsTest,method,model,XDataCluster)

disp('Applying model...');

clustering = [];
clustering.NumberCenters = 1;
Xcluster = ones(size(X,1),1);

% feature selection backward compatibility
Feats = {};resStats = [];
if isfield(model.MODEL,'Stats')
	resStats = model.MODEL.Stats;
end
if isfield(model.MODEL,'Feats')
	Feats = model.MODEL.Feats;
end
if (isfield(model.MODEL,'Feats') | isfield(model.MODEL,'Stats'))
	model.MODEL = model.MODEL.Model;
end

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

if strcmp(prdType,'PC')
	X = X(:,1:ncps);
	Ypred = NaN*zeros(length(indsTest),size(model.MODEL,3));
	for c=1:prod(clustering.NumberCenters)
		ii0 = find(Xcluster==c);
		[ii,i1,i2] = intersect(ii0,indsTest);
		if isempty(Feats)        
			f = squeeze(model.MODEL(c,:,:));
			if((size(X,2)+1)~=size(f,1))
				f = f';
			end
			Ypred(i2,:) = [ones(size(X(ii,:),1),1), X(ii,:)]*f;
		else
			for k=1:size(Y,2)
				f = squeeze(model.MODEL(c,:,k));
				if((length(Feats{c,k})+1)~=size(f,1))
					f = f';
				end
				Ypred(i2,k) = [ones(size(X(ii,:),1),1), X(ii,Feats{c,k})]*f;
			 end
		end
	end
else
	Ypred = NaN*zeros(length(indsTest),size(Y,2));
	for c=1:prod(clustering.NumberCenters)
		if prod(clustering.NumberCenters)>1,disp(sprintf('   ...cluster %d de %d',c,prod(clustering.NumberCenters))),end
		ii0 = find(Xcluster==c);
		[ii,i1,i2] = intersect(ii0,indsTest);            
		for k=1:size(Y,2)
			vecinos = MLknn(model.obsMeta.Info.Location(k,:),model.dmn.nod',nnns,'Norm-2');
			indsVecinos = [1:ncps];
			for i=1:size(model.dmn.par,1)
				indsVecinos = [indsVecinos (ncps+vecinos+(i-1)*size(model.dmn.nod,2))];
			end
			indNN=setdiff(indsVecinos,[1:ncps]);
			nnAverage=[];
            colsAve=[];
			if nnAve
				nnAverage=repmat(NaN,length(ii),size(model.dmn.par,1));
				for i=1:size(model.dmn.par,1)
					ind=findVarPosition(model.dmn.par{i,1},model.dmn.par{i,3},model.dmn.par{i,2},model.dmn);
					indNN_var=intersect(indNN,ind+ncps);
					nnAverage(:,i)=nanmean(X(ii,indNN_var),2);
					clear ind indNN_var
				end
				colsAve=[1:size(nnAverage,2)];
				indsVecinos=[1:ncps];
			end
			if ~isempty(Feats)
				if nnAve
					indsVecinos=Feats{c,k}(Feats{c,k}<=ncps);
					colsAve=Feats{c,k}(Feats{c,k}>ncps)-ncps;
				else
					indsVecinos = Feats{c,k};					
				end
			end
			XX = [ones(size(X(ii,:),1),1), X(ii,indsVecinos), nnAverage(:,colsAve)];
			f = squeeze(model.MODEL(c,:,k)');
			if(size(XX,2)~=size(f,1))
				f = f';
			end
			Ypred(i2,k) = XX*f;
		end
	end
end
if (isfield(method.properties,'Simulation') & strcmp(method.properties.Simulation,'true'))
	Ypred = Ypred+randn(size(Ypred)).*repmat(resStats(2,:),size(Ypred,1),1); 
end

