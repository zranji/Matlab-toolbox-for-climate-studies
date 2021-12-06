#include "readmessage.h"
int debug=0;
#define VERBOSE 0

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray *prhs[] )
     
{ 
    
	char *InFile;
    unsigned short *DumStr;
	double *A,*offset;
    float *y=NULL;
    long m=0,n=0,i,eof=1,j,chLon,NumMes,flag,num;
   	MessageStruct Mess;

	if (nrhs != 2) { 
		mexErrMsgTxt("Two input arguments required."); 
    } else if (nlhs > 4) {
		mexErrMsgTxt("Too many output arguments."); 
    } 
    
	offset = mxGetPr(prhs[1]);
    NumMes=mxGetM(prhs[1]);
    InFile=mxArrayToString(prhs[0]);
/*
	mexPrintf("InFile: %s\n",InFile);
*/
/*
    DumStr = (unsigned short *)mxGetPr(prhs[0]); 
    offset = mxGetPr(prhs[1]);
    chLon=mxGetN(prhs[0]);
	NumMes=mxGetM(prhs[1]);
	InFile=(char *)malloc(sizeof(char)*(chLon+1));
	for(i=0;i<chLon;i++) InFile[i]=(char)DumStr[i];
	
	InFile[chLon]='\0';
*/
    num=(int)offset[0];
	
	eof=readgrib(InFile,&num,&y,(int *)&m,(int *)&n,(int *)&flag,&Mess);

    
	mxFree(InFile);
	
	if(eof==1){m=0;n=0;}
	plhs[0] = mxCreateDoubleMatrix(m, n, mxREAL); 
	A = mxGetPr(plhs[0]);
	for(i=0;i<m;i++)
		for(j=0;j<n;j++)
			A[i+j*m]=(double)y[i*n+j];

	if (nlhs > 1)
		plhs[1] = AssignMessToMatlab(Mess);
	if (nlhs > 2){
		plhs[2] = mxCreateDoubleMatrix(1, 1, mxREAL);
		offset=mxGetPr(plhs[2]);
		offset[0]=(double)num;
	}
	if (nlhs > 3){
		plhs[3] = mxCreateDoubleMatrix(1, 1, mxREAL);
		offset=mxGetPr(plhs[3]);
		offset[0]=(double)eof;
	}
	
	if(y!=NULL) free(y);

	return;
    
}
