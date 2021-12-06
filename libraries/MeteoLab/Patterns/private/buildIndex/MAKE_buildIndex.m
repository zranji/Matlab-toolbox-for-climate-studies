DIRC=dir('./gribsimp_buildindex/*.c');
DIRC=cellstr(strcat(' ./gribsimp_buildindex/',strvcat(DIRC.name)));
eval(['mex -v -I./include/ -O -output buildIndex -outdir .. buildIndex_mex.c buildIndex.c proutils.c ',strcat(DIRC{:})]);
