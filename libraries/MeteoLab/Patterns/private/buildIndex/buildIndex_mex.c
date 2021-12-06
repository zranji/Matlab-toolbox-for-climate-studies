#include "proutils.h"

void mexFunction(int nlhs, mxArray  *plhs[], int nrhs, const mxArray *prhs[]) {
    char *fin=NULL,*fout=NULL,*dir=NULL,*cmd=NULL;
    SDoubleMtx *MtxF;
    if(nrhs<4)
        mexErrMsgTxt("You need 4 inputs.\n.");
    if (!(mxIsChar(prhs[0]))){
        mexErrMsgTxt("Input 1 must be of type string.\n.");
    }
    cmd=mxArrayToString(prhs[0]);
    
    if (!(mxIsChar(prhs[1]))){
        mexErrMsgTxt("Input 2 must be of type string.\n.");
    }
    dir=mxArrayToString(prhs[1]);
    
    if (!(mxIsChar(prhs[2]))){
        mexErrMsgTxt("Input 3 must be of type string.\n.");
    }
    fin=mxArrayToString(prhs[2]);
    
    if (!(mxIsChar(prhs[3]))){
        mexErrMsgTxt("Input 4 must be of type string.\n.");
    }
    fout=mxArrayToString(prhs[3]);
    MtxF=buildIndex(cmd,dir,fin,fout);
    if(MtxF!=NULL){
        /*printf("%d ",MtxF->Ndim);*/
        /*printf("%d %d\n",MtxF->Dim[0],MtxF->Dim[1]);*/
        plhs[0]=MtxF->MatArray;
    }
    mxFree(cmd);
    mxFree(dir);
    mxFree(fin);
    mxFree(fout);
}
