#include "proutils.h"
int static compare( const void *arg1, const void *arg2 )
{
    double a,b;
    a=((double *)arg1)[0];
    b=((double *)arg2)[0];
    if(a>b)
        return 1;
    else if(b>a)
        return -1;
    else 
        return 0;
}

void getprctile(SDoubleMtx *Prob,SDoubleMtx *Umb,SDoubleMtx *Anlg,SDoubleMtx *NAnlg,SDoubleMtx *Pesos){
    
    int d1,d2,d3,l1,l2,l3,N,u,dU,Nv=0;
    double nan,dt;
    double *DUMMY=NULL;
    nan=fmod(0.0,0.0);
    d1=Anlg->Dim[0];d2=Anlg->Dim[1];
    if(Anlg->Ndim==3)
        d3=Anlg->Dim[2];
    else
        d3=1;
    
    dU=Umb->Dim[1];
    /*DUMMY=(double *)malloc(sizeof(double)*Nv);*/
    #ifdef VERBOSE_PRO  
        mexPrintf("\td1=%d,d2=%d,d3=%d)\n",d1,d2,d3);
    #endif
    for(l1=0;l1<d1;l1++){
         for(l2=0;l2<d2;l2++){
             N=0;
             for(l3=0;l3<d3;l3++){
                dt=Anlg->Mtx[l3*d2*d1+l2*d1+l1];
                /*
                mexPrintf("%3d %3d %3d %8g %8g %1d\n",l1,l2,l3,dt,nan,memcmp(&dt,&nan,sizeof(double)));
                */
                if(memcmp(&dt,&nan,sizeof(double))==0) 
                    continue;
            /*  #ifdef VERBOSE_PRO  
                    mexPrintf("\t\t(%d,%d,%d)\n",l1,l2,l3);
                #endif*/
                if(N>=Nv){ 
                    Nv+=100;
                    DUMMY=(double *)realloc(DUMMY,sizeof(double)*Nv);
                }
                DUMMY[N]=dt;                
                N++;
                if(N>=NAnlg->Mtx[l2*d1+l1]) break;
             }
             qsort(DUMMY,(size_t)N,sizeof(double),compare);
             
             for(u=0;u<dU;u++){
                 if(N==0) Prob->Mtx[u*d2*d1+l2*d1+l1]=nan;
                 else Prob->Mtx[u*d2*d1+l2*d1+l1]=DUMMY[(int)(Umb->Mtx[u]*(double)(N-1))];
             } 
         }
    }
    if(DUMMY) free(DUMMY);
    #ifdef VERBOSE_PRO  
        mexPrintf("\t\tExiting rellenaProb...\n",l1,l2,l3);
    #endif
    
}
