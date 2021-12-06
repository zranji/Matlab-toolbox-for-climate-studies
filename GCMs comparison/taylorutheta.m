% taylor plot the Taylor graph for visual compariosn of GCMs 
% Applicable for wind speeds and wind direction.

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
%   Tatlor plot of GCMs


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
[thetao,mago]=cart2pol(vars1,vars2);
thetao=mod(thetao,2*pi());
thetao=rad2deg(thetao);
thetao=mod((270-thetao),360);
for i=1:size(nc,1)
    fldtmo=ncinfo(nc(i).name);
    a=char(fldtmo.Variables.Name);
    if all(~contains(a,'uas'))
        continue;
    end
    varsm1=ncread(nc(i).name,'uas'); %read the GCM data
    varsm2=ncread(nc(i).name,'vas'); %read the GCM data
    [thetam,magm]=cart2pol(varsm1,varsm2); %conversion of u/v to mag/theta
    thetam=mod(thetam,2*pi());
    thetam=rad2deg(thetam);
    thetam=mod((270-thetam),360);
    cd ../shapefies
    S=shaperead('AS.shp');
    cd ../ncfiles
    Lon=repmat(lon,size(lat));
    Lat=repmat(lat,size(lon));
    [in,on]=inpolygon(Lon,Lat,S.X',S.Y'); %points inside the specified ploygone by shapefile
    CC=[Lon(in),Lat(in)];
        for x=1:size(lon)
            for y=1:size(lat)
                CCC=[lon(x) lat(y)];
                if ismember(CCC,CC,'rows')                    
                    mvars(x,y)=mean(mago(x,y,:),3); %interchangeable between theta/mago
                    %mvars(x,y)=mean(thetao(x,y,:),3);
                    mvarsm(x,y)=mean(magm(x,y,:),3); %interchangeable between theta/mago
                    %mvarsm(x,y)=mean(thetam(x,y,:),3);
                else
                    mvars(x,y)=NaN;
                    mvarsm(x,y)=NaN;
                end
            end
        end
        statu(i,:,:)= allstats_modified(mvars(:,:),mvarsm(:,:)); %accuracy metrics for all grids
        %statu(i,:,:)= allstatstheta_modified(mvars(:,:),mvarsm(:,:)); %for theta
end
statu=statu(:,:,2);
idx=find(all(statu==0,2));
nc(idx)=[];
statu(all(~statu,2),:)=[];
subaxis(2,2,4,'SpacingVert',0.001,'SpacingHoriz',0.001)
[pp, tt, axl] = taylordiag(squeeze(statu(:,2)),squeeze(statu(:,3)),squeeze(statu(:,4)));%Taylor plot
for ii = 1 : size(statu,1)
    if ii == 1
       s{ii}='REANALYSIS';
    else
       a=split(nc(ii).name,{'out_','.nc'});
       s{ii}=a{2,1};
       set(tt(ii),'String',s{ii});
    end
end
legend(pp,s)