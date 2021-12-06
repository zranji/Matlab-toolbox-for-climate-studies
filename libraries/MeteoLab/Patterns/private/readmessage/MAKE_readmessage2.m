DIRC=dir('./gribsimp/*.c');
DIRC=cellstr(strcat(' ./gribsimp/',strvcat(DIRC.name)));
eval(['mex -v -I./gribsimp/ -O -output readmessage2 -outdir .. ./readgrib_b_DOUBLE.c readmessage2_mex.c gribtomatlab.c ',strcat(DIRC{:})]);
