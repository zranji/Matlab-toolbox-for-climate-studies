% futureseries bias correct the future series and plot the timeseries of reference data/gcm data/biascorrected data  
% applicable for wind speeds and directions

% INPUTS:
%	Timeseries of reference data in baseline period in netcdf format in future/future series directory
%   Timeseries of GCMs ensemble in baseline period in netcdf format in future/future series directory
%   Timeseries of GCMs ensemble in future period in netcdf format in future/future series directory (all netcdf files must be
%   regridded into a similar grid. We used remapbic command of CDO package, for this purpose)

% There are also series of cdo commands, provided as examples, to extract GCMs signals:
% cdo seltimestep,901/1140 RCP45.nc RCP45_far.nc     to extract mid/far future time slice
% cdo splitmon RCP45_far.nc mon  to extrcat specific months
% cdo runavg,20 m5_RCP45_far.nc rcp5_RCP45_far.nc  to average over the time slice
% cdo ensmean rcp5_RCP45_far.nc rcp6_RCP45_far.nc rcp_RCP45_far.nc  to average seasonally on from extracted months
% ncdiff out_rcp_RCP45_far.nc out_his_his.nc sig45_far.nc to extract the signals by substracting historical mean from future mean
% cdo ensmean -apply,-selname,zg,ua,va,ta [ cnrm.nc mpi-mr.nc canesm.nc mpi-lr.nc csiro.nc cmcc.nc ] ENS.nc to average over different (top-ranked) GCMs
% OUTPUTS:
% timeseries plot of reference data and ensemble of GCMs in the baseline
% period together with original and bias corrected data in the future
% period

clc
clear 
close all

var='uas';
var2='vas';

cd reference % read the reference data
xr=ncread('REANALYSIS.nc','lon');
yr=ncread('REANALYSIS.nc','lat');
[X,Y]=meshgrid(xr,yr);
ur=ncread('REANALYSIS.nc',var); 
vr=ncread('REANALYSIS.nc',var2);
[varrth,varr]=cart2pol(ur,vr);
varrth=mod(varrth,2*pi());
varrth=rad2deg(varrth);
varrth=mod((270-varrth),360);
timer=ncread('REANALYSIS.nc','time');
mvarr=mean(mean(varr,1),2);
mvarrth=mean(mean(varrth,1),2);
cd ..

cd ensemble  %read the GCMs ensemble data in the baseline period
us=ncread('ENS_spring.nc',var);
vs=ncread('ENS_spring.nc',var2);
[varsth,vars]=cart2pol(us,vs);%conversion of u/v to mag/theta
varsth=mod(varsth,2*pi());
varsth=rad2deg(varsth);
varsth=mod((270-varsth),360);
times=ncread('ENS_spring.nc','time');
mvars=mean(mean(vars,1),2);
mvarsth=mean(mean(vars,1),2);
cd ..

cd('future/future series') %read the GCMs ensemble data in the future period
u45=ncread('RCP4.5_spring.nc',var);  
v45=ncread('RCP4.5_spring.nc',var2);
[var45th,var45]=cart2pol(u45,v45);%conversion of u/v to mag/theta
var45th=mod(var45th,2*pi());
var45th=rad2deg(var45th);
var45th=mod((270-var45th),360);
time45=ncread('RCP4.5_spring.nc','time');
mvar45=mean(mean(var45,1),2);
mvar45th=mean(mean(var45th,1),2);
u85=ncread('RCP8.5_spring.nc',var); 
v85=ncread('RCP8.5_spring.nc',var2);
[var85th,var85]=cart2pol(u85,v85);%conversion of u/v to mag/theta
var85th=mod(var85th,2*pi());
var85th=rad2deg(var85th);
var85th=mod((270-var85th),360);  
time85=ncread('RCP8.5_spring.nc','time');
mvar85=mean(mean(var85,1),2);
mvar85th=mean(mean(var85th,1),2);
cd ../..
% create timeseries of above mentioned data
obs_tmean=timetable(datetime(datestr(timer/24+datenum(1900,1,1))),squeeze(mvarr));
SIMcontrol=timetable(datetime(datestr(times+datenum(1850,1,1))),squeeze(mvars));
SIMproj45=timetable(datetime(datestr(time45+datenum(1850,1,1))),squeeze(mvar45));
SIMproj85=timetable(datetime(datestr(time85+datenum(1850,1,1))),squeeze(mvar85));
% call biascorr to bias correct the data
[SIMprojCTL_eQM,SIMproj45_eQM,SIMproj85_eQM]= biascorr(obs_tmean,SIMcontrol,SIMproj45,SIMproj85);
