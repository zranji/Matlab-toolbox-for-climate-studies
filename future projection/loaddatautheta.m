% loaddata plot the spatial variation of signals for GCMs ensemble  
% applicable for wind speeds and directions

% INPUTS:
%	shape file that specifies the polygone of the domain. So that all
%	compuatation is performed inside the polygone (for oceanic purposes).
%	The file is specified in shapefiles folder.
%	
%   Signals of GCM ensembles in netcdf format in future/signals directory (all netcdf files must be
%   regridded into a similar grid. We used remapbic command of CDO package, for this purpose)

% There are also series of cdo commands, provided as examples, to extract GCMs signals:
% cdo seltimestep,901/1140 RCP45.nc RCP45_far.nc     to extract mid/far future time slice
% cdo splitmon RCP45_far.nc mon  to extrcat specific months
% cdo runavg,20 m5_RCP45_far.nc rcp5_RCP45_far.nc  to average over the time slice
% cdo ensmean rcp5_RCP45_far.nc rcp6_RCP45_far.nc rcp_RCP45_far.nc  to average seasonally on from extracted months
% ncdiff out_rcp_RCP45_far.nc out_his_his.nc sig45_far.nc to extract the signals by substracting historical mean from future mean
% cdo ensmean -apply,-selname,zg,ua,va,ta [ cnrm.nc mpi-mr.nc canesm.nc mpi-lr.nc csiro.nc cmcc.nc ] ENS.nc to average over different (top-ranked) GCMs
% OUTPUTS:
% 2D plot of signals variations for an ensemble of GCMs

clc
clear 
close all

cd('future/signals')
% read and reorder the signal files
files=dir('ENS_autumn_*.nc');
file(1:2,:)=files(3:4,:);
file(3:4,:)=files(1:2,:);
var='uas';
var2='vas';
pp=0;
for nc=1:size(file,1)
        pp=pp+1;
        xs=ncread(file(nc).name,'lon');
        ys=ncread(file(nc).name,'lat');
        [X,Y]=meshgrid(xs,ys);
        us=ncread(file(nc).name,var); 
        vs=ncread(file(nc).name,var2);
        [varsth,vars]=cart2pol(us,vs);%conversion of u/v to mag/theta
        varsth=mod(varsth,2*pi());
        varsth=rad2deg(varsth);
        varsth=mod((270-varsth),360);
        cd ../../shapefies
        S=shaperead('AS.shp');
        cd ../future/signals
        Lon=repmat(xs,size(ys));
        Lat=repmat(ys,size(xs));
        [in,on]=inpolygon(Lon,Lat,S.X',S.Y');%points inside the specified ploygone by shapefile
        CC=[Lon(in),Lat(in)];
        for i=1:size(xs,1)
            for j=1:size(ys,1)
                CCC=[xs(i) ys(j)];
                if ismember(CCC,CC,'rows')
                   mvars(i,j)=vars(i,j); %% create 128years array
                   mvarsth(i,j)=varsth(i,j);
               else
                   mvars(i,j)=NaN;
                   mvarsth(i,j)=NaN;
                end
            end
        end
        %plot the signals
        subaxis(2,4,pp,'SpacingVert',0.08,'SpacingHoriz',0.08)
        h=pcolor(X'-0.5,Y'-0.5,mvars); %speeds signals
        colormap(jet(20))
        caxis([0 15])  
        set(h,'edgecolor','none')
        mapshow(S,'Color','k');
        xlim([48 76])
        ylim([8.5 31])

        subaxis(2,4,pp+4,'SpacingVert',0.08,'SpacingHoriz',0.08)
        h2=pcolor(X'-0.5,Y'-0.5,mvarsth);%direction signals
        colormap(jet(20))
        caxis([40 120]) 
        set(h2,'edgecolor','none')
        mapshow(S,'Color','k');
        xlim([48 76])
        ylim([8.5 31])
end
