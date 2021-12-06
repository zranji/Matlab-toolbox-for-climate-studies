#include <stdio.h>              /* standard I/O header file          */
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <ctype.h>
#include "mex.h"
#include "./gribsimp/grib.h"               /* GRIB encoder/decoder structures   */
#include "./gribsimp/tables.h"
int grib_seek (char *, char **, long *, unsigned long *);
void gbyte(char *, unsigned long *, unsigned long * , unsigned long );
int gribgetpds(char *, PDS_INPUT *);
int gribgetgds(char *, grid_desc_sec *);
int gribgetbms(char *, BMS_INPUT *bms, int ,unsigned long );
int gribgetbds(char *, float **, short ,struct BDS_HEAD_INPUT *,grid_desc_sec *, BMS_INPUT *);
int gribgetbds_DOUBLE(char *, double **, short ,struct BDS_HEAD_INPUT *,grid_desc_sec *, BMS_INPUT *);
int gribdec1(char *, struct PDS_INPUT *,struct grid_desc_sec *, struct BDS_HEAD_INPUT *,      BMS_INPUT *bms, float **);
int gribdec1_DOUBLE(char *, struct PDS_INPUT *,struct grid_desc_sec *, struct BDS_HEAD_INPUT *,      BMS_INPUT *bms, double **);
void init_struct (PDS_INPUT *, grid_desc_sec *, BMS_INPUT *, BDS_HEAD_INPUT *);
void prt_err(int);
int apply_bitmap ( BMS_INPUT *, float **, float , BDS_HEAD_INPUT *);    
int apply_bitmap_DOUBLE ( BMS_INPUT *, double **, double , BDS_HEAD_INPUT *);    

#ifdef MATLAB_MEX_FILE
#define MYMALLOC(tam) mxMalloc((tam))
#else
#define MYMALLOC(tam) malloc((tam))
#endif

#define FILL_VALUE (float)fmod(0,0) /* missing dta pts           */
#define FILL_VALUE_DOUBLE (double)fmod(0,0) /* missing dta pts           */
typedef struct MessageStruct{
    BMS_INPUT       bms;
    PDS_INPUT       pds;
    grid_desc_sec   gds;
    BDS_HEAD_INPUT  bdsHead;
}MessageStruct;

mxArray *AssignMessToMatlab(MessageStruct);
mxArray *AssignPDSToMatlab(PDS_INPUT);
mxArray *AssignGDSToMatlab(grid_desc_sec);
mxArray *AssignBMSToMatlab(BMS_INPUT);
mxArray *AssignBDSToMatlab(BDS_HEAD_INPUT);

mxArray *AssignGDSHeadToMatlab(GDS_HEAD_INPUT);
mxArray *AssignGDSLatLonToMatlab(GDS_LATLON_INPUT);
mxArray *AssignGDSLambertToMatlab(GDS_LAM_INPUT);
mxArray *AssignGDSPolarToMatlab(GDS_PS_INPUT);
mxArray *AssignGDSMercatorToMatlab(mercator);
mxArray *AssignGDSSpaceViewToMatlab(space_view);

mxArray *ushortTomxArray(unsigned short );
mxArray *uintTomxArray(unsigned int );
mxArray *ulongTomxArray(unsigned long );

mxArray *shortTomxArray(short );
mxArray *intTomxArray(int );
mxArray *longTomxArray(long );

mxArray *floatTomxArray(float);
/*int readgrib(FILE *,int *,float **,int *,int *,int *,MessageStruct *);*/  
int readgrib(char *,long *,float **,int *,int *,int *,MessageStruct *);
int readgrib_DOUBLE(char *,long *,double **,int *,int *,int *,MessageStruct *);
