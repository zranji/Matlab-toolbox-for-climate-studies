function struct=atmosphericMoisture(struct,varargin)
% Functions related to the thermodynamics of atmospheric moisture
% Copyright (C) 2002, Jon Saenz, Jesus Fernandez and Juan Zubillaga
% 
% This function is a version for MeteoLab of the program with the 
% same name of the pyclimate software developed by J. Saen, J. Fernandez 
% and J.Zubillaga
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation, version 2.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
%
% Jon Saenz, 2002

% Example
% clear all
% cd('C:/Work/Work/MeteoLab/'),init
% Ejemplo huss hurs:
% ex.Network={'//oceano/gmeteo/WORK/DATA/ObservationsData/DMI/KNMI_ERA40/CTL/'};
% ex.Variable={'huss'};
% [huss,network]=loadObservations(ex,'boundingbox',[-10 34;5 44],'dates',{'01-Jan-1990','31-Dec-1990'},'netcdf',1);
% ex.Variable={'hurs'};
% [hurs,network]=loadObservations(ex,'boundingbox',[-10 34;5 44],'dates',{'01-Jan-1990','31-Dec-1990'},'netcdf',1);
% ex.Variable={'ps'};
% [ps,network]=loadObservations(ex,'boundingbox',[-10 34;5 44],'dates',{'01-Jan-1990','31-Dec-1990'},'netcdf',1);
% ex.Variable={'tas'};
% [tas,network]=loadObservations(ex,'boundingbox',[-10 34;5 44],'dates',{'01-Jan-1990','31-Dec-1990'},'netcdf',1);
% ex.Variable={'tdps'};
% [tdps,network]=loadObservations(ex,'boundingbox',[-10 34;5 44],'dates',{'01-Jan-1990','31-Dec-1990'},'netcdf',1);
% Si pasamos las variables que queremos no hace nada:
% struct=atmosphericMoisture([],'names',{'hurs';'huss'},'huss',huss,'hurs',hurs);

% struct=atmosphericMoisture([],'names',{'hurs'},'huss',huss,'tas',tas,'ps',ps);
% struct1=atmosphericMoisture([],'names',{'hurs'},'tdps',tdps,'tas',tas,'ps',ps);

% Some constants:
Rv=461;% J/(K kg)
Rd=287.058;% dry air constant J/(K kg)
T0=273.15;% K
es0=611;% Pa
epsilon=Rd/Rv; % adimensional
GammaST=0.0065;% (dT/dz)^st standard atmosphere vertical gradient of the temperature in the troposphere (0.0065 (K/m^-1))

nombres=[];
tas=[];ps=[];hurs=[];huss=[];tdps=[];dpds=[];
existence=[0 0 0 0 0 0];
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'names', nombres=varargin{i+1};
        case 'tas', tas=varargin{i+1};existence(1)=1;
        case 'ps', ps=varargin{i+1};existence(2)=1;
        case 'hurs', hurs=varargin{i+1};existence(3)=1;
        case 'huss', huss=varargin{i+1};existence(4)=1;
        case 'tdps', tdps=varargin{i+1};existence(5)=1;
        case 'dpds', dpds=varargin{i+1};existence(6)=1;
        otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
    end
end

for i=1:length(nombres)
	disp(nombres{i})
	switch lower(nombres{i}),
		case {'hurs';'hur';'r'},nombre='hur';
			if existence(3)==1
				Z=hurs;
			elseif sum(existence([1 2 4]))==3
				ws=tas2ws(ps,tas);
				w=huss./(1-huss);% W es el mixing ratio
				Z=100*w./ws;
			elseif (sum(existence([1 2 5]))==3) & (sum(existence([1 2 5 6]))==3)
				Z=dpds2hurs(tas-tdps,tas,ps);
			elseif sum(existence([1 2 6]))==3
				Z=dpds2hurs(dpds,tas,ps);
			elseif sum(existence([1 5]))==2
				Z=tdps2hurs(tdps,tas);
			end
		case {'huss';'hus';'q'},nombre='hus';
			if existence(4)==1
				Z=huss;
			elseif sum(existence([1 2 3]))==3
				Z=hurs2huss(hurs,ps,tas);
			end
		case {'pvp'},nombre='pvp';
			if sum(existence([4 2]))==2
				Z=huss2pvp(huss,ps);
			elseif sum(existence([1 2 3]))==3
				huss=hurs2huss(hurs,ps,tas);
				Z=huss2pvp(huss,ps);
			end
		case {'ws'},nombre='ws';
			if sum(existence([1 2]))==2
				Z=tas2ws(ps,tas);
			elseif sum(existence([1 2 3]))==3
				Z=hurs2w(hurs,ps,tas);
			end
		case {'w'},nombre='w';
			if existence(4)==1
				Z=huss./(1-huss);
			elseif sum(existence([1 2 3]))==3
				[ws,Z]=hurs2w(hurs,ps,tas);
			end
			
    end
	struct=setfield(struct,nombre,Z);
end

function ws=tas2ws(ps,tas)
% Saturation pressure (Pa) from temperature
% Consider the cases over water and ice, according to the temperature involved.
% Do not consider subcooled water at all.
Rv=461.5;Rd=287.058;% J/(K kg)
T0=273.15;% K
es0=611;% Pa
es=repmat(NaN,size(tas));
% Saturation pressure (Pa) over ice
% See Bohren, Albrecht (2000), pages 197-200
iceMask=find(tas<T0);es(iceMask)=es0*exp((6293/T0)-(6293./tas(iceMask))-0.555*log(abs(tas(iceMask)/T0)));
% Saturation pressure (Pa) over water
% See Bohren, Albrecht (2000), pages 197-200
waterMask=find(tas>=T0);es(waterMask)=es0*exp((6808/T0)-(6808./tas(waterMask))-5.09*log(abs(tas(waterMask)/T0)));
% WS(tas,pas) es el saturation mixing ratio
% Saturation mixing ratio from temperature and pressure
% See Wallace and Hobbs
% 'ps' -- Presure (Pa)
% 'tas' -- Temperature (K)
ws=(Rd/Rv)*(es./(ps-es));

function [ws,w]=hurs2w(hurs,ps,tas)
% Get the mixing ratio from the relative humidity
% 'hur' -- Relative humidity (%)
% 'ps' -- Pressure (Pa)
% 'tas' -- Temperature (K)
ws=tas2ws(ps,tas);
w=ws.*hurs/100;

function huss=hurs2huss(hurs,ps,tas)
% Get the specific humidity from the relative humidity
% 'hur' -- Relative humidity (%)
% 'ps' -- Pressure (Pa)
% 'tas' -- Temperature (K)
[ws,w]=hurs2w(hurs,ps,tas);huss=w./(1+w);

function hurs=dpds2hurs(dpds,tas,ps)
% Get the relative humidity from the dew-point depression
% 'dpds' -- Dew point depression (K)
% 'ps' -- Pressure (Pa)
% 'tas' -- Temperature (K)
tdps=tas-dpds;
hurs=100*tas2ws(ps,tdps)./tas2ws(ps,tas);

function hurs=tdps2hurs(tdps,tas)
% Get the relative humidity from the dew-point depression
% 'tdps' -- Dew point depression (K)
% 'tas' -- Temperature (K)
lv=2.5*10^6;Rv=461.5;
hurs=100*exp((lv/Rv)*((1./tas)-(1./tdps)));

function pvp=huss2pvp(huss,ps)
% Get the partial vapour pressure from specific humidity
% 'huss' -- Specific humidity
% 'ps' -- Pressure (Pa)
Rv=461.5;Rd=287.058;% J/(K kg)
epsilon=Rd/Rv; % adimensional
pvp=(huss.*ps)./(epsilon*(1-huss)+huss);

%% Pressure reduction formula: https://www.wmo.int/pages/prog/www/IMOP/meetings/SI/ET-Stand-1/Doc-10_Pressure-red.pdf
function ps=mslp2ps(mslp,tas,zs)
Rd=287.058;% dry air constant J/(K kg)
GammaST=0.0065;% (dT/dz)^st standard atmosphere vertical gradient of the temperature in the troposphere (0.0065 (K/m^-1))
g=9.80665;% (m/s^2) gravitational aceleration
ps=mslp;ind=find(abs(zs)>=0.001);auxGamma=repmat(NaN,size(ps));
To=tas+GammaST*zs/g;
ind1=intersect(find(To>290.5 & tas<=290.5),ind);auxGamma(ind1)=g*(290.5-tas(ind1))./zs(ind1);ind=setdiff(ind,ind1);
ind1=intersect(find(To>290.5 & tas>290.5),ind);auxGamma(ind1)=0;tas(ind1)=0.5*(255+tas(ind1));ind=setdiff(ind,ind1);
ind1=intersect(find(tas<255),ind);auxGamma(ind1)=GammaST;tas(ind1)=0.5*(255+tas(ind1));ind=setdiff(ind,ind1);
auxGamma(ind)=GammaST;ind=find(abs(zs)>=0.001);
ps(ind)=mslp(ind).*exp((-zs(ind)./(Rd*tas(ind))).*(1-0.5*(auxGamma(ind).*zs(ind))./(g*tas(ind))+(1/3)*((auxGamma(ind).*zs(ind))./(g*tas(ind))).^2));

function mslp=ps2mslp(ps,tas,zs)
Rd=287.058;% dry air constant J/(K kg)
GammaST=0.0065;% (dT/dz)^st standard atmosphere vertical gradient of the temperature in the troposphere (0.0065 (K/m^-1))
g=9.80665;% (m/s^2) gravitational aceleration
mslp=ps;ind=find(abs(zs)>=0.001);auxGamma=repmat(NaN,size(ps));
To=tas+GammaST*zs/g;
ind1=intersect(find(To>290.5 & tas<=290.5),ind);auxGamma(ind1)=g*(290.5-tas(ind1))./zs(ind1);ind=setdiff(ind,ind1);
ind1=intersect(find(To>290.5 & tas>290.5),ind);auxGamma(ind1)=0;tas(ind1)=0.5*(255+tas(ind1));ind=setdiff(ind,ind1);
ind1=intersect(find(tas<255),ind);auxGamma(ind1)=GammaST;tas(ind1)=0.5*(255+tas(ind1));ind=setdiff(ind,ind1);
auxGamma(ind)=GammaST;ind=find(abs(zs)>=0.001);
mslp(ind)=ps(ind).*exp((zs(ind)./(Rd*tas(ind))).*(1-0.5*(auxGamma(ind).*zs(ind))./(g*tas(ind))+(1/3)*((auxGamma(ind).*zs(ind))./(g*tas(ind))).^2));

%% Ejemplo con Interim:
% 129,Z,0,1,,
% 151,SLP,0,1,,
% 167,2T,0,1,,
% 134,PS,0,1,,
% clear all,fclose all;
% cd('C:/Work/MLToolbox/MeteoLab/'),init
% import ucar.nc2.dt.grid.*
% import ucar.nc2.dt.grid.GridDataset.*
% origFile='//oceano/gmeteo/DATA/ECMWF/INTERIM/EuroAfrica075/';
% ctl=[origFile 'url.txt'];tableFileName=[origFile 'Table.txt'];
% nameFile=[origFile '1996/INTERIM075_199601_SFC_167.128.grb'];
% dataset=GridDataset.open(deblank(nameFile));nc=getNetcdfDataset(dataset);
% lon=nc.findVariable('lon');lon=lon.read;lon=squeeze(copyToNDJavaArray(lon));
% lat=nc.findVariable('lat');lat=lat.read;lat=squeeze(copyToNDJavaArray(lat));
% [lon,lat]=meshgrid(lon,lat);
% lon(lon>180)=lon(lon>180)-360;
% [lon,ilon2]=sort(lon,2);ilon2=unique(ilon2,'rows');
% grid=[lon(:) lat(:)];Ngrid=size(grid,1);close(dataset);clear lon lat nc dataset
% varNames={'Geopotential_isobaric';'Surface_pressure_surface';'Mean_sea_level_pressure_surface';'2_metre_temperature_surface'};
% dmn.nod=grid';dmn.par={'Z',1000,0,0;'PS',0,0,0;'SLP',0,0,0;'2T',0,0,0};dmn.startDate='01-Jan-1996';dmn.endDate='31-Jan-1996';dmn.step='24:00';
% dates=datevec([datenum(dmn.startDate):datenum(dmn.endDate)]');ndata=size(dates,1);
% for i=1:length(varNames)
	% dmn1=dmn;dmn1.par=dmn.par(i,:);[pattern,dmn1]=loadGCM(dmn1,ctl,'dates',dates);
	% struct(i).data=pattern;clear dmn1 pattern
% end
% cd([origFile '1996/']);delete('*.gbx8');delete('*.gbx9');delete('*.ncx'); 

% function ps=mslp2ps(mslp,tas,zs)
% zs=struct(1).data;mslp=struct(3).data;tas=struct(4).data;
% Rd=287.058;% dry air constant J/(K kg)
% GammaST=0.0065;% (dT/dz)^st standard atmosphere vertical gradient of the temperature in the troposphere (0.0065 (K/m^-1))
% g=9.80665;% (m/s^2) gravitational aceleration
% ps=mslp;ind=find(abs(zs)>=0.001);auxGamma=repmat(GammaST,size(ps));
% To=tas+GammaST*zs/g;
% ind1=intersect(find(To>290.5 & tas<=290.5),ind);auxGamma(ind1)=g*(290.5-tas(ind1))./zs(ind1);ind=setdiff(ind,ind1);
% ind1=intersect(find(To>290.5 & tas>290.5),ind);auxGamma(ind1)=0;tas(ind1)=0.5*(255+tas(ind1));ind=setdiff(ind,ind1);
% ind1=intersect(find(tas<255),ind);auxGamma(ind1)=GammaST;tas(ind1)=0.5*(255+tas(ind1));ind=setdiff(ind,ind1);
% auxGamma(ind)=GammaST;ind=find(abs(zs)>=0.001);
% ps(ind)=mslp(ind).*exp((-zs(ind)./(Rd*tas(ind))).*(1-0.5*(auxGamma(ind).*zs(ind))./(g*tas(ind))+(1/3)*((auxGamma(ind).*zs(ind))./(g*tas(ind))).^2));
% figure,drawStations(grid,'color',struct(2).data(1,:)','israster','true','size',0.375,'resolution','high'),colorbar,clim=get(gca,'clim');
% figure,drawStations(grid,'color',ps(1,:)','israster','true','size',0.375,'resolution','high'),colorbar%,set(gca,'clim',clim)
% clear mslp tas zs

% function mslp=ps2mslp(ps,tas,zs)
% zs=struct(1).data;ps=struct(2).data;tas=struct(4).data;
% Rd=287.058;% dry air constant J/(K kg)
% GammaST=0.0065;% (dT/dz)^st standard atmosphere vertical gradient of the temperature in the troposphere (0.0065 (K/m^-1))
% g=9.80665;% (m/s^2) gravitational aceleration
% mslp=ps;ind=find(abs(zs)>=0.001);auxGamma=repmat(NaN,size(ps));
% To=tas+GammaST*zs/g;
% ind1=intersect(find(To>290.5 & tas<=290.5),ind);auxGamma(ind1)=g*(290.5-tas(ind1))./zs(ind1);ind=setdiff(ind,ind1);
% ind1=intersect(find(To>290.5 & tas>290.5),ind);auxGamma(ind1)=0;tas(ind1)=0.5*(255+tas(ind1));ind=setdiff(ind,ind1);
% ind1=intersect(find(tas<255),ind);auxGamma(ind1)=GammaST;tas(ind1)=0.5*(255+tas(ind1));ind=setdiff(ind,ind1);
% auxGamma(ind)=GammaST;ind=find(abs(zs)>=0.001);
% mslp(ind)=ps(ind).*exp((zs(ind)./(Rd*tas(ind))).*(1-0.5*(auxGamma(ind).*zs(ind))./(g*tas(ind))+(1/3)*((auxGamma(ind).*zs(ind))./(g*tas(ind))).^2));
% figure,drawStations(grid,'color',struct(3).data(1,:)','israster','true','size',0.375,'resolution','high'),colorbar,clim=get(gca,'clim');
% figure,drawStations(grid,'color',mslp(1,:)','israster','true','size',0.375,'resolution','high'),colorbar%,set(gca,'clim',clim)

% clear all,fclose all;
% cd('C:/Work/MLToolbox/MeteoLab/'),init
% import ucar.nc2.dt.grid.*
% import ucar.nc2.dt.grid.GridDataset.*
% nameFile='C:/Work/Work/MeteoLab/MLToolbox_R2008a/ObservationsData/ESCENA/UCAN_WRA_EC5R2/20C3M/data/UCAN_WRA_CTL_ERAIN_FIX_orog.nc';
% dataset=GridDataset.open(deblank(nameFile));nc=getNetcdfDataset(dataset);
% lon=nc.findVariable('lon');lon=lon.read;lon=double(squeeze(copyToNDJavaArray(lon)));
% lat=nc.findVariable('lat');lat=lat.read;lat=double(squeeze(copyToNDJavaArray(lat)));
% alt=nc.findVariable('orog');alt=alt.read;alt=double(squeeze(copyToNDJavaArray(alt)));
% grid=[lon(:) lat(:)];Ngrid=size(grid,1);close(dataset);clear lon lat alt nc dataset
% ex.Network={'C:/Work/Work/MeteoLab/MLToolbox_R2008a/ObservationsData/ESCENA/UCAN_WRA_EC5R2/20C3M/'};
% ex.Variable={'ps'};[ps,network]=loadObservations(ex,'boundingBox',[-10 34;5 44],'dates',{'01-Jan-1991';'31-Jan-1991'});ind=find(~isnan(network.Info.Height));ps=ps(:,ind);
% ex.Variable={'psl'};[mslp,network]=loadObservations(ex,'boundingBox',[-10 34;5 44],'dates',{'01-Jan-1991';'31-Jan-1991'});ind=find(~isnan(network.Info.Height));mslp=mslp(:,ind);
% ex.Variable={'tas'};[tas,network]=loadObservations(ex,'boundingBox',[-10 34;5 44],'dates',{'01-Jan-1991';'31-Jan-1991'});ind=find(~isnan(network.Info.Height));tas=tas(:,ind);
% Rd=287.058;% dry air constant J/(K kg)
% GammaST=0.0065;% (dT/dz)^st standard atmosphere vertical gradient of the temperature in the troposphere (0.0065 (K/m^-1))
% g=9.80665;% (m/s^2) gravitational aceleration
% zs=repmat(network.Info.Height(ind)',size(tas,1),1)*g;location=network.Info.Location(ind,:);
% ps1=mslp;ind=find(abs(zs)>=0.001);auxGamma=repmat(GammaST,size(ps1));
% To=tas+GammaST*zs/g;
% ind1=intersect(find(To>290.5 & tas<=290.5),ind);auxGamma(ind1)=g*(290.5-tas(ind1))./zs(ind1);ind=setdiff(ind,ind1);
% ind1=intersect(find(To>290.5 & tas>290.5),ind);auxGamma(ind1)=0;tas(ind1)=0.5*(255+tas(ind1));ind=setdiff(ind,ind1);
% ind1=intersect(find(tas<255),ind);auxGamma(ind1)=GammaST;tas(ind1)=0.5*(255+tas(ind1));ind=setdiff(ind,ind1);
% auxGamma(ind)=GammaST;ind=find(abs(zs)>=0.001);
% ps1(ind)=mslp(ind).*exp((-zs(ind)./(Rd*tas(ind))).*(1-0.5*(auxGamma(ind).*zs(ind))./(g*tas(ind))+(1/3)*((auxGamma(ind).*zs(ind))./(g*tas(ind))).^2));
% figure(1),subplot(2,2,1),drawStations(location,'color',ps(1,:)','israster','true','size',0.1,'resolution','high'),set(gca,'clim',[min([ps(1,:) ps1(1,:)]') max([ps(1,:) ps1(1,:)]')]),colorbar,
% figure(1),subplot(2,2,3),drawStations(location,'color',ps1(1,:)','israster','true','size',0.1,'resolution','high'),set(gca,'clim',[min([ps(1,:) ps1(1,:)]') max([ps(1,:) ps1(1,:)]')]),colorbar,
% figure(1),subplot(2,2,2),drawStations(location,'color',nanmean(ps)','israster','true','size',0.1,'resolution','high'),set(gca,'clim',[min([nanmean(ps) nanmean(ps1)]') max([nanmean(ps) nanmean(ps1)]')]),colorbar,
% figure(1),subplot(2,2,4),drawStations(location,'color',nanmean(ps1)','israster','true','size',0.1,'resolution','high'),set(gca,'clim',[min([nanmean(ps) nanmean(ps1)]') max([nanmean(ps) nanmean(ps1)]')]),colorbar,
% figure(2),subplot(2,2,1),plot(sqrt(nanmean((ps-ps1).^2,2))'),
% figure(2),subplot(2,2,2),plot(sqrt(nanmean((ps-ps1).^2,1))'),
% figure(2),subplot(2,2,3),plot(nanmean((ps-ps1),2)),
% figure(2),subplot(2,2,4),plot(nanmean((ps-ps1),1)),
% figure,drawStations(location,'color',sqrt(nanmean((ps-ps1).^2))','israster','true','size',0.1,'resolution','high','colormap',flipud(hot)),set(gca,'clim',[0 600]),colorbar
% figure,drawStations(location,'color',nanmean(ps-ps1)','israster','true','size',0.1,'resolution','high','colormap',flipud(hot)),set(gca,'clim',[0 600]),colorbar
% clear mslp tas zs

% function mslp=ps2mslp(ps,tas,zs)
% mslp1=ps;ind=find(abs(zs)>=0.001);auxGamma=repmat(NaN,size(ps));
% To=tas+GammaST*zs/g;
% ind1=intersect(find(To>290.5 & tas<=290.5),ind);auxGamma(ind1)=g*(290.5-tas(ind1))./zs(ind1);ind=setdiff(ind,ind1);
% ind1=intersect(find(To>290.5 & tas>290.5),ind);auxGamma(ind1)=0;tas(ind1)=0.5*(255+tas(ind1));ind=setdiff(ind,ind1);
% ind1=intersect(find(tas<255),ind);auxGamma(ind1)=GammaST;tas(ind1)=0.5*(255+tas(ind1));ind=setdiff(ind,ind1);
% auxGamma(ind)=GammaST;ind=find(abs(zs)>=0.001);
% mslp1(ind)=ps(ind).*exp((zs(ind)./(Rd*tas(ind))).*(1-0.5*(auxGamma(ind).*zs(ind))./(g*tas(ind))+(1/3)*((auxGamma(ind).*zs(ind))./(g*tas(ind))).^2));
% figure(1),subplot(2,2,1),drawStations(location,'color',mslp(1,:)','israster','true','size',0.1,'resolution','high'),set(gca,'clim',[min([mslp(1,:) mslp1(1,:)]') max([mslp(1,:) mslp1(1,:)]')]),colorbar,
% figure(1),subplot(2,2,3),drawStations(location,'color',mslp1(1,:)','israster','true','size',0.1,'resolution','high'),set(gca,'clim',[min([mslp(1,:) mslp1(1,:)]') max([mslp(1,:) mslp1(1,:)]')]),colorbar,
% figure(1),subplot(2,2,2),drawStations(location,'color',nanmean(mslp)','israster','true','size',0.1,'resolution','high'),set(gca,'clim',[min([nanmean(mslp) nanmean(mslp1)]') max([nanmean(mslp) nanmean(mslp1)]')]),colorbar,
% figure(1),subplot(2,2,4),drawStations(location,'color',nanmean(mslp1)','israster','true','size',0.1,'resolution','high'),set(gca,'clim',[min([nanmean(mslp) nanmean(mslp1)]') max([nanmean(mslp) nanmean(mslp1)]')]),colorbar,
% figure(2),subplot(2,2,1),plot(sqrt(nanmean((mslp-mslp1).^2,2))'),
% figure(2),subplot(2,2,2),plot(sqrt(nanmean((mslp-mslp1).^2,1))'),
% figure(2),subplot(2,2,3),plot(nanmean((mslp-mslp1),2)),
% figure(2),subplot(2,2,4),plot(nanmean((mslp-mslp1),1)),
% figure,drawStations(location,'color',sqrt(nanmean((mslp-mslp1).^2))','israster','true','size',0.1,'resolution','high','colormap',flipud(hot)),set(gca,'clim',[0 600]),colorbar
% figure,drawStations(location,'color',nanmean(mslp-mslp1)','israster','true','size',0.1,'resolution','high','colormap',hot),set(gca,'clim',[-600 0]),colorbar
