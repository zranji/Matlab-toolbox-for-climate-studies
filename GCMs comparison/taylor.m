% taylor plot the Taylor graph for visual compariosn of GCMs 
% not applicable for wind speeds and wind direction.

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
% 	Tatlor plot of GCMs

clc
clear
close all

cd('ncfiles')
nc=dir('*.nc');
obs='REANALYSIS.nc';
lon=ncread(obs,'lon');
lat=ncread(obs,'lat');
[X,Y]=meshgrid(lon,lat);
VAR={'tas','psl','hurs'};
for n=1:size(VAR,2)
    clear statu vars varsm mvars mvarsm pp tt idx s a
    vars=ncread(obs,VAR{n}); %read the reference data
    for i=1:size(nc,1)
        fldtmo=ncinfo(nc(i).name);
        a=char(fldtmo.Variables.Name);
        if all(~contains(a,VAR{n}))
            continue;
        end
        varsm=ncread(nc(i).name,VAR{n}); %read the GCM data
        cd ../shapefies
        S=shaperead('AS.shp');
        cd ../ncfiles
        Lon=repmat(lon,size(lat));
        Lat=repmat(lat,size(lon));
        [in,on]=inpolygon(Lon,Lat,S.X',S.Y'); %points inside the specified ploygone by shapefile
%       plot(Lon(in),Lat(in),'r+')
        CC=[Lon(in),Lat(in)];
            for x=1:size(lon)
                for y=1:size(lat)
                    CCC=[lon(x) lat(y)];
                    if ismember(CCC,CC,'rows')                    
                        mvars(x,y)=mean(vars(x,y,:),3); %temporal mean of reference data inside the polygone
                        mvarsm(x,y)=mean(varsm(x,y,:),3); %temporal mean of GCM data inside the polygone
                    else
                        mvars(x,y)=NaN; %nan for the grids outside the polygone
                        mvarsm(x,y)=NaN;
                    end
                end
            end
            statu(i,:,:)= allstats_modified(mvars(:,:),mvarsm(:,:)); %accuracy metrics for all grids
    end
    statu=statu(:,:,2);
    idx=find(all(statu==0,2));
    nc(idx)=[];
    statu(all(~statu,2),:)=[];
    figure(1)
    subaxis(2,2,n,'SpacingVert',0.001,'SpacingHoriz',0.001)
    [pp, tt, axl] = taylordiag(squeeze(statu(:,2)),squeeze(statu(:,3)),squeeze(statu(:,4))); %Taylor plot
    for ii = 1 : length(tt)
        if ii == 1
           s{ii}='REANALYSIS';
        else
           a=split(nc(ii).name,'.nc');
           s{ii}=a{1,1};
           set(tt(ii),'String',s{ii});
        end
    end
    legend(pp,s)
end