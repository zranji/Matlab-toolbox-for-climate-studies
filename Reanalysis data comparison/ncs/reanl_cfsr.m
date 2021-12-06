function [tblanl] = reanl_cfsr(name,x,y)
longi=ncread(strcat(name,'.nc'),'lon');
lati=ncread(strcat(name,'.nc'),'lat');
[lat,lon]=meshgrid(lati,longi);
longi2=ncread(strcat(name,'.nc'),'lon_2');
lati2=ncread(strcat(name,'.nc'),'lat_2');
[lat2,lon2]=meshgrid(lati2,longi2);
time=ncread(strcat(name,'.nc'),'time');
tas=ncread(strcat(name,'.nc'),'tas');
hurs=ncread(strcat(name,'.nc'),'hurs');
psl=ncread(strcat(name,'.nc'),'psl');
vas=ncread(strcat(name,'.nc'),'vas');
uas=ncread(strcat(name,'.nc'),'uas');
t=size(time,1);
    for i=1:t
       u(i)= interp2(lat2,lon2,uas(:,:,i),y,x);
       v(i)= interp2(lat2,lon2,vas(:,:,i),y,x);
       ta(i)= interp2(lat2,lon2,tas(:,:,i),y,x)-273.15;
       hur(i)= interp2(lat,lon,hurs(:,:,i),y,x);
       ps(i)= interp2(lat,lon,psl(:,:,i),y,x)/100;
    end
date=datestr(time+datenum(1979,1,1));
[theta, mag]=cart2pol(u,v);
theta=mod(theta,2*pi());
theta=rad2deg(theta);
theta=mod((270-theta),360);
tblanl=timetable(datetime(date),ps',ta',hur',mag',theta','VariableNames',{'psl','tas','hurs','u','theta'});
end