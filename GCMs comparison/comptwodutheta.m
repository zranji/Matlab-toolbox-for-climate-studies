% comptwodutheta plot the spatial accuracy metrics for each GCM 
% applicable for wind speeds and direction

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
% 2D plot of accuracy metrics of GCMs

clc
clear
close all

cd('ncfiles')
nc=dir('*.nc');
obs='Reanalysis.nc';
lon=ncread(obs,'lon');
lat=ncread(obs,'lat');
[X,Y]=meshgrid(lon,lat);
vars1=ncread(obs,'uas');%read the reference data
vars2=ncread(obs,'vas');%read the reference data
[varsu,varsth]=cart2pol(vars1,vars2);%conversion of u/v to mag/theta
varsth=mod(varsth,2*pi());
varsth=rad2deg(varsth);
varsth=mod((270-varsth),360);
plotn=1;
for i=1:size(nc,1)
    fldtmo=ncinfo(nc(i).name);
    a=char(fldtmo.Variables.Name);
    if all(~contains(a,'uas'))
        continue;
    end
    varsm1=ncread(nc(i).name,'uas');%read the GCM data
    varsm2=ncread(nc(i).name,'vas');%read the GCM data
    [varsmu,varsmth]=cart2pol(varsm1,varsm2);%conversion of u/v to mag/theta
    varsmth=mod(varsmth,2*pi());
    varsmth=rad2deg(varsmth);
    varsmth=mod((270-varsmth),360);
    cd ../shapefies
    S=shaperead('AS.shp');
    cd ../ncfiles
    Lon=repmat(lon,size(lat));
    Lat=repmat(lat,size(lon));
    [in,on]=inpolygon(Lon,Lat,S.X',S.Y');%points inside the specified ploygone by shapefile
    CC=[Lon(in),Lat(in)];
    for x=1:size(lon)
        for y=1:size(lat)
            CCC=[lon(x) lat(y)];
            if ismember(CCC,CC,'rows')
               statisticsu(:,:,x,y,i)= allstats_modified(squeeze(varsu(x,y,:)),squeeze(varsmu(x,y,:)));
               statisticsth(:,:,x,y,i)= allstatstheta_modified(squeeze(varsth(x,y,:)),squeeze(varsmth(x,y,:)));
            else
               statisticsu(:,:,x,y,i)= NaN([7 2]);
               statisticsth(:,:,x,y,i)= NaN([7 2]);
            end
       end
    end
    %ploting bias indices for GCMs
    subaxis(double(int64(size(nc,1)/3))+1,3,plotn,'SpacingVert',0.02,'SpacingHoriz',0.02)
    h=pcolor(X'-0.5,Y'-0.5,squeeze(statisticsu(7,2,:,:,i))); %bias for u
    %h=pcolor(X'-0.5,Y'-0.5,squeeze(statisticsth(7,2,:,:,i))); %bias for theta
    % h=pcolor(X'-0.5,Y'-0.5,squeeze(statistics(3,2,:,:,i))); %rmsd for u
    % h=pcolor(X'-0.5,Y'-0.5,squeeze(statistics(4,2,:,:,i))); %corr for u
    colormap(jet(20))
    set(h,'edgecolor','none')
    mapshow(S,'Color','k');
    str=split(nc(i).name,'.nc');
    title(str(2));
    plotn=plotn+1;
end