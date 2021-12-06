ISCONTOUR=1;
ISPCOLOR=0;
ISCONTOURF=0;

numEOFs=4;no=numEOFs^.5;
va=[129 12 500]; %parametro, tiempo, nivel
ncont=10; % cant lineas
%130 temperatura
%		Kelvin
%129 geopotencial (m^2/s^2)
%		en este caso hay que dividir por 9.8 para tener la altura del geopotencia (in m).
%133 humedad especifica (Kg(agua)/Kg(aire))
%		

load('meteocolor')
cfg.fil='domain.cfg';
cfg.cam='../AreaPatterns/ECMWF1_N/Nacional10_Z500/'; %IMPORTANTE estoy trabajando en meteolab10.0litecfg.fil='domain.cfg';  
%cfg.cam=['../AreaPatterns/DEMETERPeru/Peru2.0/']
%cfg.cam=['../AreaPatterns/DEMETERPeru/Nino12/']
%cfg.cam=['../AreaPatterns/ECMWF1/Nacional50/']

dmn=readDomain([cfg.cam cfg.fil]);

%CP=loadMtx(cfg.cam,'CP');
EOF=loadMtx(cfg.cam,'SV');
OP=loadMtx(cfg.cam,'OP');
mu=loadMtx(cfg.cam,'MN');
sig=loadMtx(cfg.cam,'DV');

% en el caso de geopontencial dividimos por 9.8
if (va(1)==129) EOF=EOF/9.8; end
% en el caso de MSLP tenemos Pascales. Dividimos por 100 para pasar a hPa o mb.
if (va(1)==151) EOF=EOF/100; end

lambda=OP(:,1); %valores propios


%[Y,X]=meshgrid(dmn.lat,dmn.lon);
y=dmn.lat;
x=dmn.lon;
[Y2,X2]=meshgrid(y,x);

x=linspace(min(x),max(x),100);
y=linspace(min(y),max(y),100);
[Y,X]=meshgrid(y,x);

worldlo=load('worldlo');
%fidbnd=fopen('worldcoastlo.bin','rb','ieee-be');
%bnd=fread(fidbnd,[2,inf],'single')';
%fclose(fidbnd);

ind=getInd(va(1,:),dmn);

X1=X2(dmn.nod);
Y1=Y2(dmn.nod);

%lambda:autovalores. 
%(1) sin desantarizar:
%EOFDim=EOF;
%(2)Sin desandarizar y multiplicando EOFs*lambda
%	EOFDim=EOF.*repmat(lambda',[size(EOF,1) 1]);
%(3)Se desestandariza y se hace EOFs*lambda 
%ojo porque datos=datos*EOF*LAMBDA*EOF', luego el patron es EOF*sqrt(lambda)
%EOFDim=EOF.*repmat(sqrt(lambda'),[size(EOF,1) 1]).*repmat(sig',[1 size(EOF,2)])+repmat(mu',[1 size(EOF,2)]);
%(4)Anomalia 
EOFDim=EOF.*repmat(sqrt(lambda'),[size(EOF,1) 1]).*repmat(sig',[1 size(EOF,2)]);

figure('name',['Variable ' num2str(va(1,1)) ' at ' num2str(va(1,3),'%04d') ' mb (' num2str(va(1,2),'%02d') 'Z)'])
colormap(meteocolor(end-20:-1:20,:));
cl=[min(prctile(EOFDim(ind,:),2)) max(prctile(EOFDim(ind,:),90))];
%cl=[min(min(SV(ind3,:))) max(max(SV(ind3,:)))];
for clas=1:numEOFs
   axes('units','normal','Position',[mod(clas-1,no)*1/no 1-(1+fix((clas-1)/no))*1/no 1/no 1/no],...
      'box','on');
   %shading('interp')
   hold on
   axis equal
   set(gca,'xtick',[],'ytick',[],...
      'xlimmode','manual','xlim',[min(dmn.lon) max(dmn.lon)],...
      'ylimmode','manual','ylim',[min(dmn.lat) max(dmn.lat)],...
      'climmode','manual','clim',[cl(1) cl(2)]);
   % Para dibujar viento utilizamos el quiver y le pasamos dos coordenadas
   %axis manual
   %[cc,hh]=contourf(X,Y,reshape(SV(ind3,clas),size(x,2),size(y,2))');
   %quiver(X,Y,reshape(SV(ind1,clas),size(x,2),size(y,2))',reshape(SV(ind2,clas),size(x,2),size(y,2))','k');
   %plot(bnd(:,1),bnd(:,2),'k');
   Z1=EOFDim(ind,clas);
   Z=GRIDDATA(X1,Y1,Z1,X,Y);
   if(ISPCOLOR)
      surface(X,Y,zeros(size(Z)),Z);shading('flat');
      set(gca,'View',[0 90],'DataAspectRatio',[1 1 1],'DataAspectRatioMode','manual');
   elseif(ISCONTOURF)
      contourf(X,Y,Z,ncont);
      set(gca,'View',[0 90],'DataAspectRatio',[1 1 1],'DataAspectRatioMode','manual');
   elseif(ISCONTOUR)
      stcont=(max(max(Z))-min(min(Z)))/ncont;%paso entre lineas
      cont=[min(min(Z)):stcont:max(max(Z))];
      cont=round(100*cont)/100;%redondeo de los datos para el plot
      [cc,hh]=contour(X,Y,Z,cont);
      % pcolor(X2,Y2,z);
      set(hh,'LineWidth',2);
      h=clabel(cc,hh,'FontName','Arial','FontUnits','Normal','FontSize',0.075,'labelspacing',1000);
      %h=clabel(cc,hh,'FontName','Arial','FontUnits','Normal','FontSize',0.075);   
   else
      error('No te lo crees ni tu');
   end
   
   plot(worldlo.POline(1).long,worldlo.POline(1).lat,'r')
	plot(worldlo.POline(2).long,worldlo.POline(2).lat,'b')
   
   %plot(bnd(:,1),bnd(:,2),'b','LineWidth',1);
   
	drawnow
end
h=axes('Units','Normal','Position',[0 0.05 0.5 0.90],...
   'climmode','manual','clim',[cl(1) cl(2)],'zlimmode','manual','zlim',[cl(1) cl(2)]);
h2=surface(X,Y,zeros(size(Z)),Z);shading('flat');
colorbar
set(h,'Visible','off')
set(h2,'Visible','off')





