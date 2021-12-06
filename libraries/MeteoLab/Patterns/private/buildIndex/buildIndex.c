/*
20050819 Antonio S. Cofino cofinoa@yahoo.es
         -modified casts warnings due to compare funtion declaration

*/


#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include "gribfuncs.h"
#include "proutils.h"
#define VERBOSE 1
#define LENGTHPATH 1024
#define STRINGLENGTH 1024
int debug=0;
static char **IdxFace=NULL;
static long FaceLength=-1;
static long IdxSize=0;
static long IdxSizeMAX=0;
static long FaceCMP=0;
static long pIdxFile=26;
static long wIdxFile=4;
static long pIdxPosi=30;
static long wIdxPosi=10;
static char IdxFormatDefault[]="%04d%02d%02d%02d%04d_%03d%03d%04d_%04d%010d";
static char IdxFormat[STRINGLENGTH],DumMess[STRINGLENGTH];

int grbseek (char *,FILE **, long *, int,GRIB_HDR *, char *);
int grib_dec_heads (char *, PDS_INPUT  *, grid_desc_sec  *,
            BDS_HEAD_INPUT *, BMS_INPUT *,char *);
typedef struct Index_member{
    unsigned short Year;
    unsigned char  Month;
    unsigned char  Day;
    unsigned char  Hour;
    unsigned short Fore;
    unsigned char  Parm;
    unsigned char  Subparm;
    unsigned short Height;
    unsigned long  File;
    unsigned long  Pos;
} Index_member;

int compare( const void *arg1, const void *arg2 ){
    return strncmp(((char **)arg1)[0],((char **)arg2)[0],FaceCMP);
}
int makeIndex(char *Dir,char *NameIn);

int parseIdxFormat(char *Dir,char *NameIn){
	char *pch,DataFile[LENGTHPATH],DirData[LENGTHPATH];
	char ndat[STRINGLENGTH],dum1[STRINGLENGTH];
	FILE *fin;
	int status;
	if(strlen(Dir)>0 && ((Dir[strlen(Dir)-1]!='/') || (Dir[strlen(Dir)-1]!='\\'))){
	        sprintf(DirData,"%s/",Dir);
	    }else{
	        sprintf(DirData,"%s",Dir);
	    }
	sprintf(DataFile,"%s%s",DirData,NameIn);
	if(!(fin=fopen(DataFile,"rb"))){
        sprintf(dum1,"Invalid Input File %s",DataFile);
        errMsgTxt(dum1);
    }
    status=fscanf(fin,"%s",ndat);
    /*printf("Processing: %s (%d)\n",ndat,status);*/
	if(ndat[0]=='%'){
		strcpy(IdxFormat,ndat);
		status=fscanf(fin,"%s",ndat);
    }else{
		strcpy(IdxFormat,IdxFormatDefault);
	}
	/*sprintf(DumMess,IdxFormat,idx[k].Year=0,idx[k].Month=0,idx[k].Day=0,idx[k].Hour=0,idx[k].Fore=0,idx[k].Parm=0,idx[k].Subparm=0,idx[k].Height=0,idx[k].File=0,idx[k].Pos=0);*/
	sprintf(DumMess,IdxFormat,1,2,3,4,5,6,7,8,9,10);
	FaceLength=strlen(DumMess)+1;
	pch=strrchr(DumMess,'_');
	if(pch==NULL){
	    sprintf(dum1,"Invalid Index Format string %s",IdxFormat);
        errMsgTxt(dum1);
	}
	FaceCMP=(pch-DumMess)/sizeof(char);
	pch=strrchr(IdxFormat,'_');
    if(pch==NULL){
    	    sprintf(dum1,"Invalid Index Format string %s",IdxFormat);
            errMsgTxt(dum1);
   	}
    status=sscanf(pch,"_%%%dd%%%dd",&wIdxFile,&wIdxPosi);
    if(status<2){
    	    sprintf(dum1,"Invalid Index Format string %s",IdxFormat);
            errMsgTxt(dum1);
   	}
    pIdxFile=FaceCMP+1;
	pIdxPosi=FaceCMP+1+wIdxFile;
	#if VERBOSE>0
		printf("DumMess:%s\n",DumMess);
		printf("FaceLength: %d; FaceCMP: %d\n",FaceLength,FaceCMP);
	#endif
	fclose(fin);
	return 0;
}

SDoubleMtx *buildIndex(char *cmd,char *Dir,char *NameIn,char *NameOut) {
    FILE *ftxt;
    int i=0,k=0;char dum1[LENGTHPATH],DirData[LENGTHPATH],DataFile[LENGTHPATH];
    char ndat[STRINGLENGTH];
    int d[]={1,2};
    long NM;
    SDoubleMtx *MtxF=NULL;
    char *mess,**messFound,*temp;
    /*printf("Starting...\n");*/
    if(strstr(cmd,"make")){
    	if(strlen(Dir)>0 && ((Dir[strlen(Dir)-1]!='/') || (Dir[strlen(Dir)-1]!='\\'))){
    	        sprintf(DirData,"%s/",Dir);
    	    }else{
    	        sprintf(DirData,"%s",Dir);
   	    }
        parseIdxFormat(Dir,NameIn);
        if(IdxFace) {
			if(IdxFace[0]) free(IdxFace[0]);
			free(IdxFace);
		}
        /*printf("Making: %s %s\n",Dir,NameIn);*/
        IdxFace=NULL;
        IdxSize=0;
        IdxSizeMAX=0;
        makeIndex(Dir,NameIn);

    }
    if(strstr(cmd,"sort")){
        qsort(IdxFace,(size_t)IdxSize,sizeof(char *),compare);
    }
    
    if(strstr(cmd,"write")){
        sprintf(DataFile,"%s%s",DirData,NameOut);
        if(!(ftxt=fopen(DataFile,"wb"))){sprintf(dum1,"Invalid Output File %s",DataFile);errMsgTxt(dum1);}
        for (k=0;k<IdxSize;k++)
            /*IdxFace[k][FaceLength-1]='\n';*/
			/*fwrite( IdxFace[k], sizeof(char)*FaceLength,1, ftxt );*/
			fprintf(ftxt,"%s\n",IdxFace[k]);
        if (ftxt) fclose(ftxt);
    }
    
    if(strstr(cmd,"read")){
    	if(strlen(Dir)>0 && ((Dir[strlen(Dir)-1]!='/') || (Dir[strlen(Dir)-1]!='\\'))){
    	        sprintf(DirData,"%s/",Dir);
    	    }else{
    	        sprintf(DirData,"%s",Dir);
   	    }
        parseIdxFormat(Dir,NameIn);
        sprintf(DataFile,"%s%s",DirData,NameOut);
        if(!(ftxt=fopen(DataFile,"rb"))){sprintf(dum1,"Invalid Index File %s",DataFile);errMsgTxt(dum1);}
        if(IdxFace) {
			if(IdxFace[0]) free(IdxFace[0]);
			free(IdxFace);
		}
        IdxFace=NULL;
        IdxSize=0;
        IdxSizeMAX=0;
        k=0;
        while (fscanf(ftxt,"%s",ndat)>0){
            if((strlen(ndat)+1)!=FaceLength){sprintf(dum1,"Invalid FaceLength %d!=%d",(strlen(ndat)+1),FaceLength);errMsgTxt(dum1);}
        	if(IdxSize>=IdxSizeMAX){
            	IdxSizeMAX+=10000;
            	if(IdxFace==NULL){
            		IdxFace=(char**)malloc(sizeof(char *)*IdxSizeMAX);
            		IdxFace[0]=(char *)malloc(sizeof(char)*FaceLength*IdxSizeMAX);
            	}else{
            		IdxFace=(char**)realloc(IdxFace,sizeof(char *)*IdxSizeMAX);
            		temp=(char *)realloc(IdxFace[0],sizeof(char)*FaceLength*IdxSizeMAX);
            		if(temp!=IdxFace[0]){
            			for(i=1;i<k;i++) IdxFace[i]=&temp[FaceLength*i];
            		}
            		IdxFace[0]=temp;
            	}
            }
            IdxFace[k]=&IdxFace[0][FaceLength*k];
            strcpy(IdxFace[k],ndat);
            k++;IdxSize++;
        }
        printf("%d messages indexes read\n",IdxSize);
        if (ftxt) fclose(ftxt);
    
    }
    if(strstr(cmd,"find")){
        /*printf("%s %s\n",NameIn,Dir);*/
        NM=strtol(NameIn,&mess,10);
        d[0]=NM;
        MtxF=newDoubleMtx(2,d);
        
        /*printf("NM=%d\n",NM);*/
        mess=strtok(Dir,",");
        /*printf("mess=%s\n",mess);*/
        for(k=0;k<NM;k++){
            if(mess==NULL){sprintf(dum1,"A problem with FIND\n");errMsgTxt(dum1);}
            messFound=bsearch(&mess,IdxFace,(size_t)IdxSize,sizeof(char *),compare);                
            if(messFound==NULL){
                MtxF->Mtx[k]=0; 
                MtxF->Mtx[k+NM]=0;  
            }else{
                strncpy(dum1,messFound[0]+pIdxFile,wIdxFile);
                dum1[wIdxFile]='\0';
                MtxF->Mtx[k]=atof(dum1);    
                strncpy(dum1,messFound[0]+pIdxPosi,wIdxPosi);
                dum1[wIdxPosi]='\0';
                MtxF->Mtx[k+NM]=atof(dum1); 
            }
            /*printf(messFound[0]);*/
            mess=strtok(NULL,",");
        }
    }
    return MtxF;
}

int makeIndex(char *Dir,char *NameIn){
    FILE *fin,*fp;
    char errmsg[STRINGLENGTH],ndat[STRINGLENGTH],dum1[STRINGLENGTH];
    char DataFile[LENGTHPATH],DirData[LENGTHPATH];
    unsigned long numfil;
    int nReturn=0,Rd_Indexfile=0,k,status;
    long offset,NM=0,iM=0,dumTime;
    Index_member *idx=NULL;
    
    BMS_INPUT bms;
    PDS_INPUT pds;
    grid_desc_sec gds;
    BDS_HEAD_INPUT bds_head;
    GRIB_HDR *gh1;
    
    errmsg[0]='\0';
    offset=0;
    fp=(FILE *)NULL;
    
    if(nReturn = init_gribhdr(&gh1,errmsg)){sprintf(dum1,"%s",errmsg);errMsgTxt(dum1);}
    if(strlen(Dir)>0 && ((Dir[strlen(Dir)-1]!='/') || (Dir[strlen(Dir)-1]!='\\'))){
        sprintf(DirData,"%s/",Dir);
    }else{
        sprintf(DirData,"%s",Dir);
    }   
    sprintf(DataFile,"%s%s",DirData,NameIn);
    /*parseIdxFormat(DataFile);*/
	if(!(fin=fopen(DataFile,"rb"))){
        sprintf(dum1,"Invalid Input File %s",DataFile);
        errMsgTxt(dum1);
    }
    status=fscanf(fin,"%s",ndat);
    if(ndat[0]=='%'){
    	status=fscanf(fin,"%s",ndat);
    }
    numfil=0;
    while(status>0)
    {
        numfil++;
        gh1->msg_length=0L;
        sprintf(DataFile,"%s%s",DirData,ndat);
        
        /*printf("Processing: %s\n",DataFile);*/
    
        if(!(fp=fopen(DataFile,"rb"))){sprintf(dum1,"Invalid File %s",ndat);errMsgTxt(dum1);}
        for(offset = 0L;nReturn==0;offset += gh1->msg_length){
            if(nReturn=grbseek(ndat,&fp,&offset,Rd_Indexfile,gh1,errmsg))
            {
                if(nReturn == 2) break;
                sprintf(dum1,"Grib_seek returned non zero stat (%d)\n\terrmsg: %s",nReturn,errmsg);
                errMsgTxt(dum1);
            }
            if (errmsg[0] != '\0')
            {
                /*printf("%s; Skip message...\n",errmsg);*/
                errmsg[0]='\0';
                gh1->msg_length=0L;
                continue;           
            }
            if (gh1->msg_length<0)
            {
                sprintf(dum1,"Error: message returned has bad length (%ld)\n",gh1->msg_length);errMsgTxt(dum1);
            }
            else if (gh1->msg_length == 0)
            {
                printf("msg_length is Zero, set offset to 1\n");
                gh1->msg_length=1L;
                continue ;
            }
            init_dec_struct(&pds,&gds,&bms,&bds_head);  
            if(nReturn=grib_dec_heads((char *)gh1->entire_msg,&pds,&gds,&bds_head,&bms,errmsg))
            {
                sprintf(dum1,"grib_dec returned non zero stat (%d)\n\terrmsg: %s\n\t%d,%s",nReturn,errmsg,offset,DataFile);
                errMsgTxt(dum1);
            }
            if (iM>=NM){
                NM+=1000;
                idx=(Index_member *)realloc(idx,sizeof(Index_member)*NM);
            }
            if(pds.usHeight1<10000){
                idx[iM].Year=(unsigned short)((pds.usCentury-1)*100+pds.usYear);
                idx[iM].Month=(unsigned char)pds.usMonth;
                idx[iM].Day=(unsigned char)pds.usDay;
                idx[iM].Hour=(unsigned char)pds.usHour;
				
				
                switch(pds.usTime_range){
					case 2:
					case 3:
					case 4:
					case 5:
						dumTime=pds.usP2;
					break;
					case 10:
						dumTime=pds.usP1*256+pds.usP2;
					break;
					default:
						dumTime=pds.usP1;
					break;
				}

                /*20-June-2005 Antonio S. Cofiño (cofinoa@yahoo.es)*/
				/*	Convert some other Time units to hours*/
				/*dumTime=pds.usTime_range==10?pds.usP1*256+pds.usP2:pds.usP1;*/
				/*Convert to hours*/
				switch(pds.usFcst_unit_id){
					case 0: /*minute*/
						dumTime/=60;
						break;
					case 1: /*hour*/
						break;
					case 2: /*day*/
						dumTime*=24;
						break;
					case 10: /*3-hour*/
						dumTime*=3;
						break;
					case 11: /*6-hour*/
						dumTime*=6;
						break;
					case 12: /*12-hour*/
						dumTime*=12;
						break;
					default :
						sprintf(dum1,"Error: WMO Code Table: 4 - unit of time not accepted (%d)\n",pds.usFcst_unit_id);
						errMsgTxt(dum1);
						break;
				}

				idx[iM].Fore    = (unsigned short)dumTime;
                idx[iM].Parm    = (unsigned char) pds.usParm_id;
                idx[iM].Subparm = (unsigned char) pds.usParm_sub;
                idx[iM].Height  = (unsigned short)pds.usHeight1;
                idx[iM].File    = (unsigned long) numfil;
                idx[iM].Pos     = (unsigned long) offset;
                iM++;
            }
        }
        ndat[0]='\0';
        status=fscanf(fin,"%s",ndat);
        nReturn=0;
        gh1->msg_length=0;
        offset=0;
        if (fp) fclose(fp);
        fp=(FILE*)NULL;
    }
    
    IdxSize=iM;
    IdxFace=(char**)malloc(sizeof(char *)*IdxSize);
    IdxFace[0]=(char *)malloc(sizeof(char)*FaceLength*IdxSize);
    for (k=0;k<IdxSize;k++){
        IdxFace[k]=&IdxFace[0][FaceLength*k];
/*        sprintf(IdxFace[k],"%04d%02d%02d%02d%06d_%03d%03d%06d_%06d%010d\n",idx[k].Year,idx[k].Month,idx[k].Day,idx[k].Hour,idx[k].Fore,idx[k].Parm,idx[k].Subparm,idx[k].Height,idx[k].File,idx[k].Pos);*/
        sprintf(IdxFace[k],IdxFormat,idx[k].Year,idx[k].Month,idx[k].Day,idx[k].Hour,idx[k].Fore,idx[k].Parm,idx[k].Subparm,idx[k].Height,idx[k].File,idx[k].Pos);
        /*fprintf(ftxt,"%s",IdxFace[k]);*/
    }
    if (idx) free(idx);
    printf("%d messages decoded\n",IdxSize);
	return 0;
    
}

