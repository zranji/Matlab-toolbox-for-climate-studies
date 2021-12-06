function [tblanl] = reanl_era(name,x,y)
longi=ncread(strcat(name,'.nc'),'longitude');
lati=ncread(strcat(name,'.nc'),'latitude');
[lat,lon]=meshgrid(lati,longi);
time=ncread(strcat(name,'.nc'),'time');
tas=ncread(strcat(name,'.nc'),'t2m');
dew=ncread(strcat(name,'.nc'),'d2m');
psl=ncread(strcat(name,'.nc'),'msl');
vas=ncread(strcat(name,'.nc'),'v10');
uas=ncread(strcat(name,'.nc'),'u10');
t=size(time,1);
    for i=1:t
       u(i)= interp2(lat,lon,uas(:,:,i),y,x);
       v(i)= interp2(lat,lon,vas(:,:,i),y,x);
       ta(i)= interp2(lat,lon,tas(:,:,i),y,x)-273.15;
       de(i)= interp2(lat,lon,dew(:,:,i),y,x)-273.15;
       ps(i)= interp2(lat,lon,psl(:,:,i),y,x)/100;
    end
hum1=6.11*exp(17.67*de./(243.5+de));
hum2=6.11*exp(17.67*ta./(243.5+ta));
hur=100*hum1./hum2;
date=datestr(double(time/24)+datenum(1900,1,1));
[theta, mag]=cart2pol(u,v);
theta=mod(theta,2*pi());
theta=rad2deg(theta);
theta=mod((270-theta),360);
tblanl=timetable(datetime(date),ps',ta',hur',mag',theta','VariableNames',{'psl','tas','hurs','u','theta'});
end