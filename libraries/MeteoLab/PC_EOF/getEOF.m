function [EOF,PC,MN,DV,PEV]=getEOF(dmn,varargin)
%[EOF,PC,MN,DV,PEV]=getEOF(dmn,varargin)
%
%Loading Empirical Ortogonal Functions (EOF, in columns), the Principal Components 
%(PC, in columns), the cummulative proportion of explained variance by i-th PC (PEV),
%and the mean (MN) and standard deviation (DV) of the data.
%
%The input data is a domain file (dmn)
%		
%	varargin	: optional parameters
%		'npc'	-	is the number of PC-EOF loaded.
%		'startdate'	-	starting date for PCs ('dd-mmm-yyyy')
%		'enddate'	-	end date for PCs ('dd-mmm-yyyy')

if(~isempty(dmn) & ~ischar(dmn))
    startDate1=datenum(dmn.startDate);
    endDate1=datenum(dmn.endDate);
    if isfield(dmn,'path'),cam=dmn.path;else,cam=[];end
elseif(ischar(dmn))
    startDate1=[];
    endDate1=[];
    cam=dmn;
else
    startDate1=[];
    endDate1=[];
    cam=[];
end
    

startDate2=[];
endDate2=[];

NPC=[];
for i=1:2:length(varargin)
   switch lower(varargin{i}),
   case 'ncp', NPC = varargin{i+1}; %for compatibility with an old version
   case 'npc', NPC = varargin{i+1};
   case 'startdate',   
      if ((datenum(varargin{i+1}))<startDate1),
         error(['no existen los datos correspondientes a la fecha ' varargin{i+1}])
      else
         startDate2 = datenum(varargin{i+1}); 
      end
   case 'enddate',  
      if datenum(varargin{i+1})>endDate1,
         error(['no existen los datos correspondientes a la fecha' varargin{i+1}])
      else
         endDate2= datenum(varargin{i+1}); 
      end
   case 'dates', 
      dates=varargin{i+1};
      if (datenum(dates{1})<startDate1),
         error(['no existen los datos correspondientes a la fecha ' dates{1}])
      else
         startDate2 = datenum(dates{1}); 
      end
      if (datenum(dates{2})>endDate1),
         error(['no existen los datos correspondientes a la fecha' dates{2}])
      else
         endDate2= datenum(dates{2}); 
      end 
   case 'path', 
      cam=varargin{i+1};
   otherwise
      error(sprintf('Unknown option in %s : %s',mfilename,lower(varargin{i})));
   end
end

fechas=[];
if(isempty(endDate1) & isempty(startDate1))
    numDias=(endDate1-startDate1)+1;
    if (~isempty(startDate2) & ~isempty(endDate2))
        fechas=[1+(startDate2-startDate1):1:numDias-(endDate1-endDate2)];
    elseif (~isempty(startDate2)& isempty(endDate2))
        fechas=[1+(startDate2-startDate1):1:numDias];
    elseif (~isempty(endDate2) & isempty(startDate2))
        fechas=[1:1:numDias-(endDate1-endDate2)];
    end
end

try
    PC=loadMtx(cam,'PC');
catch
    PC=loadMtx(cam,'CP');
end    
try
    EOF=loadMtx(cam,'EOF');
catch
    EOF=loadMtx(cam,'SV');
end

try
    PEV=loadMtx(cam,'PEV');
catch
    PEV=loadMtx(cam,'OP');
end

MN=loadMtx(cam,'MN');
DV=loadMtx(cam,'DV');


if ~isempty(NPC)
   PC=PC(:,1:NPC);
   EOF=EOF(:,1:NPC);
   PEV=PEV(1:NPC);
end
if ~isempty(fechas)
   PC=PC(fechas,:);
end



