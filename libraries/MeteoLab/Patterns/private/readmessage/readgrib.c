#include "readmessage.h"
int debug=0;
void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray *prhs[] )
     
{ 
    
	char *InFile;
    unsigned short *DumStr;
	double *A,*offset;
    float *y=NULL;
    long m,n,i,eof,j,chLon,NumMes,flag,num;
   	MessageStruct Mess;

	if (nrhs != 2) { 
		mexErrMsgTxt("Two input arguments required."); 
    } else if (nlhs > 4) {
		mexErrMsgTxt("Too many output arguments."); 
    } 
    
    DumStr = (unsigned short *)mxGetPr(prhs[0]); 
    offset = mxGetPr(prhs[1]);
    chLon=mxGetN(prhs[0]);
	NumMes=mxGetM(prhs[1]);
	InFile=(char *)malloc(sizeof(char)*(chLon+1));
	for(i=0;i<chLon;i++) InFile[i]=(char)DumStr[i];
	
	InFile[chLon]='\0';
    num=(int)offset[0];
	eof=readgrib(InFile,&num,&y,&m,&n,&flag,&Mess);
    free(InFile);
  
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
int readgrib(char *InFile,int *offset,float **grib_data,int *m,int *n,int *scan,MessageStruct *Mess){
	int nReturn;
	int 		msg_length;
	char 		*curr_ptr=NULL;
		
	
	if (nReturn=grib_seek(InFile, &curr_ptr, offset, &msg_length)){
		if(nReturn==3) return 1;
	}
	
	init_struct(&Mess->pds,&Mess->gds,&Mess->bms,&Mess->bdsHead);
	if (nReturn = gribdec1(curr_ptr,&Mess->pds,&Mess->gds,&Mess->bdsHead,&Mess->bms,&grib_data[0]))
	{
		prt_err(nReturn);  /* Print error code and message */
		printf("error=%d----->%d\n",nReturn,Mess->gds.head.usData_type);
#ifdef MATLAB_MEX_FILE
		mexErrMsgTxt("error on MEX-FILE READGRIB\n\n");
#else 
		exit(0);
#endif
	}
	switch(Mess->gds.head.usData_type){
     case 0:    /* Lat/Lon Grid */
     case 4:    /* Gaussian Latitude/Longitude grid */
     case 10:   /* Rotated Lat/Lon */
     case 14:   /* Rotated Gaussian */
     case 20:   /* Stretched Lat/Lon */
     case 24:   /* Stretched Gaussian */
     case 30:   /* Stretched and Rotated Lat/Lon */
     case 34:   /* Stretched and Rotated Gaussian */
       *n = Mess->gds.llg.usNi;
	   *m = Mess->gds.llg.usNj;
       *scan=(int)Mess->gds.llg.usScan_mode;
	   break;
     case 1:  /* Mercator Grid */
       *n = Mess->gds.merc.cols;
	   *m = Mess->gds.merc.rows; 
       *scan=(int)Mess->gds.merc.usScan_mode;
       break;
     case 3:  /* Lambert Conformal */
     case 8:  /* Albers equal-area */
     case 13: /* Oblique Lambert Conformal */
       *n = Mess->gds.lam.iNx;
	   *m = Mess->gds.lam.iNy; 
       *scan=(int)Mess->gds.lam.usScan_mode;
       break;
     case 5:  /* Polar Stereographic */
       *n = Mess->gds.pol.usNx; 
	   *m = Mess->gds.pol.usNy; 
       *scan=(int)Mess->gds.pol.usScan_mode;
       break;
     
	}
	
	if(curr_ptr!=NULL){free(curr_ptr);}
	return 0;
}

