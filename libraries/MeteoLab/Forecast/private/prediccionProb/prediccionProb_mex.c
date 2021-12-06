#include "proutils.h"

void mexFunction(int nlhs, mxArray  *plhs[], int nrhs, const mxArray *prhs[]) {
	SDoubleMtx Umb[1],NAnlg[1],Anlg[1],Prdc[1],Dist[1],Ptnd[1],IndEx[1],NEx[1];
	SParamPrd Param[1];
	mxArray *Dum;
	/*int k,M,N;*/
#ifdef VERBOSE_PRO
	msgPrintf("Starting Prediccion...\n");
#endif	
	if(nrhs<4) 
		mexErrMsgTxt("Error: necesitas 4 variables de entrada");
	if(nlhs>1) 
		mexErrMsgTxt("Error: No se que hacer con mas de una salida");
	if(!mxIsStruct(prhs[3]))
		mexErrMsgTxt("Error: la variable 4 ha de ser una Estructura");
		
	
	Anlg->Ndim=mxGetNumberOfDimensions(prhs[0]);
	Anlg->Dim=(int *)mxGetDimensions(prhs[0]);
	Anlg->Mtx=mxGetPr(prhs[0]);

	Dist->Ndim=mxGetNumberOfDimensions(prhs[1]);
	Dist->Dim=(int *)mxGetDimensions(prhs[1]);
	Dist->Mtx=mxGetPr(prhs[1]);
	


	Ptnd->Ndim=mxGetNumberOfDimensions(prhs[2]);
	Ptnd->Dim=(int *)mxGetDimensions(prhs[2]);
	Ptnd->Mtx=mxGetPr(prhs[2]);

	Dum=mxGetField(prhs[3],0,"Umb");
	if(Dum==NULL)
		mexErrMsgTxt("Error: al intentar extraer el campo Umb de la estructura");
	Umb->Ndim=mxGetNumberOfDimensions(Dum);
	Umb->Dim=(int *)mxGetDimensions(Dum);
	if(Umb->Dim[0]<2) 
		mexErrMsgTxt("Error: Los Umbrales han de tener 2 filas");
	Umb->Mtx=mxGetPr(Dum);

	Dum=mxGetField(prhs[3],0,"IndEx");
	if(Dum==NULL)
		mexErrMsgTxt("Error: al intentar extraer el campo IndEx de la estructura");
	
	IndEx->Ndim=mxGetNumberOfDimensions(Dum);
	IndEx->Dim=(int *)mxGetDimensions(Dum);
	IndEx->Mtx=mxGetPr(Dum);
	
	
	Dum=mxGetField(prhs[3],0,"NumA");
	if(Dum==NULL)
		mexErrMsgTxt("Error: al intentar extraer el campo NumA de la estructura");
	NAnlg->Ndim=mxGetNumberOfDimensions(Dum);
	NAnlg->Dim=(int *)mxGetDimensions(Dum);
	NAnlg->Mtx=mxGetPr(Dum);
	
	Dum=mxGetField(prhs[3],0,"NEx");
	if(Dum==NULL)
		mexErrMsgTxt("Error: al intentar extraer el campo NEx de la estructura");
	NEx->Ndim=mxGetNumberOfDimensions(Dum);
	NEx->Dim=(int *)mxGetDimensions(Dum);
	NEx->Mtx=mxGetPr(Dum);
	Param->Umb=Umb;
	Param->IndEx=IndEx;
	Param->NAnlg=NAnlg;
	Param->NEx=NEx;
/*
	mexPrintf("Anlg(%3d %3d %3d)\n",Anlg->Dim[0],Anlg->Dim[1],Anlg->Dim[2]);
	mexPrintf("NAnlg(%3d %3d)\n",NAnlg->Dim[0],NAnlg->Dim[1]);
*/
	Prdc->Ndim=3;
	Prdc->Dim=(int *)malloc(sizeof(int)*Prdc->Ndim);
	Prdc->Dim[0]=Anlg->Dim[0];
	Prdc->Dim[1]=Ptnd->Dim[1];
	Prdc->Dim[2]=Umb->Dim[1];
	
	plhs[0]=mxCreateNumericArray(Prdc->Ndim,Prdc->Dim,mxDOUBLE_CLASS,mxREAL);
	Prdc->Mtx=mxGetPr(plhs[0]);
	
#ifdef VERBOSE_PRO	
	mexPrintf("Param->Umb[%2d](%3d %3d)\n",Param->Umb->Ndim,Param->Umb->Dim[0],Param->Umb->Dim[1]);
	mexPrintf("Param->IndEx[%2d](%3d %3d)\n",Param->IndEx->Ndim,Param->IndEx->Dim[0],Param->IndEx->Dim[1]);
	mexPrintf("Param->NumA[%2d](%3d %3d)\n",Param->NAnlg->Ndim,Param->NAnlg->Dim[0],Param->NAnlg->Dim[1]);
	mexPrintf("Anlg[%2d](%3d %3d)\n",Anlg->Ndim,Anlg->Dim[0],Anlg->Dim[1]);
	mexPrintf("Dist[%2d](%3d %3d)\n",Dist->Ndim,Dist->Dim[0],Dist->Dim[1]);
	mexPrintf("Prdc[%2d](%3d %3d %3d)\n",Prdc->Ndim,Prdc->Dim[0],Prdc->Dim[1],Prdc->Dim[2]);
	mexPrintf("Ptnd[%2d](%3d %3d)\n",Ptnd->Ndim,Ptnd->Dim[0],Ptnd->Dim[1]);
	mexPrintf("Entering on PrediccionProb\n");
#endif
	prediccionProb(Prdc,Anlg,Dist,Ptnd,Param);
	free(Prdc->Dim);	
}
