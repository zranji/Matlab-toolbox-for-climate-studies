Cuenca={'Catalana','Norte','Duero','Tajo','Guadiana','Guadalquivir','Sur','Segura','Levante','Ebro','Baleares','Canarias'}
PtndName={'Es','Gr','Ll','Tr','Ro','Nb','Nv','Precip_07_07','Vx','In','Tx','Tn'};
PtndUmb={[000,001,inf],...
      [000,001,inf],...
      [000,001,inf],...
      [000,001,inf]...
      [000,001,inf],...
      [000,001,inf],...
      [000,001,inf],...
      [000,001,020,100,200,inf],...
      [000,050,080,inf],...
      [000,010,030,050,070,inf],...
      [],[]};

Prdc.Type='Prb';
Prdc.Method='Fq';
Prdc.NumA=50;
Prdc.IndEx=[];%solo para hindcasting
Prdc.NEx=15;%solo para hindcasting

for i=2%Cuenca
   cfg.cam=['areaPatterns/Spain/Cuenca' Cuenca{i} '/'];
   cfg.fil='domain.cfg';
   dmn=readDomain([cfg.cam cfg.fil]);
   CP=getEOF(cfg,'NCP',25);
   [AnalogPat,Neig,NeigDist]=getAnalogous(CP(1,:),CP,150,'knn',[]);
   Stations.Zone={'INM'};
   Stations.AreaStation={['completasCuenca' Cuenca{i}]};%fichero .stn con los indicativos
   for j=8%Variable
      Stations.Variable={PtndName{j}};%variable especificada (es un directorio que contiene los ficheros de .stn)
      [data,Stations]=loadStations(Stations);
      indAng=Neig;
      distAng=1./NeigDist;
      Ptnd=data;
      Prdc.Umb=PtndUmb{j};
      P=makePrediction(indAng,distAng,Ptnd,Prdc)
   end
end