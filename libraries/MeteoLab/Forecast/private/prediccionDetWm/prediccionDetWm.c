#include "proutils.h"

void prediccionDetWm(SDoubleMtx *Prdc,SDoubleMtx *Anlg,SDoubleMtx *Dist,SDoubleMtx *Ptnd,SParamPrd *Param){
	int NStn,NPro,NUmb,NumA,NReg,l1,l2,l3,linf,lsup,M,N,ind;
	SDoubleMtx PtndAnlg[1],DistLoc[1],NA[1],PrdcLoc[1];
	double DBL_NAN,dist;
	DBL_NAN=fmod(0.0,0.0);
	/***************************************************************
	  Inicializando la prediccion.
	***************************************************************/
	NReg=Ptnd->Dim[0];	
	NStn=Ptnd->Dim[1];	
	NPro=Anlg->Dim[0];
	NumA=Anlg->Dim[1];
	NUmb=1;
#ifdef VERBOSE_PRO	
	mexPrintf("NaN=%f,NReg=%d;NStn=%d;NPro=%d;NumA=%d;NUmb=%d\n",DBL_NAN,NReg,NStn,NPro,NumA,NUmb);
#endif
	PtndAnlg->Ndim=3;
	PtndAnlg->Dim=(int *)malloc(sizeof(int)*PtndAnlg->Ndim);
	PtndAnlg->Dim[0]=1;PtndAnlg->Dim[1]=NStn;PtndAnlg->Dim[2]=NumA;
	PtndAnlg->Mtx=(double *)malloc(sizeof(double)*NumA*NStn);
	NA->Ndim=2;
	NA->Dim=(int *)malloc(sizeof(int)*NA->Ndim);
	NA->Dim[0]=1;NA->Dim[1]=NStn;
	NA->Mtx=(double *)malloc(sizeof(double)*NStn);
	PrdcLoc->Ndim=3;
	PrdcLoc->Dim=(int *)malloc(sizeof(int)*PrdcLoc->Ndim);
	PrdcLoc->Dim[0]=1;PrdcLoc->Dim[1]=NStn;PrdcLoc->Dim[2]=NUmb;
	PrdcLoc->Mtx=(double *)malloc(sizeof(double)*NUmb*NStn);
	if(Dist->Mtx!=NULL){
		DistLoc->Ndim=3;
		DistLoc->Dim=(int *)malloc(sizeof(int)*DistLoc->Ndim);
		DistLoc->Dim[0]=1;DistLoc->Dim[1]=NStn;DistLoc->Dim[2]=NumA;
		DistLoc->Mtx=(double *)malloc(sizeof(double)*NumA*NStn);
	}else
		DistLoc->Mtx=NULL;
	
	M=Param->NAnlg->Dim[0];
	if((M!=1) && (M!=Anlg->Dim[0]))
		errMsgTxt("Error: las dimensiones de NAnlg no son las correctas");	
	N=Param->NAnlg->Dim[1];
	if((N!=1) && (N!=Ptnd->Dim[1]))
		errMsgTxt("Error: las dimensiones de NAnlg no son las correctas");	
	
	/***************************************************************
	  Calculamos la PDF para cada uno de los dias problemas.
	***************************************************************/
#ifdef VERBOSE_PRO	
	mexPrintf("\tComenzando Bucle de Dias Problema...\n",NReg,NStn,NPro,NumA,NUmb);
#endif
	for(l1=0;l1<NPro;l1++){
		/***************************************************************
		  Los limites de exclusion son calculados si se ha definido un
		  array con los indices a excluir.							  
		***************************************************************/
		if(Param->IndEx->Mtx==NULL){
			linf=NReg;
			lsup=0;
		}
		else{
			linf=(int)Param->IndEx->Mtx[l1]-(int)Param->NEx->Mtx[0];
			lsup=(int)Param->IndEx->Mtx[l1]+(int)Param->NEx->Mtx[0];
		}
		/***************************************************************
		  Para cada dia Problema, transformamos los indices de analogos
		  en Predictandos.
		***************************************************************/
#ifdef VERBOSE_PRO	
		mexPrintf("\tPtnd->Anlg(%d)\n",l1);
#endif
		for(l3=0;l3<NumA;l3++){
			ind=(int)Anlg->Mtx[l3*NPro+l1]-1;
			/***************************************************************
			  Si el indice esta dentro del intervalo de exclusion, el dato 
			  no existe (>que el numero de dias disponibles en la matriz de
			  Ptnd).
			***************************************************************/
			if((ind>linf) && (ind<lsup))
				ind=NReg;
			if(Dist->Mtx!=NULL)
				dist=Dist->Mtx[l3*NPro+l1];
			
			for(l2=0;l2<NStn;l2++){
				/***************************************************************
				  Si el indice esta fuera de las dimensiones de la matriz Ptnd,
				  entonces el predictando no existe (!!!!LAGUNA=NaN!!!!).
				***************************************************************/
				if((ind<NReg) && (ind>=0)){
					PtndAnlg->Mtx[l3*NStn+l2]=Ptnd->Mtx[NReg*l2+ind];
					if(Dist->Mtx!=NULL)
						DistLoc->Mtx[l3*NStn+l2]=dist;

				}
				else
					PtndAnlg->Mtx[l3*NStn+l2]=DBL_NAN;
			}
		}
		/***************************************************************
		  Para cada dia problema y cada estacion habra un numero 
		  diferente de analogos a considerar. Todas las estaciones 
		  pueden tener el midmo numero de analogos para cada dia 
		  problema. Todos los dias Problema pueden tener el mismo 
		  numero de Analogos para cada estacion. Todos los dias 
		  problema, y todas las estaciones pueden tener los mismos. 
		***************************************************************/
		for(l2=0;l2<NStn;l2++){
			NA->Mtx[l2]=Param->NAnlg->Mtx[l2%N*M+l1%M];/*<-----!!CUIDADO!!*/
		}
		/***************************************************************
		  Rellenamos la probanilidad para el dia problema l1 y para 
		  todas las estaciones.
		***************************************************************/
#ifdef VERBOSE_PRO	
		mexPrintf("\tPrdcLoc[%d](%d,%d,%d)\n",PrdcLoc->Ndim,PrdcLoc->Dim[0],PrdcLoc->Dim[1],PrdcLoc->Dim[2]);
		mexPrintf("\tUmb[%d](%d,%d)\n",Param->Umb->Ndim,Param->Umb->Dim[0],Param->Umb->Dim[1]);
		mexPrintf("\tPtndAnlg[%d](%d,%d,%d)\n",PtndAnlg->Ndim,PtndAnlg->Dim[0],PtndAnlg->Dim[1],PtndAnlg->Dim[2]);
		mexPrintf("\tNAnlg[%d](%d,%d)\n",NA->Ndim,NA->Dim[0],NA->Dim[1]);
		mexPrintf("\tDistLoc[%d](%d,%d,%d)\n",DistLoc->Ndim,DistLoc->Dim[0],DistLoc->Dim[1],DistLoc->Dim[2]);
		mexPrintf("\tAnlg->Prdc(%d)...\n",l1);
#endif
		getwm(PrdcLoc,Param->Umb,PtndAnlg,NA,DistLoc);
#ifdef VERBOSE_PRO	
		mexPrintf("Filling Prediccion...(NaN=%f)\n",DBL_NAN);
#endif
		for(l2=0;l2<NStn;l2++){
			for(l3=0;l3<NUmb;l3++){
				Prdc->Mtx[l3*NPro*NStn+l2*NPro+l1]=PrdcLoc->Mtx[l3*NStn+l2];
				PrdcLoc->Mtx[l3*NStn+l2]=0.0;
			}
		}
	
	}
	free(PtndAnlg->Dim);
	free(PtndAnlg->Mtx);
	free(PrdcLoc->Dim);
	free(PrdcLoc->Mtx);
	free(NA->Dim);
	free(NA->Mtx);
	if(Dist->Mtx!=NULL){
		free(DistLoc->Dim);
		free(DistLoc->Mtx);
	}
}
