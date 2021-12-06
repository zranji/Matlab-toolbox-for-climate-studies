dmn=readDomain('Nao');
[EOF,CP]=getEOF(dmn,'ncp',100);

%Obtener analogos usando K-vecinos
[AnalogPat,Neig,NeigDist]=getAnalogous(CP(1,:),CP,50,'knn',[]);

%Obtener analogos usando agrupamiento, con K-medias
Clustering=makeClustering(CP,'Kmeans',[50]);
hist(cat(2,Clustering.SizeGroup{:}));
[AnalogPat,Neig,NeigDist]= getAnalogous(CP(1,:),CP,1,'Kmeans',Clustering);

%Obtener analogos usando agrupamiento, con SOM
Clustering=makeClustering(CP,'SOM',[10 10]);
[AnalogPat,Neig,NeigDist]= getAnalogous(CP(1,:),CP,1,'SOM',Clustering);

