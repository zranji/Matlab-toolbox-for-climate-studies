function [tblanl] = reanl_ncep(name,x,y)
longi=ncread(strcat(name,'.nc'),'lon');
lati=ncread(strcat(name,'.nc'),'lat');
[lat,lon]=meshgrid(lati,longi);
time=ncread(strcat(name,'.nc'),'time');
tas=ncread(strcat(name,'.nc'),'air');
hurs=ncread(strcat(name,'.nc'),'rhum');
psl=ncread(strcat(name,'.nc'),'slp');
vas=ncread(strcat(name,'.nc'),'vwnd');
uas=ncread(strcat(name,'.nc'),'uwnd');
t=size(time,1);
    for i=1:t
       u(i)= interp2(lat,lon,uas(:,:,i),y,x);
       v(i)= interp2(lat,lon,vas(:,:,i),y,x);
       ta(i)= interp2(lat,lon,tas(:,:,i),y,x);
       hur(i)= interp2(lat,lon,hurs(:,:,i),y,x);
       ps(i)= interp2(lat,lon,psl(:,:,i),y,x);
    end
date=datestr(double(time/24)+datenum(1800,1,1));
[theta, mag]=cart2pol(u,v);
theta=mod(theta,2*pi());
theta=rad2deg(theta);
theta=mod((270-theta),360);
tblanl=timetable(datetime(date),ps',ta',hur',mag',theta','VariableNames',{'psl','tas','hurs','u','theta'});
end