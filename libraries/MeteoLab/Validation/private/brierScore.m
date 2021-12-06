function BSP=brierScore(P,O,varargin)
%Hay que tener en cuenta que pueden existir nan's debido a lagunas
%BSS=1-nanmean((Prdc-Obsr).^2+(1-Prdc-1+Obsr).^2,1)./nanmean((Clmt-Obsr).^2+(1-Clmt-1+Obsr).^2,1);
%1-Prdc-1+Obsr se reduce a 2*(Prdc-Obsr)
if nargin<3
   DIM=1;
else
   DIM=varargin{1};
end


BSP=nanmean((P-O).^2,DIM);
