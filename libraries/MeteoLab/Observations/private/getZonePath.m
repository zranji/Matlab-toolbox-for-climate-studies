function pathzone=getZonePath(zone)
%
pathzone=zone;
if(isempty(dir(pathzone)))   % The network is not in the specified directory
    METEOLAB=getMETEOLAB;  % Setting the network directory to the default one
    pathzone=[METEOLAB.home '/../ObservationsData/' zone];
    if(isempty(dir(pathzone)))    % The network is not in 'ObservationsData' directory
        error(['Directory ' zone ' cannot be found in path ' zone ' nor ' [METEOLAB.home '/../ObservationsData/']]);
    end
end

% METEOLAB=getMETEOLAB;

% [Zones,pathZones]=textread(METEOLAB.networksFiles1,'%s%s','delimiter','=','whitespace','\n\r','commentstyle','shell');

% if(isfield(METEOLAB,'networksFiles2'))
    % [z,p]=textread(METEOLAB.networksFiles2,'%s%s','delimiter','=','whitespace','\n\r','commentstyle','shell');
    % Zones=[z;Zones];
    % pathZones=[p;pathZones]; 
% end

% i = strmatch(zone,Zones,'exact');
% if isempty(i)
    % warning(['Network definition not available: ' zone]);
    % pathzone=zone;
% else
    % pathzone=pathZones{i(1)};
% end

%Putting everything with forward slash
%METEOLAB=getappdata(0,'METEOLAB');

% pathzone = strrep(pathzone,'$METEOLAB_HOME',METEOLAB.home);
% pathzone=strrep(pathzone,'\','/');
