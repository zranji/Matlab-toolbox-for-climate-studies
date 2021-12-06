DIRC=dir('./gribsimp/*.c');
DIRC=cellstr(strcat(' ./gribsimp/',strvcat(DIRC.name)));
eval(['mex -v -I./gribsimp/ -O -output readmessage -outdir .. ./readgrib_b.c readmessage_mex.c gribtomatlab.c ',strcat(DIRC{:})]);
