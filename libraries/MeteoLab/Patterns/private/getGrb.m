function [DATA,xi,yi]=getGrb(dmn)
fcDate=datevec(datenum(1979,1,1):datenum(1994,2,28));
fcDate=fcDate(:,1:3);
disp(dmn);
ctl.cam=['./'];
ctl.fil='era.ctl';
ctlname=[ctl.cam ctl.fil];
idxname=[ctl.cam ctl.fil '.idx'];
disp(ctlname)
fid=fopen(ctlname,'rb');
k=1;
while ~feof(fid)
   name{k}=[ctl.cam fgetl(fid)];
   k=k+1;
end
fclose(fid);
buildIndex('read',ctl.cam,'','era.ctl.idx');
DATA=[];
[xi,yi]=meshgrid(dmn.lon,dmn.lat);
for D=1:size(fcDate,1)
   %if(fcDate(D,2)==1 & fcDate(D,3)==1),fprintf(1,'%d\n',fcDate(D,1)),end
   mess=sprintf('%04d%02d%02d%02d%04d_%03d%03d%04d',fcDate(D,:),dmn.tim,0,dmn.par,0,dmn.lvl);
   F=buildIndex('find',mess,'1','');
   if F(1)
      [A,info]=readmessage(name{F(1)},F(2));
   else
      error(['Field not found: ',mess]);
   end
   
   if (info.PDS.Parameter==dmn.par & info.PDS.Height1==dmn.lvl& info.PDS.Hour==dmn.tim & info.PDS.Year==mod(fcDate(D,1),100) & info.PDS.Month==fcDate(D,2)& info.PDS.Day==fcDate(D,3))
      if isempty(DATA)
         
         scanmode=info.GDS.LatLon.ScanMode;
         dx=(1-2*bitget(scanmode,1))*info.GDS.LatLon.Di;
         dy=(-1+2*bitget(scanmode,2))*info.GDS.LatLon.Dj;
         
         x=info.GDS.LatLon.Lon1:dx:info.GDS.LatLon.Lon2;
         y=info.GDS.LatLon.Lat1:dy:info.GDS.LatLon.Lat2;
         x=x/1000;y=y/1000;
      	[X,Y]=meshgrid(x,y);   
	      if bitget(scanmode,3)
            X=X';Y=Y';
         end
         DATA=zeros([size(fcDate,1),length(dmn.lon)*length(dmn.lat)])*NaN;
      end

    %  if (size(DATA,2) == prod(size(A)))
         %DATA(D,:)=A(:)';
         zi=interp2(X,Y,A,xi,yi,'cubic')';
         DATA(D,:)=zi(:)';
     % else
     %    error(sprintf('dim(A)=%d & dim(DATA,2)=%d are differents in mess: %s',prod(size(A)),size(DATA,2),mess));
     % end
   else
      error('Problems reading message');
   end
end
