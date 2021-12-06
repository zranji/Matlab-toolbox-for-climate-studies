% DIRC=dir('./zlib-1.1.4/*.c');
% DIRC=cellstr(strcat(' ./zlib-1.1.4/',strvcat(DIRC.name)));
% eval(['mex -v -I./zlib-1.1.4/ -O -output zipgetStationData -outdir .. zipgetStationData_mex.c' strcat(DIRC{:})])

DIRC=dir('./zlib-1.2.3/*.c');
DIRC=cellstr(strcat(' ./zlib-1.2.3/',strvcat(DIRC.name)));
eval(['mex -v -I./zlib-1.2.3/ -O -output zipgetStationData -outdir .. zipgetStationData_mex.c' strcat(DIRC{:})])
