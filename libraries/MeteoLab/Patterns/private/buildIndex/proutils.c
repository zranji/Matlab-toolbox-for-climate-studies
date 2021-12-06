#include "proutils.h"
void errMsgTxt(const char *Msg){
#ifdef MATLAB_MEX_FILE
        mexErrMsgTxt(Msg);
#else
        fprintf(stderr,Msg);
        exit(1);
#endif  
}
void msgPrintf(const char *Msg,...){
        /*va_list(arglist);*/
        /*va_start(arglist, Msg);*/

#ifdef MATLAB_MEX_FILE
        mexPrintf(Msg);
#else
        fprintf(stdout,Msg);
        /*exit(0);*/
#endif  
}

SDoubleMtx *newDoubleMtx(int Nd,int *d){
    SDoubleMtx *DoubleMtx;
    long N=1,k;
    DoubleMtx=(SDoubleMtx *)malloc(sizeof(SDoubleMtx));

    DoubleMtx->Ndim=Nd;
    DoubleMtx->Dim=(int *)malloc(sizeof(int)*Nd);
    for(k=0;k<Nd;k++){
        DoubleMtx->Dim[k]=d[k];
        N*=d[k];
    }
#ifdef MATLAB_MEX_FILE

    DoubleMtx->MatArray=mxCreateNumericArray(Nd,d,mxDOUBLE_CLASS,mxREAL);

    DoubleMtx->Mtx=mxGetPr(DoubleMtx->MatArray);

#else   

    DoubleMtx->Mtx=(double *)malloc(sizeof(double)*N);

#endif  

    return DoubleMtx;

    
}

void delDoubleMtx(SDoubleMtx *DoubleMtx){
    free(DoubleMtx->Mtx);
    free(DoubleMtx->Dim);
    free(DoubleMtx);
}
