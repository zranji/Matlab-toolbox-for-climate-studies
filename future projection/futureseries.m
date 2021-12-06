% futureseries bias correct the future series and plot the timeseries of reference data/gcm data/biascorrected data  
% not applicable for wind speeds and directions

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


var='psl';

cd reference % read the reference data
xr=ncread('REANALYSIS.nc','lon');
yr=ncread('REANALYSIS.nc','lat');
[X,Y]=meshgrid(xr,yr);
varr=ncread('REANALYSIS.nc',var);  
timer=ncread('REANALYSIS.nc','time');
mvarr=mean(mean(varr,1),2);
cd ..

cd ensemble %read the GCMs ensemble data in the baseline period
vars=ncread('ENS_spring.nc',var);  
times=ncread('ENS_spring.nc','time');
mvars=mean(mean(vars,1),2);
cd ..

cd('future/future series') %read the GCMs ensemble data in the future period
var45=ncread('RCP4.5_spring.nc',var);  
time45=ncread('RCP4.5_spring.nc','time');
mvar45=mean(mean(var45,1),2);
var85=ncread('RCP8.5_spring.nc',var);  
time85=ncread('RCP8.5_spring.nc','time');
mvar85=mean(mean(var85,1),2);
cd ../..
% create timeseries of above mentioned data
obs_tmean=timetable(datetime(datestr(timer/24+datenum(1900,1,1))),squeeze(mvarr));%-273.15
SIMcontrol=timetable(datetime(datestr(times+datenum(1850,1,1))),squeeze(mvars));
SIMproj45=timetable(datetime(datestr(time45+datenum(1850,1,1))),squeeze(mvar45));
SIMproj85=timetable(datetime(datestr(time85+datenum(1850,1,1))),squeeze(mvar85));
% call biascorr to bias correct the data
[SIMprojCTL_eQM,SIMproj45_eQM,SIMproj85_eQM]= biascorr(obs_tmean,SIMcontrol,SIMproj45,SIMproj85);
