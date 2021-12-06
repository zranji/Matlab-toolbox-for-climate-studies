function pathzone=getZonePath(zone)
%
METEOLAB=getMETEOLAB;

[Zones,pathZones]=textread(METEOLAB.networksFiles1,'%s%s','delimiter','=','whitespace','\n\r','commentstyle','shell');

if(isfield(METEOLAB,'networksFiles2'))
    [z,p]=textread(METEOLAB.networksFiles2,'%s%s','delimiter','=','whitespace','\n\r','commentstyle','shell');
    Zones=[z;Zones];
    pathZones=[p;pathZones]; 
end

if (isstruct(zone))
    if(isfield(zone,'Network'))
        zone=zone.Network{1};
    end
end
   
i = strmatch(zone,Zones,'exact');
if isempty(i)
    warning(['Network definition not available: ' zone]);
    pathzone=zone;
else
    pathzone=pathZones{i(1)};
end

%Putting everything with forward slash
%METEOLAB=getappdata(0,'METEOLAB');

pathzone = strrep(pathzone,'$METEOLAB_HOME',METEOLAB.home);
pathzone=strrep(pathzone,'\','/');


