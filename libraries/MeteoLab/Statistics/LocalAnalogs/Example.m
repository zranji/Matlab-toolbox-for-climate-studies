dmn=readDomain('Iberia');
Stations.Network={'GSN'};
Stations.Stations={'Spain.stn'};
Stations.Variable={'Precip'};

%Training data
dates={'1-Jan-1960','31-Dec-1998'};
[EOF,CP]=getEOF(dmn,'ncp',50,'dates',dates);
[dataE,Stations]=loadStations(Stations,'dates',dates,'ascfile',1);

%Test data
dates={'1-Jan-1999','31-Dec-1999'};
[EOF,CPT]=getEOF(dmn,'ncp',50,'dates',dates);
[dataT,Stations]=loadStations(Stations,'dates',dates,'ascfile',1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DETERMINISTIC (forecasting with the mean of the analog ensemble)
O=[];P=[];
for j=1:1:180
   [AnalogPat,Neig,NeigDist]=getAnalogous(CPT(j,:),CP,25,'knn',[]);
   O=[O;dataT(j,:)];
   P=[P;nanmean(dataE(Neig,:))];
end
plot([O(:,1),P(:,1)])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PROBABILISTIC (forecasting with the frequency of the event)
umbral=5;
i=find(~isnan(dataE));
dataE(i)=dataE(i)>umbral;
dataT(:)=dataT(:)>umbral;

O=[];P=[];
for j=1:1:180
   [AnalogPat,Neig,NeigDist]=getAnalogous(CPT(j,:),CP,25,'knn',[]);
   O=[O;dataT(j,:)];
   P=[P;nanmean(dataE(Neig,:))];
end
%validation of the probabilistic forecast
makeValidation(O(:,1),P(:,1))

