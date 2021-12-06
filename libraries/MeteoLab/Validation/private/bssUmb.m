function [BSS0,BSP0,BSC0,BSS1,BSP1,BSC1]=bss(O,P,C)

BSP0=ones([1 size(P,2) size(P,3)])*NaN;
BSC0=BSP0;
BSP1=BSP0;
BSC1=BSP0;
nU=size(P,3);
for k=1:nU
   Od=O(:,:,k);
   Od(find(Od==0))=NaN;
   BSP1(:,:,k)=nanmean((P(:,:,k)-Od).^2,1);
	BSC1(:,:,k)=nanmean((C(:,:,k)-Od).^2,1);
   
   Od=O(:,:,k);
   Od(find(Od==1))=NaN;
   BSP0(:,:,k)=nanmean((P(:,:,k)-Od).^2,1);
	BSC0(:,:,k)=nanmean((C(:,:,k)-Od).^2,1);
end
BSC0(find(abs(BSC0)<=eps))=NaN;
BSS0=1-BSP0./BSC0;

BSC1(find(abs(BSC1)<=eps))=NaN;
BSS1=1-BSP1./BSC1;
