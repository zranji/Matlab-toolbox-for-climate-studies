function [field]=getFieldfromEOF(cam,dmn,varargin)
%field=getFieldfromEOF(cam,dmn,var,time,level)
%
%Funcion que extrae el campo seleccionado del dominio correspondiente, recostruyendo los 
%datos a partir de sus CPs y EOFs, por defecto extrae todos los campos definidos en el 
%dominio
%
%En la entrada : 	
%	cam		:	ruta completa de donde se encuentran las CPs (cfg.cam)
%	dmn		:	domain utilizado para crear las CPs
%	varargin	:	paramétros opcionales (por defecto toma los definidos en el dmn)
%		'ncp'			-	numero de cps que quiero utilizar para reconstruir los datos
%		'var'			-	numero de la variable, con la que se han creado las CPs, que quiero extraer
%		'time'		-	hora de analisis de la variable que quiero extraer (es necesario definir var)
%		'level'		-	nivel de analisis de la variable que quiero extraer (es necesario definir var)
%		'startdate'	-	fecha de inicio de los datos que quiero extraer en formato 'dd-mmm-yyyy'
%		'enddate'	-	fecha de fin de los datos que quiero extraer en formato 'dd-mmm-yyyy'
%ejemplo de llamada:
%	field = getFieldfromEOF(cfg.cam,dmn,'var',129,'time',12,'level',850,...
%			 'startdate','01-Dec-1992','enddate','05-Dec-1992');
%En la salida	:
%	field	: 	estructura con el siguiente formato
%		field.var		:	variable(s) utilizada
%		field.tim		:	hora(s) utilizada
%		field.lvl		:	nivel(es) utilizados
%		field.startdate:	fecha de inicio de los datos seleccionados
%		field.enddate	:	fecha de fin de los datos seleccionados
%		field.dat		:	matriz de datos de tamaño (numero Dias)*...
%				[(longitud de var)*(longitud de time)*(longitud de level)*(numero de nodos)]
%
%
field=[];
CP=[];
NCP=[];
EOF=loadMtx(cam,'SV');
MN=loadMtx(cam,'MN');
DV=loadMtx(cam,'DV');
var=dmn.par;
time=dmn.tim;
level=dmn.lvl;
startDate1=datenum(dmn.startDate);
endDate1=datenum(dmn.endDate);
startDate2=[];
endDate2=[];
for i=1:2:length(varargin)
   switch lower(varargin{i}),
   case 'ncp', NCP = varargin{i+1};
   case 'var',    var = varargin{i+1};
   case 'time', time = varargin{i+1}; 
   case 'level', level = varargin{i+1};
   case 'startdate',   
      if ((datenum(varargin{i+1}))<startDate1),
         startDate1
         (varargin{i+1})
         error(['no existen los datos correspondientes a la fecha ' num2str(varargin{i+1})])
      else
         startDate2 = datenum(varargin{i+1}); 
      end
   case 'enddate',  
      if datenum(varargin{i+1})>endDate1,
         error(['no existen los datos correspondientes a la fecha' varargin{i+1}])
      else
         endDate2= datenum(varargin{i+1}); 
      end
   case 'cp', CP=varargin{i+1}; startDate1=1; endDate1=size(CP,1); 
   end
end
if isempty(CP),
   CP=loadMtx(cam,'CP');
end
if isempty(NCP),
   NCP=size(CP,2);
end


field.var=var;
field.tim=time;
field.lvl=level;
if (~isempty(startDate2))
   field.startDate=datestr(startDate2,'dd-mmm-yyyy');
else
   field.startDate=datestr(startDate1,'dd-mmm-yyyy');
end
if (~isempty(endDate2))
   field.endDate=datestr(endDate2,'dd-mmm-yyyy');
else
   field.endDate=datestr(endDate1,'dd-mmm-yyyy');
end

numDias=(endDate1-startDate1)+1;
if (~isempty(startDate2) & ~isempty(endDate2))
   fechas=[1+(startDate2-startDate1):1:numDias-(endDate1-endDate2)];
elseif (~isempty(startDate2)& isempty(endDate2))
   fechas=[1+(startDate2-startDate1):1:numDias];
elseif (~isempty(endDate2) & isempty(startDate2))
   fechas=[1:1:numDias-(endDate1-endDate2)];
else
   fechas=[1:1:numDias];
end


datos=((CP(fechas,1:NCP)*EOF(:,1:NCP)').*repmat(DV,[length(fechas) 1]))+repmat(MN,[length(fechas) 1]);

field.dat=[];
for p=1:length(var),
   for i=1:length(time)
      for j=1:length(level)
         ind=findVarPosition(var(p),time(i),level(j),dmn);
         field.dat=[field.dat datos(:,ind)];
      end
   end
end

