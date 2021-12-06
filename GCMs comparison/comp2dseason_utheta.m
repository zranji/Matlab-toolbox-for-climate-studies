% comp2dseason plot the spatial variables mean for each GCM 
% applicable for wind speeds

% INPUTS:
%	shape file that specifies the polygone of the domain. So that all
%	compuatation is performed inside the polygone (for oceanic purposes).
%	The file is specified in shapefiles folder.
%	
%   Refrence data as a netcdf file naming 'REANALYSIS.nc' in ncs directory 
%
%   GCM datasets in netcdf format in ncs directory (all netcdf files must be
%   regridded into a similar grid. We used remapbic command of CDO package, for this purpose)

% OUTPUTS:
% 2D plot of spatial variables mean for each GCM 


clc
clear
close all

cd('ncfiles')
nc=dir('*.nc');
obs='REANALYSIS.nc';
lon=ncread(obs,'lon');
lat=ncread(obs,'lat');
[X,Y]=meshgrid(lon,lat);
vars1=ncread(obs,'uas');%read the reference data
vars2=ncread(obs,'vas');%read the reference data
[thetao,mago]=cart2pol(vars1,vars2);%conversion of u/v to mag/theta
thetao=mod(thetao,2*pi());
thetao=rad2deg(thetao);
thetao=mod((270-thetao),360);
plotn=1;
for i=1:size(nc,1)
    fldtmo=ncinfo(nc(i).name);
    a=char(fldtmo.Variables.Name);
    if all(~contains(a,'uas'))
        continue;
    end
    varsm1=ncread(nc(i).name,'uas');%read the GCM data
    varsm2=ncread(nc(i).name,'vas');%read the GCM data
    [thetam,magm]=cart2pol(varsm1,varsm2);%conversion of u/v to mag/theta
    thetam=mod(thetam,2*pi());
    thetam=rad2deg(thetam);
    thetam=mod((270-thetam),360);
    cd ../shapefies
    S=shaperead('AS.shp');
    cd ../ncfiles
    Lon=repmat(lon,size(lat));
    Lat=repmat(lat,size(lon));
    [in,on]=inpolygon(Lon,Lat,S.X',S.Y');
    % plot(Lon(in),Lat(in),'r+')
    CC=[Lon(in),Lat(in)];
    for x=1:size(lon)
        for y=1:size(lat)
            CCC=[lon(x) lat(y)];
            if ismember(CCC,CC,'rows')
               mvars(x,y,:,:)=reshape(squeeze(mago(x,y,:))',12,[]); % create 128years array
               %mvars(x,y,:,:)=reshape(squeeze(thetao(x,y,:))',12,[]); %for theta
               spring(x,y)=mean(mean(mvars(x,y,5:6,:))); % 5:6 can be edited for the other seasons
               mvarsm(x,y,:,:)=reshape(squeeze(magm(x,y,:))',12,[]);
               %mvarsm(x,y,:,:)=reshape(squeeze(thetam(x,y,:))',12,[]); %for theta
               springm(x,y)=mean(mean(mvarsm(x,y,5:6,:)));
            else
               springm(x,y)= NaN;
            end
        end
     end
%ploting spatial mean of variables for GCMs
subaxis(double(int64(size(nc,1)/3))+1,3,plotn,'SpacingVert',0.02,'SpacingHoriz',0.02)
h=pcolor(X'-0.5,Y'-0.5,springm);
colormap(jet(20))
set(h,'edgecolor','none')
mapshow(S,'Color','k');
str=split(nc(i).name,'.nc');
title(str(2));
plotn=plotn+1;  
end