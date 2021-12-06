function [field,info]=getFieldfromEOF(dmn,varargin)
%field=getFieldfromEOF(cam,dmn,var,time,level)
%
%Funcion que extrae el campo seleccionado del dominio correspondiente, recostruyendo los 
%datos a partir de sus PCs y EOFs, por defecto extrae todos los campos definidos en el 
%dominio
%
%Input : 	
%	dmn		:	domain
%	varargin	:	paramétros opcionales (por defecto toma los definidos en el dmn)
%		'npc'		-	number of EOFs used to extract the data
%		'var'		-	variable name 
%		'time'		-	variable time (requires var definition)
%		'level'		-	variable level (requires var definition)
%		'par'		-	{var1,time1,level1;var2,time2,level2;...} or dmn.par([1 5],:)
%		'startdate'	-	start date of the extraction period 'dd-mmm-yyyy'
%		'enddate'	-	end date of the extraction period 'dd-mmm-yyyy'
%		'pcVector'  -	vectors of PCs used as input to extract the data (in rows)

%
%Example:
%	[field,info] = getFieldfromEOF(dmn,'var','Z','time',12,'level',850,...
%			       'startdate','01-Dec-1992','enddate','05-Dec-1992');
%   Generating two random fields from two random PC vectors
%	[field,info] = getFieldfromEOF(dmn,'npc',10,'pcVector',rand([2 10]));

%Output	:
%	info	: 	{info.par, info.nod, info.startdate, info.enddate}
%	field	:	data matriz (days)*(vars)*(times)*(levels)*(nodes)
%
info=[];
cam=dmn.path;
par=dmn.par;
var=[];
time=[];
level=[];
NPC=[];
startDate1=datenum(dmn.startDate);
endDate1=datenum(dmn.endDate);
startDate2=[];
endDate2=[];
pcVector=[];
for i=1:2:length(varargin)
   switch lower(varargin{i}),
   case 'ncp', NPC = varargin{i+1};   %For compatibility with a previous version
   case 'npc', NPC = varargin{i+1};
   case 'par',  par = varargin{i+1};
   case 'var',  var = varargin{i+1};
   case 'time', time = varargin{i+1}; 
   case 'level', level = varargin{i+1};
   case 'pcvector', pcVector = varargin{i+1};
   case 'startdate',   
      if ((datenum(varargin{i+1}))<startDate1),
         warning(['no existen los datos correspondientes a la fecha ' varargin{i+1}])
         %startDate2=startDate1;
      else
         startDate2 = datenum(varargin{i+1}); 
      end
   case 'enddate',  
      if datenum(varargin{i+1})>endDate1,
         warning(['no existen los datos correspondientes a la fecha' varargin{i+1}])
         %endDate2=endDate1;
      else
         endDate2= datenum(varargin{i+1}); 
      end
   case 'dates', 
      dates=varargin{i+1};
      if (datenum(dates{1})<startDate1),
         warning(['no existen los datos correspondientes a la fecha ' dates{1}])
         %startDate2=startDate1;
      else
         startDate2 = datenum(dates{1}); 
      end
      if (datenum(dates{2})>endDate1),
         warning(['no existen los datos correspondientes a la fecha' dates{2}])
         %endDate2=endDate1;
      else
         endDate2= datenum(dates{2}); 
      end 
   end
%end
end

EOF=loadMtx(cam,'EOF');
MN=loadMtx(cam,'MN');
DV=loadMtx(cam,'DV');
if (~isempty(pcVector))
    PC=pcVector;
    fechas=[1:size(pcVector,1)];
else
    PC=loadMtx(cam,'PC');
end
if (isempty(NPC))
    NPC=size(PC,2);   
end
  
if(all([~isempty(var) ~isempty(time) ~isempty(level)]))
    info.par={var,level,time};
else
    info.par=par;
end

if (~isempty(startDate2))
   info.startDate=datestr(startDate2,'dd-mmm-yyyy');
else
   info.startDate=datestr(startDate1,'dd-mmm-yyyy');
end
if (~isempty(endDate2))
   info.endDate=datestr(endDate2,'dd-mmm-yyyy');
else
   info.endDate=datestr(endDate1,'dd-mmm-yyyy');
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

ind=[];
for p=1:size(info.par,1),
  ind=[ind findVarPosition(info.par{p,1},info.par{p,3},info.par{p,2},dmn)];    
end

if (~isempty(pcVector))
    PC=pcVector;
    fechas=[1:size(pcVector,1)];
end

field=((PC(fechas,1:NPC)*EOF(ind,1:NPC)').*repmat(DV(ind),[length(fechas) 1]))+repmat(MN(ind),[length(fechas) 1]);
info.nod=dmn.nod;

%datos=((PC(fechas,1:NPC)*EOF(:,1:NPC)').*repmat(DV,[length(fechas) 1]))+repmat(MN,[length(fechas) 1]);

% field=[];
% for p=1:length(var),
%    for i=1:length(time)
%       for j=1:length(level)
%          ind=findVarPosition(var(p),time(i),level(j),dmn);
%          field=[field datos(:,ind)];
%       end
%    end
% end

