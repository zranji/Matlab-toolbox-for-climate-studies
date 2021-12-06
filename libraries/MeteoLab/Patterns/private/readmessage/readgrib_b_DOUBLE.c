#include "readmessage.h"
int readgrib_DOUBLE(char *fid,long *offset,double **grib_data,int *m,int *n,int *scan,MessageStruct *Mess){
	int nReturn;
	unsigned long 		msg_length;
	char 		*curr_ptr=NULL;
		
	
	if (nReturn=grib_seek(fid, &curr_ptr, offset, &msg_length)){
		if(nReturn==3) return 1;
	}
	
	init_struct(&Mess->pds,&Mess->gds,&Mess->bms,&Mess->bdsHead);
	if (nReturn = gribdec1_DOUBLE(curr_ptr,&Mess->pds,&Mess->gds,&Mess->bdsHead,&Mess->bms,&grib_data[0]))
	{
		prt_err(nReturn);  /* Print error code and message */
		printf("error=%d----->%d\n",nReturn,Mess->gds.head.usData_type);
#ifdef MATLAB_MEX_FILE
		mexErrMsgTxt("error on MEX-FILE READGRIB\n\n");
#else 
		exit(0);
#endif
	}
	if (Mess->bms.uslength>0)
      	if (nReturn=apply_bitmap_DOUBLE(&Mess->bms, &grib_data[0], FILL_VALUE_DOUBLE, &Mess->bdsHead))
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

