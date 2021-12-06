function METEOLAB=getMETEOLAB

% [nom,atr]=textread([prefdir filesep 'METEOLAB.cfg'],'%s%s','delimiter','=','whitespace','\n\r','commentstyle','shell');
% [nom,atr]=textread([prefdir filesep 'METEOLAB.cfg'],'%s%s','delimiter','=','whitespace','\r','commentstyle','shell');

% METEOLAB=struct('home');
% for i=1:length(nom);
% % for i=1:1;   %Defining only MeteoLab Main Path
%     METEOLAB=setfield(METEOLAB,nom{i},atr{i});
% end

METEOLAB.home='/home/pgf/Desktop/MLToolbox_R2013/MeteoLab';