dmn=readDomain('Nao');

%Cargamos las CPs para hacer un Agrupamiento de estas
[EOF,CP]=getEOF(dmn,'ncp',50);

%Obtener agrupamiento, con K-medias
%Clustering=makeClustering(CP,'Kmeans',[100]);
Clustering=makeClustering(CP,'SOM',[10 10]);

figure
plot(CP(:,1),CP(:,2),'b.')
hold on
plot(Clustering.Centers(:,1),Clustering.Centers(:,2),...
   'ko',...
   'MarkerSize',6,...
   'MarkerEdgeColor',[0 0 0],...
   'MarkerFaceColor',[1 0 0])

figure; plot(Clustering.PatternsGroup)
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Drawing the prototypes

fields=Clustering.Centers*EOF';
drawGrid(fields,dmn);
