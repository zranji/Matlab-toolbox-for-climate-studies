function PP=readPatterns(OPRCP,ERACP,Ptnd,Prdc);

PtndName={'Es','Gr','Ll','Tr','Ro','Nb','Nv','Pre','Vx','In','Tx','Tn','PreSynop','PrePiura'};
PtndNodato={99,99,99,99,99,99,99,-999,-999,-999,-999,-999,-999,-999};
PtndUmb={...
      [000,001,inf],...
      [000,001,inf],...
      [000,001,inf],...
      [000,001,inf]...
      [000,001,inf],...
      [000,001,inf],...
      [000,001,inf],...
      [000,001,020,100,200,inf],...
      [000,050,080,inf],...
      [000,010,030,050,070,inf],...
      [],...
      [],...
      [000,001,020,100,200,inf],...
      [000,001,020,100,200,inf],...
   };



NA=size(OPRCP,1);
NCP=size(OPRCP,2);
NS=size(OPRCP,3);
NM=size(OPRCP,4);
NV=size(OPRCP,5);
NStn=size(Ptnd,2);
%Prdc.NumA=[];Prdc.NumC=8;
%Prdc.Centers=[];
%Prdc.indCenters=[]; %NumC centros mas cercanos al dia problema
%Prdc.disCenters=[]; %Distanacia a los NumC centros mas cercanos
%Prdc.indCluster=[]; %Indice de los dia de ERACP que pertenecen a cada Cluster


if(strcmpi(Prdc.Method,'Clustering'))
   PrdcClst.Class='Clst';
   PrdcClst.Type='Prb';
   PrdcClst.Method='Wc';
   PrdcClst.Neig=Prdc.Clustering.NumC;                                                                                
   PrdcClst.NCP=Prdc.NCP;
   PrdcClst.msizex=1;
   PrdcClst.msizey=size(Prdc.Clustering.Centers,1);
   PrdcClst.NumA=[];
   PrdcClst.NEx=15;
   PrdcClst.Umb=PtndUmb{find(strcmpi(PtndName,Prdc.Variable))};
   
   ncenters=size(Prdc.Clustering.Centers,1);
   [indCP,distCP]=MLknn(ERACP(:,1:size(Prdc.Clustering.Centers,2)),Prdc.Clustering.Centers,1,'Norm-2');
   nClases=zeros([ncenters,1]);
   indCenters=[];
   distCenters=[];
   for k=1:ncenters
      iC=find(indCP(:,1)==k);
      nClases(k)=length(iC);
      indCenters(k,1:nClases(k))=iC(:)';
      distCenters(k,1:nClases(k))=distCP(iC(:),1)';
   end
   
   
   %Si realizamos prediccion estacional nos inteeresa hacer promedios mensuales.
   %	
   if(strcmpi(Prdc.System,'SEASONAL2') | strcmpi(Prdc.System,'DEMETER') | strcmpi(Prdc.System,'DEMETERPeru'))
   	PrdcClst.Type='Det';
   	PrdcClst.Method='Pr';
   	PrdcClst.Umb=[];
      PrdcClst.Prc=[0.75];
   	NUmb=size(PrdcClst.Prc,2);
      Prdc2=PrdcClst;
	   Prdc2.NumA=nClases;Prdc2.IndEx=[];Prdc2.Method='Pr';


      PtndCenters=makePrediction(indCenters,ones(size(indCenters)),Ptnd,Prdc2);
   	%PP=zeros([NA,NStn,NS,NM,NV,NUmb])*NaN;
   	%PP(NA,NStn,NS,NM,NV,NUmb)=NaN;
   	PP(NA,NStn,12*2,NM,NV,NUmb)=NaN;
   	PP(:)=NaN;
		for iA=1:NA
         for iM=1:NM
            for iV=1:NV
               disp(sprintf('%4d %4d %4d',iA,iM,iV));
               k=1;
               indC=permute(Prdc.Clustering.indCenters(iA,k,:,iM,iV),[3,2,1,4,5]);
               disC=permute(Prdc.Clustering.disCenters(iA,k,:,iM,iV),[3,2,1,4,5]);
               P=PtndCenters(indC,:,:).*...
                  repmat(1./disC,[1,size(PtndCenters,2),size(PtndCenters,3)]);
               for k=2:Prdc.Clustering.NumC
                  indC=permute(Prdc.Clustering.indCenters(iA,k,:,iM,iV),[3,2,1,4,5]);
                  disC=permute(Prdc.Clustering.disCenters(iA,k,:,iM,iV),[3,2,1,4,5]);
                  P=nansum(cat(4,P,PtndCenters(indC,:,:).*...
                     repmat(1./disC,[1,size(PtndCenters,2),size(PtndCenters,3)])),4);
               end
               disC=permute(Prdc.Clustering.disCenters(iA,k,:,iM,iV),[3,2,1,4,5]);
               P=P./repmat(nansum(1./disC,2),[1,size(P,2),size(PtndCenters,3)]);
               %PP(iA,:,:,iM,iV,:)=ipermute(P,[3,2,1,4,5]);
               D=1;
               P=getMeans(P,D,1,permute(Prdc.FcDate(iA,1:3,:,iM,iV),[3,2,1,4,5]));
               P=reshape(P,[size(P,1)*size(P,2) size(P,3) size(P,4)]);
					PP(iA,:,1:size(P,1),iM,iV,:)=ipermute(P,[3,2,1,4,5]);
            end
         end
      end
      
      
   elseif(strcmpi(Prdc.System,'ECMWF') | strcmpi(Prdc.System,'EPS') | strcmpi(Prdc.System,'AVN'))
      Prdc2=PrdcClst;
      Prdc2.NumA=nClases;Prdc2.IndEx=[];
      %Prdc2.Method='Lg';
      %%AÑADIDO PARA LA REGRESION LOCAL 
      Prdc2.Type=Prdc.Prediction.Type;
      Prdc2.Method=Prdc.Prediction.Method;
      Prdc2.MinRg=Prdc.Prediction.MinRg;
      Prdc2.Neig=Prdc.Prediction.Neig;
      
      Prdc2.RE=ERACP;
      Prdc2.REp=Prdc.Clustering.Centers;
      Prdc2.IndEx=datenum(Prdc.FcDate(:,1),Prdc.FcDate(:,2),Prdc.FcDate(:,3))-datenum(1979,1,1)+1;
      %%%%   			
      
      PtndCenters=makePrediction(indCenters,ones(size(indCenters)),Ptnd,Prdc2);
      
      for iS=1:NS
         for iM=1:NM
            for iV=1:NV
               disp(sprintf('%4d %4d %4d',iS,iM,iV));
               k=1;
               indC=Prdc.Clustering.indCenters(:,k,iS,iM,iV);
               disC=Prdc.Clustering.disCenters(:,k,iS,iM,iV);
               P=PtndCenters(indC,:,:).*...
                  repmat(1./disC,[1,size(PtndCenters,2),size(PtndCenters,3)]);
               for k=2:Prdc.Clustering.NumC
                  indC=Prdc.Clustering.indCenters(:,k,iS,iM,iV);
                  disC=Prdc.Clustering.disCenters(:,k,iS,iM,iV);
                  P=nansum(cat(4,P,PtndCenters(indC,:,:).*...
                     repmat(1./disC,[1,size(PtndCenters,2),size(PtndCenters,3)])),4);
               end
               disC=Prdc.Clustering.disCenters(:,:,iS,iM,iV);
               P=P./repmat(nansum(1./disC,2),[1,size(P,2),size(P,3)]);
               PP(:,:,iS,iM,iV,:)=P;
            end
         end
      end
   else
      error(['Unknown System: ' Prdc.System]);
   end
elseif(strcmpi(Prdc.Method,'Analogues'))
   PrdcAnlg.Class='knn';
   %PrdcAnlg.Type='Prb';
   PrdcAnlg.Type=Prdc.Prediction.Type;
   PrdcAnlg.Method=Prdc.Prediction.Method;
   PrdcAnlg.MinRg=Prdc.Prediction.MinRg;
   PrdcAnlg.Neig=Prdc.Prediction.Neig;
   %PrdcAnlg.Method='Lg';
   if(strcmpi(PrdcAnlg.Type,'Prb'))
   	PrdcAnlg.Umb=PtndUmb{find(strcmpi(PtndName,Prdc.Variable))};
   	NUmb=size(PrdcAnlg.Umb,2)-2;
   elseif(strcmpi(PrdcAnlg.Type,'Det'))
   	PrdcAnlg.Umb=NaN;
   	NUmb=1;
   else
      error(['Unknown Type: ' PrdcAnlg.Type]);
   end

   %PrdcAnlg.Type='Det';
   %PrdcAnlg.Method='Pr';
   %PrdcAnlg.Umb=[];
   %PrdcAnlg.Prc=[0.70 0.75 0.80];
   %NUmb=size(PrdcAnlg.Prc,2);
   %PrdcAnlg.Neig=5;                                                                                
   %PrdcAnlg.MinRg=30;                                                                                
   %PrdcAnlg.NCP=Prdc.NCP;
   PrdcAnlg.NumA=Prdc.Clustering.NumA ;
   PrdcAnlg.Centers=[];
   PrdcAnlg.NEx=15;
   %PrdcAnlg.IndEx=[];
   PrdcAnlg.IndEx=datenum(Prdc.FcDate(:,1),Prdc.FcDate(:,2),Prdc.FcDate(:,3))-datenum(1979,1,1)+1;
   %PP=zeros([NA,NStn,NS,NM,NV,NUmb])*NaN;
   PrdcAnlg.RE=ERACP;
   
   %PP=zeros([NA,NStn,NS,NM,NV,NUmb])*NaN;
   
   PP(NA,NStn,NS,NM,NV,NUmb)=NaN;
   PP(:)=NaN;
   
   for iS=1:NS
      for iM=1:NM
         for iV=1:NV
            disp(sprintf('%4d %4d %4d',iS,iM,iV));
            [indAng,distAng]=MLknn(OPRCP(:,:,iS,iM,iV),ERACP,2*PrdcAnlg.NumA,'Norm-2');
            PrdcAnlg.REp=OPRCP(:,:,iS,iM,iV);
            P=makePrediction(indAng,1./distAng,Ptnd,PrdcAnlg);
            PP(:,:,iS,iM,iV,:)=P;
         end
      end
   end
else
   error(['Unknown Method: ' Prdc.Method]);
end
