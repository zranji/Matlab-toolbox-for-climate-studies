#include "proutils.h"

void mexFunction(int nlhs, mxArray  *plhs[], int nrhs, const mxArray *prhs[]) {
	SDoubleMtx Umb[1],Anlg[1],NAnlg[1],Prob[1],Pesos[1];
	int k;
	
	if(nrhs<3 | nrhs>3) 
		mexErrMsgTxt("Error: necesitas 3 variables de entrada");
	if(nlhs>1) 
		mexErrMsgTxt("Error: No se que hacer con mas de una salida");
	
	Umb->Ndim=mxGetNumberOfDimensions(prhs[0]);
	Umb->Dim=(int *)mxGetDimensions(prhs[0]);
	if(Umb->Dim[0]<1) 
		mexErrMsgTxt("Error: Los Umbrales ha de tener 1 fila");
	
	Anlg->Ndim=mxGetNumberOfDimensions(prhs[1]);
	Anlg->Dim=(int *)mxGetDimensions(prhs[1]);
	
	NAnlg->Ndim=mxGetNumberOfDimensions(prhs[2]);
	NAnlg->Dim=(int *)mxGetDimensions(prhs[2]);
/*
	mexPrintf("Anlg(%3d %3d %3d)\n",Anlg->Dim[0],Anlg->Dim[1],Anlg->Dim[2]);
	mexPrintf("NAnlg(%3d %3d)\n",NAnlg->Dim[0],NAnlg->Dim[1]);
*/
	if(NAnlg->Dim[0]!=Anlg->Dim[0] | NAnlg->Dim[1]!=Anlg->Dim[1])
		mexErrMsgTxt("Error: El numero de filas y columnas de NAnlg y Anlg han de ser iguales");
	
	Prob->Ndim=3;
	Prob->Dim=(int *)malloc(sizeof(int)*Prob->Ndim);
	Prob->Dim[0]=Anlg->Dim[0];
	Prob->Dim[1]=Anlg->Dim[1];
	Prob->Dim[2]=Umb->Dim[1];
	Pesos->Mtx=NULL;
	
	plhs[0]=mxCreateNumericArray(Prob->Ndim,Prob->Dim,mxDOUBLE_CLASS,mxREAL);
	
	
	Prob->Mtx=mxGetPr(plhs[0]);	
	Umb->Mtx=mxGetPr(prhs[0]);
	Anlg->Mtx=mxGetPr(prhs[1]);
	NAnlg->Mtx=mxGetPr(prhs[2]);
/*	
	mexPrintf("Umb(%3d %3d)\n",Umb->Dim[0],Umb->Dim[1]);
	mexPrintf("Anlg(%3d %3d %3d)\n",Anlg->Dim[0],Anlg->Dim[1],Anlg->Dim[2]);
	mexPrintf("NAnlg(%3d %3d)\n",NAnlg->Dim[0],NAnlg->Dim[1]);
	mexPrintf("Prob(%3d %3d %3d)\n",Prob->Dim[0],Prob->Dim[1],Prob->Dim[2]);
*/
	getprctile(Prob,Umb,Anlg,NAnlg,Pesos);
	free(Prob->Dim);	
}
