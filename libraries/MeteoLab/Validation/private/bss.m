function [BSS,BSP,BSC]=bss(O,P,C)
%[BSS,BSP,BSC]=bss(Obsr,Prdc,Clmt)
%Funcion encarga de validar prediciones probilisticas (Prdc)
%   frente a las observaciones cuantificando la probabilidad.
%   BSS=Brier Skill Score de la prediccion

%Hay que tener en cuenta que pueden existir nan's debido a lagunas
%BSS=1-nanmean((Prdc-Obsr).^2+(1-Prdc-1+Obsr).^2,1)./nanmean((Clmt-Obsr).^2+(1-Clmt-1+Obsr).^2,1);
%1-Prdc-1+Obsr se reduce a 2*(Prdc-Obsr)

BSP=nanmean((P-O).^2,1);
BSC=nanmean((C-O).^2,1);
BSC(find(abs(BSC)<=eps))=NaN;
BSS=1-BSP./BSC;

%BSP=ones([1 size(P,2) size(P,3)])*NaN;
%BSC=BSP;
%nU=size(P,3);
%for k=1:nU
%   Od=O(:,:,k);
%   Od(find(Od==0))=NaN;
%   BSP(:,:,k)=nanmean((P(:,:,k)-Od).^2,1);
%	BSC(:,:,k)=nanmean((C(:,:,k)-Od).^2,1);
%end
%BSC(find(abs(BSC)<=eps))=NaN;
%BSS=1-BSP./BSC;
