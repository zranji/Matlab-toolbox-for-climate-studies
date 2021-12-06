%%%%%%%%%%%%%%%%%
% GSN World
GSN.Network={'\\oceano.macc.unican.es\gmeteo\METEOLAB_PUBLIC\ObservationsData\GSN_World'};    
GSN.Stations={'Iberia.stn'};
GSN.Variable={'Tmax'};
period={'1-Jan-1970','31-Dec-1999'};
[datY,GSN]=loadStations(GSN,'dates',period,'aggregation','Y','missing',0.1);
[datYMax,GSN]=loadStations(GSN,'dates',period,'aggregation','Y','function','nanmax','missing',0.1);

%%%%%%%%%%%%%%%%%
% CRU TS21 
% The data is defined with a Step='M' (see Variables.txt in the corresponding directory)
CRU.Network={'\\oceano.macc.unican.es\gmeteo\METEOLAB_PUBLIC\ObservationsData\CRUTS21'};  
CRU.Variable={'Tmax'};
[data,CRU]=loadStations(CRU,'ID',{'272401','272402'},'dates',{'1-Dec-1970','30-Nov-1999'});

%%%%%%%%%%%%%%%%%
% ENSEMBLES 0.5
ENS.Network={'\\oceano.macc.unican.es\gmeteo\METEOLAB_PUBLIC\ObservationsData\ENSEMBLES\Grid0.50_regular'};    
ENS.Stations={'Countries\ESPANA.stn'};
ENS.Variable={'Tmax'};
period={'1-Jan-1970','31-Dec-1999'};
[dat,ENS]=loadStations(ENS,'dates',period,'aggregation','Y','function','nanmax','missing',0.01);
dat=nanmean(dat); loc=ENS.Info.Location;  % Drawing mean temperature
drawStationsValue(dat,loc,'marker','t','size',0.5,'colorbar','true');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% PRIVATE 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%
% AEMET
SP.Network={'Y:\METEOLAB\ObservationsData\INM\Estaciones'};    
SP.Stations={'homogeneasTx.stn'};
SP.Variable={'Tx'};
period={'1-Jan-1970','31-Dec-1999'};
[dat,SP]=loadStations(SP,'dates',period,'aggregation','Y');
dat=nanmean(dat); loc=SP.Info.Location;  % Drawing mean temperature
drawStationsValue(dat,loc,'marker','t','size',0.2,'colorbar','true');

