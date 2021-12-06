#include "proutils.h"

void mexFunction(int nlhs, mxArray  *plhs[], int nrhs, const mxArray *prhs[]) {
	SDoubleMtx Anlg[1],Dist[1],PRO[1],OBJ[1];
	double *NP;
	if(nrhs<4) 
		mexErrMsgTxt("Error: necesitas 4 variables de entrada");
	if(nlhs>2) 
		mexErrMsgTxt("Error: No se que hacer con mas de dos salida");
	
	PRO->Ndim=mxGetNumberOfDimensions(prhs[0]);
	PRO->Dim=(int *)mxGetDimensions(prhs[0]);
	
	OBJ->Ndim=mxGetNumberOfDimensions(prhs[1]);
	OBJ->Dim=(int *)mxGetDimensions(prhs[1]);

	if(OBJ->Dim[1] != PRO->Dim[1])
		mexErrMsgTxt("Error: El numero de columnas del primer y segundo argumento han de ser iguales");

	
/*
	mexPrintf("Anlg(%3d %3d %3d)\n",Anlg->Dim[0],Anlg->Dim[1],Anlg->Dim[2]);
	mexPrintf("NAnlg(%3d %3d)\n",NAnlg->Dim[0],NAnlg->Dim[1]);
*/
	
	NP=mxGetPr(prhs[2]);	
		
	Anlg->Ndim=2;
	Anlg->Dim=(int *)malloc(sizeof(int)*Anlg->Ndim);
	Anlg->Dim[0]=PRO->Dim[0];
	Anlg->Dim[1]=(int)NP[0];
	
	plhs[0]=mxCreateNumericArray(Anlg->Ndim,Anlg->Dim,mxDOUBLE_CLASS,mxREAL);
	
	Dist->Ndim=2;
	Dist->Dim=(int *)malloc(sizeof(int)*Dist->Ndim);
	Dist->Dim[0]=PRO->Dim[0];
	Dist->Dim[1]=(int)NP[0];
	
	if(nlhs>1)
		plhs[1]=mxCreateNumericArray(Dist->Ndim,Dist->Dim,mxDOUBLE_CLASS,mxREAL);
	
	
	Anlg->Mtx=mxGetPr(plhs[0]);	
	if(nlhs>1)
		Dist->Mtx=mxGetPr(plhs[1]);
	else
		Dist->Mtx=NULL;
	PRO->Mtx=mxGetPr(prhs[0]);
	OBJ->Mtx=mxGetPr(prhs[1]);
/*	
	mexPrintf("PRO(%3d %3d)\n",PRO->Dim[0],PRO->Dim[1]);
	mexPrintf("OBJ(%3d %3d)\n",OBJ->Dim[0],OBJ->Dim[1]);
	mexPrintf("Anlg(%3d %3d)\n",Anlg->Dim[0],Anlg->Dim[1]);
	mexPrintf("Dist(%3d %3d)\n",Dist->Dim[0],Dist->Dim[1]);
*/
	/*if(nrhs>3) 
		D=(double)(*mxGetPr(prhs[3]));
	else
		D=2.;

	if(D==2){
		knn(Anlg,Dist,PRO,OBJ,1);
	}else if(D==INF){
		knn_norma(Anlg,Dist,PRO,OBJ,1);
	}else{
		knn_inf(Anlg,Dist,PRO,OBJ,1);
	}
	*/
	knn(Anlg,Dist,PRO,OBJ,1);
	free(Anlg->Dim);	
	free(Dist->Dim);	
}
