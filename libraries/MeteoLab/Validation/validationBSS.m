function [BSS,BSC,BSP]=validationBSS(O,P)
%
%   [BSS,BSC,BSP]=validationBSS(O,P);
%   Computes Relative Operation Characteristics (ROC) for to the
%   binary observations O and the probabilistic predictions P.
%   The vectors O and P may contain missing data (NaN values).
%
% Inputs:
%      O:  DxN matrix of discrete observations where D is the number of
%          predictions (days) and N is the number of stations.
%      P:  DxN matrix of probabilistic predictions.
%     Validation is performed by rows (days) and averaged by columns (stations)
%
% Outputs:
%    BSS:  Brier Skill Score, Range: 0 to 1. Perfect score: 1
%    BSC:  Brier Score of climatology
%    BSP:  Brier Score of predictions
%
% Example (a random forecast with no skill):
%      O=rand(365,1)>0.5; P=rand(365,1);
%      [BSS,BSC,BSP]=validationBSS(O,P)


% Climatological occurrence probability
Clim=nanmean(O);

%Brier Scores de Obsercacion y Prediccion y Brier Skill Score
%Hay que tener en cuenta que pueden existir nan's debido a lagunas
%BSS=1-nanmean((Prdc-Obsr).^2+(1-Prdc-1+Obsr).^2,1)./nanmean((Clmt-Obsr).^2+(1-Clmt-1+Obsr).^2,1);
%1-Prdc-1+Obsr se reduce a 2*(Prdc-Obsr)

BSP=nanmean((P-O).^2,1);
BSC=nanmean((repmat(Clim,size(O,1),1)-O).^2,1);
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

% Station Average
% BSP=nanmean(BSP,2);
% BSC=nanmean(BSC,2);
% BSS=nanmean(BSS,2);

%    EVA:  Economic Value Area, Range: 0 to 1. Perfect score: 1
%     EV:  Structure with Economic Values for the different cost/loss ratios.
end