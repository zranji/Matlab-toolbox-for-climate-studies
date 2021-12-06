function mapaBlank(X,Y,Z)
%Cargamos los poligonos de los paises
STR=load('worldlo.mat','POpatch');

%Dentro hay una variable que me da el nombre.
%   Lo usaremos para saber cual es Spain
[names{1:length(STR.POpatch)}]=deal(STR.POpatch.tag);
i=strmatch('Spain',names);
%Ahora que lo sabemos extraemos sus poligonos
XB=STR.POpatch(i).long;
YB=STR.POpatch(i).lat;

%Definimos cual es el rectangulo que queremos
XC=[-11 6 6 -11 -11]';
YC=[33 33 45 45 33]';

%Y con todo esto definimos obtenemos la mascara.
[XA,YA]=polybool('-',XC,YC,XB,YB,'cutvector');

%[X,Y]=meshgrid(linspace(-11,5,100),linspace(34,45,100));

%[cc,hh]=contourf(X,Y,Z,3);
   
pcolor(X,Y,Z);
shading('flat')
hold on
%y la pintamos para ver si es lo que queremos
h=patch(XA,YA,'w');
set(h,'EdgeColor','none')
plot(XB,YB,'k')
set(gca,'DataAspectRatioMode','manual','DataAspectRatio',[1 1 1],'visible','off');

