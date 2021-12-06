
#ifndef __proutils_h
#define __proutils_h 1

#include <float.h>
#include <memory.h>

#ifdef MATLAB_MEX_FILE
	/*#include "matlab.h"*/
	#include "matrix.h"
	#include "mex.h"
	#include <math.h>
	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>
	
#else 
	#include <math.h>
	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>
#endif

typedef struct SDoubleMtx{
	double *Mtx;
	int *Dim;
	int Ndim;

#ifdef MATLAB_MEX_FILE

	mxArray *MatArray;

#endif
} SDoubleMtx;

typedef struct SParamPrd{
	SDoubleMtx *Umb;
	SDoubleMtx *IndEx;
	SDoubleMtx *NEx;
	SDoubleMtx *NAnlg;
} SParamPrd;

typedef struct SParamClmtPrd{
	SDoubleMtx *Umb;
	SDoubleMtx *Ind;
	SDoubleMtx *N;
} SParamClmtPrd;

typedef struct SDomain{
	SDoubleMtx *Par;
	SDoubleMtx *Tim;
	SDoubleMtx *Lvl;
	SDoubleMtx *Lat;
	SDoubleMtx *Lon;
	SDoubleMtx *Lop;
	SDoubleMtx *Nod;

} SDomain;

void rellenaProb(SDoubleMtx *,SDoubleMtx *,SDoubleMtx *,SDoubleMtx *,SDoubleMtx *);
void knn(SDoubleMtx *,SDoubleMtx *,SDoubleMtx *,SDoubleMtx *,int );
void knn_norma(SDoubleMtx *,SDoubleMtx *,SDoubleMtx *,SDoubleMtx *,int );

void knn_inf(SDoubleMtx *,SDoubleMtx *,SDoubleMtx *,SDoubleMtx *,double );

void prediccionProb(SDoubleMtx *,SDoubleMtx *,SDoubleMtx *,SDoubleMtx *,SParamPrd *);
void prediccionDetPercentil(SDoubleMtx *,SDoubleMtx *,SDoubleMtx *,SDoubleMtx *,SParamPrd *);
void prediccionClmtProb(SDoubleMtx *,SDoubleMtx *,SParamPrd *);
void errMsgTxt(const char *);
void msgPrintf(const char *,...);
SDoubleMtx *ReadFile(char *);

SDoubleMtx *readAscData(char *,double);

SDoubleMtx *getFields(char *,int *,int );
SDoubleMtx *getCP(char *,char *);
long NumCharsOnRow(FILE *);
long NumDouOnRow(char *,long );
SDoubleMtx *readFile(char *);
SDoubleMtx *newDoubleMtx(int ,int *);
void delDoubleMtx(SDoubleMtx *DoubleMtx);
int findMess(float **,char *,int ,int ,int , int );
SDomain *readDomain(char *);
SDoubleMtx *extractDmn(char *,char *);
#endif
