#include<stdio.h>
#include<stdlib.h>
#include"../proutils.h"
#define VERSION "$Rev: 1123 $ $Date: 2011-12-12 17:10:25 +0330 (دوشنبه, 12 دسامبر 2011) $"
int main(int argc, char **argv){
    char NameOut[1024];
    char cmd[]="make,sort,write";
    char mess[]="19790101000000_1510000000";
    //char cmd[]="read";
    char *Dir=NULL,*NameIn=NULL;
	if(argc<3){
       printf(VERSION);
	   printf("\n%s directory listFiles\n",argv[0]);
       exit(1);
    }
	Dir=argv[1];
	NameIn=argv[2];
	
	printf("Processing: %s\n",NameIn);
    sprintf(NameOut,"%s.idx",NameIn);
    buildIndex(cmd,Dir,NameIn,NameOut);
    //buildIndex("find",mess,"1","");
    return 0;
}
// /*
    // if(strlen(Dir)>0 && ((Dir[strlen(Dir)-1]!='/') || (Dir[strlen(Dir)-1]!='\\'))){
        // sprintf(DirData,"%s/",Dir);
    // }else{
        // sprintf(DirData,"%s",Dir);
    // }   
	// /*Create index*/
    // makeIndex(Dir,NameIn);
	// /*Sort index*/
	// printf("\tSorting Fields...\n");
	// qsort(IdxFace,(size_t)IdxSize,sizeof(char *),compare);
 	// /*Write index*/
    // printf("\tWriting Fields...\n");
    // sprintf(DataFileIdx,"%s%s.idx",DirData,NameIn);
	// if(!(ftxt=fopen(DataFileIdx,"wb"))){sprintf(dum1,"Invalid Output File %s",DataFileIdx);fprintf(stderr,dum1);}
    // for (k=0;k<IdxSize;k++){
		// IdxFace[k][FaceLength-1]='\n';
        // fwrite( IdxFace[k], sizeof(char)*FaceLength,1, ftxt );
	// }
    // if (ftxt) fclose(ftxt);
    // /*Finished*/
    // return 0;
// */
