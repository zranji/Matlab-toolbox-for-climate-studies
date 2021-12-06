#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <errno.h>
#include <fcntl.h>


    #include "matrix.h"
    #include "mex.h"
/*#define PRINTDEBUG 1*/

#include "unzip.h"
#include "zlib.h"
#define CASESENSITIVITY (1)
#define WRITEBUFFERSIZE (8192)
#define MIN(A,B) A<B?A:B


typedef struct SDoubleMtx{
    double *Mtx;
    int *Dim;
    int Ndim;
#ifdef MATLAB_MEX_FILE
    mxArray *MatArray;
#endif
} SDoubleMtx;

static unzFile uf;
static char zipName[WRITEBUFFERSIZE];
static unsigned char *BUF=NULL;
static unsigned int NBUF=0;
static unsigned int INITIALIZED=0;

/*
 * WhichEndian.c
 
 * returns 1 if Big Endian  ( MSB LSB )
 * returns 0 if Little Endian ( LSB MSB )
 */
int WhichEndian()
{
  unsigned short i;
  
  i=0x01;  
  return( ( (int) *(char *)(&i) == 0) );
}

/*
 * LittleEndian.c
 
 * returns 0 if Big Endian  ( MSB LSB )
 * returns 1 if Little Endian ( LSB MSB )
 */
int LittleEndian()
{
  return( WhichEndian() == 0 );
}

/*
 * BigEndian.c
 
 * returns 1 if Big Endian  ( MSB LSB )
 * returns 0 if Little Endian ( LSB MSB )
 */
int BigEndian()
{
  return( WhichEndian() );
}



void copyBytes(unsigned char *orig,unsigned char *dest,int nb,int swp){
    int j;
    if(swp){
        for(j=0;j<nb;j++) dest[nb-j-1]=orig[j];
    }else{
        for(j=0;j<nb;j++) dest[j]=orig[j];
    }
}
void swapBytes(unsigned char *orig,int nb,int N){
    int i,j,k,m,NN;
    unsigned char dum;
    m=nb/2;
    NN=N*nb;
    for(i=0;i<NN;i+=nb){
        k=i+nb-1;
        for(j=0;j<m;j++){
            dum=orig[i+j];
            orig[i+j]=orig[k-j];
            orig[k-j]=dum;
        }

    }
}

void cleanup(void) {
     if(BUF!=NULL)
      mxFree(BUF);
}

void mexFunction(int nlhs, mxArray  *plhs[], int nrhs, const mxArray *prhs[]) {
    char *fin=NULL,*fout=NULL,*dir=NULL,*filename=NULL,*filetype;
    int dim[]={0,0};
    
    int error=0;
    int err = UNZ_OK;
    char filename_inzip[WRITEBUFFERSIZE];
    unz_file_info file_info;
    size_t size_buf = 0;
    /*unz_s* s;*/
    int N;
    /*unsigned char *buf;*/
    unsigned int nbr, nb,NUMDIAS,i,n;
	int SWAPFILES;  

    int BINFILE=1;
    short *sDum;
    float *fDum;
    int *iDum;
    unsigned char Dum[8];
	double *array;
    char *finalPtr,*inicialPtr;
    char *tok=" \t\n\r\,;";
    sDum=(short *)Dum;
    fDum=(float *)Dum;
    iDum=(int *)Dum;

    if(nrhs<2)
        mexErrMsgTxt("You need 2 inputs.\n.");
    if (!(mxIsChar(prhs[0]))){
        mexErrMsgTxt("Input 1 must be of type string.\n.");
    }
    dir=mxArrayToString(prhs[0]);
    
    if (!(mxIsChar(prhs[1]))){
        mexErrMsgTxt("Input 2 must be of type string.\n.");
    }
    filename=mxArrayToString(prhs[1]);

    if(nrhs>2){
     if (!(mxIsChar(prhs[2]))){
        mexErrMsgTxt("Input 3 must be of type string.\n.");
     }
     filetype=mxArrayToString(prhs[2]);
     if(strcmp(filetype,"ASC")==0){
      BINFILE=0;
     }
     if(nrhs>3){
         if (!(mxIsChar(prhs[3]))){
            mexErrMsgTxt("Input 4 must be of type string.\n.");
         }
         tok=mxArrayToString(prhs[3]);
     }
    }

    /*
	MtxF=(SDoubleMtx *)mxMalloc(sizeof(SDoubleMtx));
    MtxF->Ndim=2;
    MtxF->Dim=(int *)mxMalloc(sizeof(int)*MtxF->Ndim);
    MtxF->Dim[0]=0;MtxF->Dim[1]=0;
    */
	
    for(i=0;i<nlhs;i++)
        plhs[i]=mxCreateNumericArray(2,dim,mxDOUBLE_CLASS,mxREAL);

    if(strcmp(dir,zipName)!=0){
    /*  printf("%s,%s\n",dir,zipName);*/
        unzClose(uf);
        uf = unzOpen(dir);
        strcpy(zipName,dir);
    }
    
    if (unzLocateFile(uf,filename,1)!=UNZ_OK)
    {
        /*printf("file %s not found in the zipfile (%s)\n",filename,dir);*/
        error=1;
        return;
    }

    err = unzGetCurrentFileInfo(uf,&file_info,filename_inzip,sizeof(filename_inzip),NULL,0,NULL,0);
    if (err!=UNZ_OK)
    {
        /*printf("error %d with zipfile (%s) in unzGetCurrentFileInfoe\n",err,dir);*/
        error=1;
        return;

    }
    
    err = unzOpenCurrentFile(uf);
    if (err!=UNZ_OK)
    {
        /*printf("error %d with zipfile (%s) in unzOpenCurrentFile\n",err,dir);*/
        error=1;
        return;
    }
    
    size_buf=file_info.uncompressed_size;
    
    if(INITIALIZED==0){
     mexAtExit(cleanup);
     BUF=(unsigned char *)mxMalloc(sizeof(unsigned char)*32768);
     mexMakeMemoryPersistent(BUF);
     NBUF=32768;
     INITIALIZED=1;
     #ifdef PRINTDEBUG
     printf("Initialized\n");
     #endif
   }
    
    if(size_buf>NBUF){
        BUF=(unsigned char *)mxRealloc(BUF,sizeof(unsigned char)*size_buf);
        mexMakeMemoryPersistent(BUF);
        NBUF=size_buf;
     #ifdef PRINTDEBUG
     printf("Reallocating(%d)\n",NBUF);
     #endif
    }
    /*
    s=(unz_s*)file;
    s->pfile_in_zip_read.;
    ^*/
    
    nbr = unzReadCurrentFile(uf,BUF,size_buf);
    err=unzCloseCurrentFile(uf);
    if (err!=UNZ_OK)
    {
        /*printf("error %d with zipfile (%s) in unzOpenCurrentFile\n",err,dir);*/
        error=1;
        return;
    }
    #ifdef PRINTDEBUG
    printf("[%d]>[%d]:[%d] %s\n",file_info.uncompressed_size,file_info.compressed_size,nbr,filename_inzip);
    #endif
    
    if(nbr<(size_buf)){
        printf("Error Reading Data [size_buf=%d]:[nbr=%d]",size_buf,nbr);
        return;
    }
    
    N=0;
    for(i=N;i<size_buf;i++){
        if(BUF[i]=='\n') break;
    }
    BUF[i]='\0';

    #ifdef PRINTDEBUG
    printf("%s\n",&BUF[N]);
    #endif
    
    plhs[0]=mxCreateString(&BUF[N]);
    N=i+1;
    if(nlhs<2){ 
/*        if(buf!=NULL)
            mxFree(buf);
*/
     return;
    }
    
    for(i=N;i<size_buf;i++){
        if(BUF[i]=='\n') break;
    }
    BUF[i]='\0';

    #ifdef PRINTDEBUG
    printf("%s\n",&BUF[N]);
    #endif

    plhs[1]=mxCreateString(&BUF[N]);
    N=i+1;
    if(nlhs<3){ 
/*        if(buf!=NULL)
            mxFree(buf);
*/
     return;
    }
    
    
    if(BINFILE){

        SWAPFILES=LittleEndian();

        nb=sizeof(float);
        NUMDIAS=(nbr-N)/nb;
        
		dim[0]=NUMDIAS;dim[1]=1;
        plhs[2]=mxCreateNumericArray(2,dim,mxDOUBLE_CLASS,mxREAL);
        array=mxGetPr(plhs[2]);
        
	    if(SWAPFILES)
    		swapBytes(&BUF[N],nb,NUMDIAS);
        
    #ifdef PRINTDEBUG
    printf("nb=%d:NUMDIAS=%d:nbr=%d:%s\n",nb,NUMDIAS,nbr,SWAPFILES?"LE":"BE");
    #endif
		n=0;
		for(i=N;i<nbr;i+=nb){
            array[n]=((double)(*(float *)&BUF[i]));
			/*
            array[n]=0.0;
            */
    #ifdef PRINTDEBUG
            if(n<1000)
             printf("%d=%g [%x,%x,%x,%x]\n",n,array[n],BUF[i+0],BUF[i+1],BUF[i+2],BUF[i+3]);
/*
            if(fmod(n,100)==0){
            printf("\n");
             //printf("nb=%d:n=%d:i=%d:nbr=%d:v=%g\n",nb,n,i,nbr,array[n]);
            }
*/
    #endif
            n++;
        }

        /*
		n=0;
        for(i=N;i<nbr;i+=nb){
            copyBytes(&buf[i],Dum,nb,SWAPFILES);
            array[n]=((double)fDum[0]);
            n++;
        }
		*/
    }else{
        int psize=0;
        double *p=NULL,a=0.0;
        n=0;
        inicialPtr=&BUF[N];
        a=strtod(inicialPtr,&finalPtr);
        while(inicialPtr!=finalPtr){
            a=strtod(inicialPtr,&finalPtr);
            if(n>=psize){
                psize+=1024;
                p=(double *)mxRealloc(p,sizeof(double)*psize);
            }
            p[n]=a;
            n++;
            inicialPtr=finalPtr;
            a=strtod(inicialPtr,&finalPtr);
        }
        dim[0]=n;dim[1]=1;
        plhs[2]=mxCreateNumericArray(2,dim,mxDOUBLE_CLASS,mxREAL);
        array=mxGetPr(plhs[2]);
        for(i=0;i<n;i++) array[i]=p[i];
        if(p!=NULL) mxFree(p);
    }
/*
    if(buf!=NULL)
        mxFree(buf);
*/
}
