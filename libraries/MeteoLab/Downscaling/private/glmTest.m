function Ypred = glmTest(X,Y,indsTrain,indsTest,method,model,XDataCluster)

disp('Applying model...');

clustering = [];
clustering.NumberCenters = 1;
Xcluster = ones(size(X,1),1);

% feature selection backward compatibility
Feats = {};
if isfield(model.MODEL,'Feats')
    Feats = model.MODEL.Feats;
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
if isfield(method.properties,'SimAmount')
    method.properties.SimGLM = method.properties.SimAmount;
end

if strcmp(prdType,'PC')
    X = X(:,1:ncps);
    Ypred = NaN*zeros(length(indsTest),size(Y,2));
    for c=1:prod(clustering.NumberCenters)
        ii0 = find(Xcluster==c);
        [ii,i1,i2] = intersect(ii0,indsTest);
        for k=1:size(Y,2)
            ixCols = [1:size(X,2)];
            if ~isempty(Feats)
                ixCols = Feats{c,k};
            end
            if isfield(method.properties, 'ThresholdProb')
                Ypred(i2,k) = downOccVal(X(ii,ixCols),model.MODEL.occModel{c,k},1:length(ii),'sim',method.properties.SimOccurrence,'threprob',method.properties.ThresholdProb);
            else
                Ypred(i2,k) = downOccVal(X(ii,ixCols),model.MODEL.occModel{c,k},1:length(ii),'sim',method.properties.SimOccurrence);
            end
            if isfield(method.properties, 'PercExtremeCorrection')
                Ypred(i2,k) = Ypred(i2,k).*downGLMVal(X(ii,ixCols),model.MODEL.amoModel{c,k},1:length(ii),'sim',method.properties.SimGLM,'pec',method.properties.PercExtremeCorrection);
            else
                Ypred(i2,k) = Ypred(i2,k).*downGLMVal(X(ii,ixCols),model.MODEL.amoModel{c,k},1:length(ii),'sim',method.properties.SimGLM);
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
            colsAve=[];nnAverage=[];
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
            if isfield(method.properties, 'ThresholdProb')
                Ypred(i2,k) = downOccVal([X(ii,indsVecinos) nnAverage(:,colsAve)],model.MODEL.occModel{c,k},1:length(ii),'sim',method.properties.SimOccurrence,'threprob',method.properties.ThresholdProb);
            else
                Ypred(i2,k) = downOccVal([X(ii,indsVecinos) nnAverage(:,colsAve)],model.MODEL.occModel{c,k},1:length(ii),'sim',method.properties.SimOccurrence);
            end
            if isfield(method.properties, 'PercExtremeCorrection')
                Ypred(i2,k) = Ypred(i2,k).*downGLMVal([X(ii,indsVecinos) nnAverage(:,colsAve)],model.MODEL.amoModel{c,k},1:length(ii),'sim',method.properties.SimGLM,'pec',method.properties.PercExtremeCorrection);
            else
                Ypred(i2,k) = Ypred(i2,k).*downGLMVal([X(ii,indsVecinos) nnAverage(:,colsAve)],model.MODEL.amoModel{c,k},1:length(ii),'sim',method.properties.SimGLM);
            end
        end
    end
end
