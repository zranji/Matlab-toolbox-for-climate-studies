function [Neig,NeigDist,AnalogPat]=getAnalogous2(OPRCP,ERACP,NumA,Type,Clustering)
%[Analogous,AnalogousDistance,AnalogousPatterns]=getAnalogous(Pattern,Library,k,Type,Clustering)
%	If TYPE='knn' return the K analogous for the vector PATTERN found in the LIBRARY of patterns.
%	If TYPE='kmeans' or 'som' you must specify a CLUSTERING structure that has been obtained 
%  from MAKECLUSTERING function and will look the K analogous clusters, and return the members 
%	of these clusters.
%
%  AIMet Group, 2003 Santander

if(strcmpi(Type,'KMeans') | strcmpi(Type,'SOM'))
   [Neig,NeigDist] = MLknn(OPRCP,Clustering.Centers,NumA,'Norm-2');
   ind=cat(2,Clustering.Group{Neig});
   if nargout>2
       AnalogPat=ERACP(ind,:);
   end
elseif (strcmpi(Type,'Knn'))
   [Neig,NeigDist] = MLknn(OPRCP,ERACP,NumA,'Norm-2');
   if nargout>2
       AnalogPat=ERACP(Neig,:);
   end
else
   error(['Unknown Type: ' Type]);
end
Neig=Neig';
NeigDist=NeigDist';


