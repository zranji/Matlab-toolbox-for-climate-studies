function str = describeFeatureSelector(model)

featSelector = 'none';

if isfield(model.method,'properties')
   if isfield(model.method.properties,'FeatureSelection')
      featSelector = model.method.properties.FeatureSelection;
   end
end

str = {};
if strcmp(featSelector,'none')
   str{1} = 'This method has no feature selector';
else
   ix = 1;
   for s=1:size(model.MODEL.Feats,2)
      str{ix} = sprintf('Features for station #%g (%s)',s,model.obsMeta.Info.Id{s});
      ix = ix+1;
      for c=1:size(model.MODEL.Feats,1)
         padd = '';
         if size(model.MODEL.Feats,1)>1
            str{ix} = sprintf('   for cluster %g',c);
            ix = ix+1;
            padd='   ';
         end
         feats = model.MODEL.Feats{c,s};
         % ordering    
         order = model.MODEL.FeatsOrder{c,s};  
         [type,ncps,nnns] = getPredictorType(model.method);
         ncps2 = 0;
         if isfield(model.method.properties,'FeatureIncremental')
            if strcmp(model.method.properties.FeatureIncremental,'true')
               ncps2 = ncps;
            end
         end
         feats(order>0) = feats(ncps2+order(order>0));
         for f=1:length(feats)
            if feats(f)<=ncps
                str{ix} = sprintf('   %sPrincipal component %g',padd,feats(f));
                ix = ix+1;
            else
                var = floor((feats(f)-ncps)/size(model.dmn.nod,2))+1;
                varStr = sprintf('%s-%g-%g-%g',model.dmn.par{var,:});
                lonlat = model.dmn.nod(:,var*size(model.dmn.nod,2)-(feats(f)-ncps));
                indAng = MLknn(model.obsMeta.Info.Location(s,:),model.dmn.nod',size(model.dmn.nod,2),2);
                [dum,pos] = min(sum(abs(model.dmn.nod'-repmat(lonlat',size(model.dmn.nod,2),1)),2));
                order = find(indAng==pos);
                str{ix} = sprintf('   %sVariable %s at [%.2f,%.2g] (#%g)',padd,varStr,lonlat,order);
                ix = ix+1;
            end
         end
      end
   end
end

if nargout>0
   if length(str)==1
      str = str{1};
   end
   return
else
   for s=1:length(str)
      disp(sprintf('%s',str{s}));
   end
   str = [];
end
