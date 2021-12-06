
O=Obsr{1,1};
P1=Clmt{1,1};
P2=Prdc{2,1};

%[BSS{1},HIR{1},FAR{1}]=validaCuant(O,P1,P2);
%[BSS{2},HIR{2},FAR{2}]=validaCuant(O,P2,P1);
%BSSD{1}=validaCuantDaily(O,P1,P2);
%BSSD{2}=validaCuantDaily(O,P2,P1);

%[hi,ob,fa,nob,fbo,fbp]=count(Obsr,Prdc,[-0.1 (0.1:0.1:1)]');

%VP.BSSD=BSSD{1};%BSS de la red P1 frente a la P2
%VP.BSS=BSS{1};
%VP.HIR=HIR{1}; %hir y far de la red P1
%VP.FAR=FAR{1};
%Loc.loc=loc{1};
%Loc.colorMap=hot(15);  
%drawValProb(VP,Loc,ptndLims{1},Labels{1});       

%Data.Obsr=O;Data.Prdc=P1;%probabilidades de la red P1 frente a las observaciones
%drawPrdcObsr(Data,Loc,ptndLims{1},Labels{1});       

%VP.BSSD=BSSD{2};%BSS de la red P2 frente a la P1
%VP.BSS=BSS{2};
%VP.HIR=HIR{2};%hir y far de la red P2
%VP.FAR=FAR{2};
%drawValProb(VP,Loc,ptndLims{1},Labels{1});       

%Data.Obsr=O;Data.Prdc=P2;%red neuronal frente a las observaciones
%drawPrdcObsr(Data,Loc,ptndLims{1},Labels{1});       

%Data.Obsr=P1;Data.Prdc=P2;%probabilidades de la red P1 frente a las de P2
%drawPrdcObsr(Data,Loc,ptndLims{1},Labels{1});       
l=[2 4 5]; %neuronal(azul), correlacion canonica(rojo) y bayesiana(verde)
for j=1:length(l)
   
P1=Prdc{l(j)};
P2=Prdc{1,2};
Oc=1-cumsum(O(:,:,1:end-1),3);
Pc=1-cumsum(P1(:,:,1:end-1),3);
Cc=1-cumsum(P2(:,:,1:end-1),3);
prob=[-0.1 (0.1:0.1:1)]';

BSS(j,:,:)=bss(Oc,Cc,Pc);
[hi,ob,fa,nob,fbo,fbp]=count(Oc,Pc,prob);
Count.HI(1,:,:,:)=permute(hi,[2 1 3]);
Count.OB(1,:,:,:)=permute(ob,[2 1 3]);
Count.FA(1,:,:,:)=permute(fa,[2 1 3]);
Count.NOB(1,:,:,:)=permute(nob,[2 1 3]);
Count.FBO(1,:,:,:)=permute(fbo,[2 1 3]);
Count.FBP(1,:,:,:)=permute(fbp,[2 1 3]);
Count.NumOb(1,:,:)=length(indSrc);
%for i=1:size(Count.FBP,4)
	i=2;
   VP(j).Pc=squeeze(sum(sum(Count.OB(:,:,:,i),1),2)./(sum(sum(Count.NOB(:,:,:,i),1),2)+sum(sum(Count.OB(:,:,:,i),1),2)));
   VP(j).FAR=squeeze(sum(sum(Count.FA(:,:,:,i),1),2)./repmat(sum(sum(Count.NOB(:,:,:,i),1),2),[1 1 size(Count.FA(:,:,:,i),3) 1]));
   VP(j).HIR=squeeze(sum(sum(Count.HI(:,:,:,i),1),2)./repmat(sum(sum(Count.OB(:,:,:,i),1),2),[1 1 size(Count.HI(:,:,:,i),3) 1]));
   VP(j).PRB=0.05:0.1:0.95;
   VP(j).FBO=squeeze(sum(sum(Count.FBO(:,:,:,i),1),2));
   VP(j).FBP=squeeze(sum(sum(Count.FBP(:,:,:,i),1),2));
end
drawValgen(VP)