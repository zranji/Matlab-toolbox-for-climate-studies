% fitgcm plot the boxplot of the GCMs trends as well as timeseries and trend of the refrence data 
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
% 	boxplot of GCMs and timeseries/trend plot of reference data


clc
clear
close all

cd('ncfiles')
nc=dir('*.nc');
obs='REANALYSIS.nc';
lon=ncread(obs,'lon');
lat=ncread(obs,'lat');
[X,Y]=meshgrid(lon,lat);
VAR={'hurs','tas','psl'};%
for n=1:size(VAR,2)
    vars=ncread(obs,VAR{n});%read the reference data
    timevars=ncread(obs,'time');
    for i=1:size(nc,1)
        fldtmo=ncinfo(nc(i).name);
        a=char(fldtmo.Variables.Name);
        if all(~contains(a,VAR{n}))
            continue;
        end
        varsm=ncread(nc(i).name,VAR{n});%read the GCM data
        timevarsm=ncread(nc(i).name,'time');
        cd ../shapefies
        S=shaperead('AS.shp');
        cd ../ncfiles
        Lon=repmat(lon,size(lat));
        Lat=repmat(lat,size(lon));
        [in,on]=inpolygon(Lon,Lat,S.X',S.Y');%points inside the specified ploygone by shapefile
    %   plot(Lon(in),Lat(in),'r+')
        CC=[Lon(in),Lat(in)];
        id=0;
            for x=1:size(lon)
                for y=1:size(lat)
                    CCC=[lon(x) lat(y)];
                    if ismember(CCC,CC,'rows')
                        %creating timetable of reference and GCM data
                        if i==1
                           gcms=timetable(datetime(datestr(timevarsm/24+datenum(1900,1,1))),squeeze(varsm(x,y,:)));
                           id=id+1;
                           reanal.(strcat('a',num2str(id)))=gcms;
                        else
                            attr=ncinfo(nc(i).name);
                            kk=5;
                            refdate=attr.Variables(kk).Attributes(4).Value;
                            yearref=textscan(refdate,'%s %s %s %s');
                            refyr=year(yearref{3});
                            gcms=timetable(datetime(datestr(timevarsm+datenum(refyr,1,1))),squeeze(varsm(x,y,:)));
                        end
                        yearly_average=retime(gcms,'yearly','mean'); %yearly mean of the data
                        f1=fit(year(yearly_average.Time),yearly_average.Var1,'poly1');
                        mvarsm(x,y)=f1.p1;
                    else
                        mvarsm(x,y)=NaN;
                    end
                end
            end
            trend_gcm(i)= nanmean(nanmean(mvarsm(:,:)));
    end
    %box plot of GCMs
    h=ttest(trend_gcm);
    subplot(3,2,2*n)
    boxplot(trend_gcm(2:end)./trend_gcm(1))
    hold on
    scatter(1,trend_gcm(1)./trend_gcm(1),'g','filled')
    hold on

    %% Reanalysis dataset plot
    fld=fieldnames(reanal);
    for vr=1:size(fld,1)
        temp=retime(reanal.(char(fld(vr,:))),'yearly','mean');
        yearlyaverage(vr,:)=temp.Var1;
    end
    meangrid=mean(yearlyaverage,1);
    f4=fit(year(temp.Time),meangrid','poly1');
    %% plot
    subplot(3,2,2*n-1)
    plot(year(temp.Time),meangrid)
    hold on
    plot(f4)
    set(gca,'xlim',([1979 2005]))
end