
disp(['This script will compile the mex-files for the toolbox.'])
disp(['This mex-files has been tested for Windows, Solaris and Linux.'])
disp(['Please refer to Matlab''s Manual to configure your system for'])
disp(['compiling mex-files'] )
disp('')

a=pwd;
%try 
disp('Making buildIndex...')
cd('../../Patterns/private/buildIndex')
MAKE_buildIndex
cd(a)

disp('Making readmessage...')
cd('../../Patterns/private/readmessage')
MAKE_readmessage
MAKE_readmessage2
cd(a)

disp('Making zipgetStationData...')
cd('../../Observations/private/zipgetStationData')
MAKE_zipgetStationData
cd(a)

disp('Making prediccionDetPercentile...')
cd('../../Forecast/private/prediccionDetPercentile')
MAKE_prediccionDetPercentile
cd(a)

disp('Making prediccionDetWm...')
cd('../../Forecast/private/prediccionDetWm')
MAKE_prediccionDetWm
cd(a)

disp('Making prediccionProb...')
cd('../../Forecast/private/prediccionProb')
MAKE_prediccionProb
cd(a)

disp('Making MLknn...')
MAKE_MLknn
disp('Making getPrctile...')
MAKE_getPrctile
%end
cd(a)