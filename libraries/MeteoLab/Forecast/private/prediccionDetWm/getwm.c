#include "proutils.h"

void getwm(SDoubleMtx *Prob,SDoubleMtx *Umb,SDoubleMtx *Anlg,SDoubleMtx *NAnlg,SDoubleMtx *Pesos){
	
	int d1,d2,d3,l1,l2,l3,N,ISPOND=1;
	double nan,dt,Weight,P;
	
	nan=fmod(0.0,0.0);
	d1=Anlg->Dim[0];d2=Anlg->Dim[1];
	if(Anlg->Ndim==3)
		d3=Anlg->Dim[2];
	else
		d3=1;
	
	if(Pesos->Mtx==NULL)
		ISPOND=0;
#ifdef VERBOSE_PRO	
	mexPrintf("\td1=%d,d2=%d,d3=%d)\n",d1,d2,d3);
#endif
	
	for(l1=0;l1<d1;l1++){
		for(l2=0;l2<d2;l2++){
			N=0;
			P=0;
			Prob->Mtx[l2*d1+l1]=0.0;
			for(l3=0;l3<d3;l3++){
				dt=Anlg->Mtx[l3*d2*d1+l2*d1+l1];
				/*
				mexPrintf("%3d %3d %3d %8g %8g %1d\n",l1,l2,l3,dt,nan,memcmp(&dt,&nan,sizeof(double)));
				*/
				if(memcmp(&dt,&nan,sizeof(double))==0) 
					continue;
					/*	#ifdef VERBOSE_PRO*/	
					/*mexPrintf("\t\t(%d,%d,%d)\n",l1,l2,l3);*/
					/*#endif*/
				Weight=ISPOND?Weight=Pesos->Mtx[l3*d2*d1+l2*d1+l1]:1;
				Prob->Mtx[l2*d1+l1]+=dt*Weight;
				P+=Weight;
				N++;
				if(N>=NAnlg->Mtx[l2*d1+l1]) break;
			}
			if(N==0) Prob->Mtx[l2*d1+l1]=nan;
			else Prob->Mtx[l2*d1+l1]/=P;
		}
	}
#ifdef VERBOSE_PRO	
	mexPrintf("\t\tExiting rellenaProb...\n",l1,l2,l3);
#endif
	
}
