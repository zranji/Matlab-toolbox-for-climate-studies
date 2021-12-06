function MODEL = quantileTrain(X,Y,indsTrain,indsTest,method,model,XDataCluster)

disp('Training model...');

quantile=95;variable=0;
threshold=0;dist='binomial';link='logit';
if isfield(method.properties,'Quantile')
	if isnumeric(method.properties.Quantile)
		quantile=method.properties.Quantile;
	else
		quantile=str2num(method.properties.Quantile);
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
if isfield(method.properties,'ThresholdPrecip')
	if ~isempty(method.properties.ThresholdPrecip)
		if isnumeric(method.properties.ThresholdPrecip)
			threshold=method.properties.ThresholdPrecip;
		else
			threshold=str2num(method.properties.ThresholdPrecip);
		end
	elseif variable==1
		method.properties.ThresholdPrecip=0;threshold=0;
	end
elseif variable==1
	method.properties.ThresholdPrecip=0;
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
    Beta = NaN*zeros(clustering.NumberCenters,size(X,2)+1,size(Y,2));
	for c=1:clustering.NumberCenters
        if clustering.NumberCenters>1,disp(sprintf('   ...%d de %d',c,clustering.NumberCenters)),end
        ii = find(Xcluster==c);
        ii = intersect(ii,indsTrain);
        for ss=1:size(Y,2)
            inonan = find(~isnan(Y(:,ss)));
            iinew = intersect(ii,inonan);
			if variable==1 % Metodo de quantile regression censurado de Friederichs and Hense (2007)
				% 1) Calculo probabilidades con el GLM
				% Regresion logistica para la ocurrencia
				[b,dum,stats] = glmfit(X(iinew,:),Y(iinew,ss) >= threshold,dist,link);
				P = glmval(stats.beta,X(iinew,:),link,stats);% glmval introduce directamente una columna de unos en X para el intercepto.
				indNaNX=find(sum(isnan(X(iinew,:)),2)>0);
				P(indNaNX)=NaN;% La funcion glmval asigna un 0 a los dias con NaNs en el predictor
				% 2) Con esas probabilidades hago una submuestra de días con P>1-tau y aplico QR
				ind1= find(P>(1-quantile/100));
				p1=quantreg([ones(length(ind1),1) X(iinew(ind1),:)],Y(iinew(ind1),ss),quantile/100);
				% los coeficientes obtenidos se aplican a toda la serie
				betaX = [ones(length(iinew),1), X(iinew,:)]*p1; 
				% 3) Con los positivos se hace otra submuestra para ajustar los beta definitivos que aplico a toda la serie 
				ind2=find(betaX>0);
				Beta(c,:,ss)=quantreg([ones(length(ind2),1) X(iinew(ind2),:)],Y(iinew(ind2),ss),quantile/100);
			else
				Beta(c,:,ss) = quantreg([ones(length(iinew),1) X(iinew,:)],Y(iinew,ss),quantile/100);
			end
		end
    end
    MODEL = Beta;
else
    Beta = NaN*zeros(clustering.NumberCenters,ncps+nnns*size(model.dmn.par,1)+1,size(Y,2));
    for c=1:clustering.NumberCenters
        if clustering.NumberCenters>1,disp(sprintf('   ...cluster %d de %d',c,clustering.NumberCenters)),end
        ii = find(Xcluster==c);
        ii = intersect(ii,indsTrain);
        for k=1:size(Y,2)
            if mod(k,100)==0
                disp(sprintf('       ...%d de %d',k,size(Y,2)));
            end
            inonan = find(~isnan(Y(:,k)));
            iinew = intersect(ii,inonan);                    
            vecinos = MLknn(model.obsMeta.Info.Location(k,:),model.dmn.nod',nnns,'Norm-2');
            indsVecinos = [1:ncps];
            for i=1:size(model.dmn.par,1)
                indsVecinos = [indsVecinos (ncpsOffset+vecinos+(i-1)*size(model.dmn.nod,2))];
            end
			if variable==1
				% 1) Calculo probabilidades con el GLM
				% Regresion logistica para la ocurrencia
				[b,dum,stats] = glmfit(X(iinew,indsVecinos),Y(iinew,k) >= threshold,dist,link);
				P = glmval(stats.beta,X(iinew,indsVecinos),link,stats);% glmval introduce directamente una columna de unos en X para el intercepto.
				indNaNX=find(sum(isnan(X(iinew,indsVecinos)),2)>0);
				P(indNaNX)=NaN;% La funcion glmval asigna un 0 a los dias con NaNs en el predictor
				% 2) Con esas probabilidades hago una submuestra de días con P>1-tau y aplico QR
				ind1= find(P>(1-quantile/100));
				p1=quantreg([ones(length(ind1),1) X(iinew(ind1),indsVecinos)],Y(iinew(ind1),k),quantile/100);
				% los coeficientes obtenidos se aplican a toda la serie
				betaX = [ones(length(iinew),1), X(iinew,indsVecinos)]*p1; 
				% 3) Con los positivos se hace otra submuestra para ajustar los beta definitivos que aplico a toda la serie 
				ind2=find(betaX>0);
				Beta(c,:,k)=quantreg([ones(length(ind2),1) X(iinew(ind2),indsVecinos)],Y(iinew(ind2),k),quantile/100);
			else
				Beta(c,:,k) = quantreg([ones(length(iinew),1) X(iinew,indsVecinos)],Y(iinew,k),quantile/100);
			end
        end
    end
    MODEL = Beta;
end
