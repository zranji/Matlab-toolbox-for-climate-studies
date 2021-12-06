function Ypred = quantileTest(X,Y,indsTrain,indsTest,method,model,XDataClusterl)

disp('Applying model...');

variable=0;
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
      if ncps>0
         ncps = min(ncps,size(X,2)-size(model.dmn.par,1)*size(model.dmn.nod,2));
      end
   elseif strcmp(prdType,'PC')
      ncps = min(ncps,size(X,2));
   end
end

ncpsOffset = ncps;
if isfield(model,'clustering')
   if ~isempty(model.clustering)
      clustering = model.clustering;
      Xcluster = MLknn(X(:,1:size(clustering.Centers,2)),clustering.Centers,1,'Norm-2');
      if ncps==0
          ncpsOffset = size(clustering.Centers,2);
      end
   end
end

if strcmp(prdType,'PC')
    X = X(:,1:ncps);
    Ypred = NaN*zeros(length(indsTest),size(model.MODEL,3));
    for c=1:clustering.NumberCenters
        ii0 = find(Xcluster==c);
        [ii,i1,i2] = intersect(ii0,indsTest);
        f = squeeze(model.MODEL(c,:,:));
        Ypred(i2,:) = [ones(length(ii),1) X(ii,:)]*f;
		if variable==1 % Metodo de quantile regression censurado de Friederichs and Hense (2007)
			for k=1:size(Y,2)
				ind0=find(Ypred(i2,k)<0);
				Ypred(i2(ind0),k)=0; % hacer cero los negativos
			end
		end
    end
else
    Ypred = NaN*zeros(length(indsTest),size(Y,2));
    for c=1:clustering.NumberCenters
        if clustering.NumberCenters>1,disp(sprintf('   ...cluster %d de %d',c,clustering.NumberCenters)),end
        ii0 = find(Xcluster==c);
        [ii,i1,i2] = intersect(ii0,indsTest);            
        for k=1:size(Y,2)
            vecinos = MLknn(model.obsMeta.Info.Location(k,:),model.dmn.nod',nnns,'Norm-2');
            indsVecinos = [1:ncps];
            for i=1:size(model.dmn.par,1)
                indsVecinos = [indsVecinos (ncpsOffset+vecinos+(i-1)*size(model.dmn.nod,2))];
            end
            f = squeeze(model.MODEL(c,:,k)');
            Ypred(i2,k) = [ones(length(ii),1) X(ii,indsVecinos)]*f;
			if variable==1 % Metodo de quantile regression censurado de Friederichs and Hense (2007)
				ind0=find(Ypred(i2,k)<0);
				Ypred(i2(ind0),k)=0; % hacer cero los negativos
			end
        end
    end
end
