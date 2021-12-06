function [TZH,dmn,anDate]=getFieldfromGRIB(ctl,dmn,varargin)

if(nargin<2 | isempty(dmn))
   [archivo,Camino2]=uigetfile('*.cfg','Selecciona un Dominio');
   dmn=readDomain([Camino2]);
end

startDate=datenum(dmn.startDate);
endDate=datenum(dmn.endDate);
if nargin>2,
   for i=1:2:length(varargin)
      switch lower(varargin{i}),
      case 'dates', 
         dates=varargin{i+1};
         if (datenum(dates{1})<startDate),
            warning(['no existen los datos correspondientes a la fecha ' dates{1}])
         else
            startDate = datenum(dates{1}); 
         end
         if (datenum(dates{2})>endDate),
            warning(['no existen los datos correspondientes a la fecha' dates{2}])
         else
            endDate= datenum(dates{2}); 
         end 
      end
   end
end


anDate=datevec(startDate:datenum(stepvec(dmn.step)):endDate);
[TZH,anDate,dmn]=getFRCfromGRIB(ctl,dmn,anDate,'Analysis',0);
