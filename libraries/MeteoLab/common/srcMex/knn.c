#include "proutils.h"

int compare( const void *arg1, const void *arg2 );

void knn(SDoubleMtx *Anlg,SDoubleMtx *Dist,SDoubleMtx *PRO,SDoubleMtx *OBJ,int Type){
    int register lp,lo,l2,DO,d2,DP,N;
    double *dum1,dum2,*dist,*P,*O,DBL_NAN;
	DBL_NAN=fmod(0.0,0.0);
    O=OBJ->Mtx;
    P=PRO->Mtx;
    DP=PRO->Dim[0];
    d2=OBJ->Dim[1];
    DO=OBJ->Dim[0];
    N=Anlg->Dim[1];
    dum1=(double *)malloc(sizeof(double)*d2);
    dist=(double *)malloc(sizeof(double)*DO*2);
    for(lp=0;lp<DP;lp++){
        for(l2=0;l2<d2;l2++){
            /*dum1[l2]=PRO->Mtx[l2*DP+lp];*/
            dum1[l2]=P[l2*DP+lp];
        }
        for(lo=0;lo<DO;lo++){
            dist[lo*2]=0;
            for(l2=0;l2<d2;l2++){
                /*dum2=dum1[l2]-OBJ->Mtx[l2*DO+lo]; */
                dum2=dum1[l2]-O[l2*DO+lo];  
                dist[lo*2]+=dum2*dum2; /*Tipo de norma*/
            }
            dist[lo*2+1]=lo+1;
        }

        qsort( (void *)dist, (size_t)DO, sizeof( double)*2, compare );

        
        for(l2=0;l2<N;l2++){
            if(l2<DO){
                Anlg->Mtx[l2*DP+lp]=dist[l2*2+1];
                if(Dist->Mtx!=NULL) 
                    Dist->Mtx[l2*DP+lp]=sqrt(dist[l2*2]);
            }else{
                Anlg->Mtx[l2*DP+lp]=DBL_NAN;
                if(Dist->Mtx!=NULL)
                    Dist->Mtx[l2*DP+lp]=DBL_NAN;
            }
        }
        
    }
    free(dum1);
    free(dist);
}


int compare( const void *arg1, const void *arg2 ){
    /*
    double a,b;
    a=((double *)arg1)[0];
    b=((double *)arg2)[0];
    if(a<b) return -1;
    else if(b>a) return 1;
    else return 0;
    */
    
    if(((double *)arg1)[0]<((double *)arg2)[0]) return -1;
    else if(((double *)arg1)[0]>((double *)arg2)[0]) return 1;
    else return 0;
    }
