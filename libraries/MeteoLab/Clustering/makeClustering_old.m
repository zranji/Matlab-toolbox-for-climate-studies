function Clustering=makeClustering(Data,Type,NumberCenters,varargin)
%Clustering=makeClustering(Data,Type,N)
%	Make clustering from DATA. TYPE can be 'kmeans' or 'som'. 
%	If TYPE='som' you will indicate a 2D-SOM making N=[NX NY],
%	If TYPE='kmeans' you will indicate the number of centers with N.
%	The function return a structure with the next fields:
%
%	Clustering.NumberCenters: Number of Centers of the Clustering
%	Clustering.Type: Type of Clustering ('kmeans' or 'som')
%	Clustering.Centers: Centers or Prototypes of the Clustering
%	Clustering.PatternsGroup: Cluster that belongs each pattern in Data (by rows)
%	Clustering.PatternDistanceGroupCenter: Distance of each pattern to the center of the cluster
%	Clustering.SizeGroup: Size of each cluster
%	Clustering.Group: Patterns from DATA that belongs to each cluster.
%
%  AIMet Group, 2003 Santander



if strcmpi(Type,'som')
   type='SOM';
   disp('Training SOM...')
   Clustering.NumberCenters=NumberCenters;
	Clustering.Type=type;
   ncenters=prod(Clustering.NumberCenters);

   %Option 1. Autonomous script
   %som_2d;
   
   %Option 2. SOM Toolbox http://www.cis.hut.fi/projects/somtoolbox/
   shape = 'sheet';
   if nargin==4  shape = varargin{1};end
   sMap = som_make(Data,'msize', NumberCenters,'neigh','ep','lattice','rect','training',[10,100],'shape',shape); 
   Clustering.Centers=sMap.codebook;  
end

if strcmpi(Type,'kmeans')
   type='KMeans';
   Clustering.NumberCenters=prod(NumberCenters);
	Clustering.Type=type;
   
   ncenters=Clustering.NumberCenters;
   
   disp('Training k-Means...')
   [c,Clustering.Centers]=kmeans(Data,Clustering.NumberCenters);
end

[Clustering.PatternsGroup,Clustering.PatternDistanceGroupCenter]=MLknn(Data,Clustering.Centers,1,'Norm-2');

%keyboard

for k=1:ncenters
   iC=find(Clustering.PatternsGroup(:,1)==k);
   Clustering.SizeGroup{k,1}=length(iC);
   if(~isempty(iC))
      Clustering.Group{k,1}=iC(:)';
      %disCenters(k,1:nClases(k))=Dist(iC(:),1)';
   else
      Clustering.Group{k,1}=[];
   end
end


%fechas=datevec(datenum(1979,1,1)+(1:size(CP,1))-1);
%ClstDate(:,[1 3 4])=fechas(:,1:3);
%ClstDate(find(fechas(:,2)==12 | fechas(:,2)==1 | fechas(:,2)==2),2)=1;
%ClstDate(find(fechas(:,2)==3 | fechas(:,2)==4 | fechas(:,2)==5),2)=2;
%ClstDate(find(fechas(:,2)==6 | fechas(:,2)==7 | fechas(:,2)==8),2)=3;
%ClstDate(find(fechas(:,2)==9 | fechas(:,2)==10 | fechas(:,2)==11),2)=4;
