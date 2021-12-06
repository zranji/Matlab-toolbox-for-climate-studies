function Ypred = analogsTest(X,Y,indsTrain,indsTest,method,model,XDataCluster)

[prdType,ncps,nnns] = getPredictorType(method);

if ncps==0
    ncps=-1;
end

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

[Ypred] = downscalingAnalogs([model.MODEL.X(:,1:ncps);X(:,1:ncps)],[model.MODEL.Y;Y],...
             model.MODEL.indsTrain,size(model.MODEL.X,1)+indsTest,...
             'numan',str2double(method.properties.AnalogueNumber),...
             'method',method.properties.InferenceMethod);
