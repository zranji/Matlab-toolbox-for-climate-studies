function BHK=validationBHK(O,P)
% BHK=validationBHK(O,P)
% Calculates Best Hanssen-Kuipers Score for probabilistic forecast
% BHK: Best Hanssen-Kuipers Score=>BHKS=HIR(pc) - FAR(pc)
% HIR(pc)/FAR(pc) means Hit Rate value/ False alarm Rate using the climatological probabilty as
% threshold.

% Inputs:
%      O:  DxN matrix of discrete observations where D is the number of
%          predictions (days) and N is the number of stations.
%      P:  DxN matrix of probabilistic predictions.
%
% Output:
%    BHK: Best Hanssen-Kuipers Score=>BHKS=HIR(pc) - FAR(pc)
%
% Example (a random forecast with no skill):
%      O=rand(365,1)>0.5; P=rand(365,1);
%      bhk=validationBHK(O,P)

e=nansum(O>0);    %Event
ne=nansum(O==0);  %No event

% Observational climatology
clim=e./(e+ne);

% Transform to binary
for j=1:size(P,2)
    P(:,j)=(P(:,j)>=clim(j));
end

%P has the predictions 0, 1 o NaN of each day/station
P=double(P);
if ~isempty(isnan(O))
    P(isnan(O))=NaN;
end

% Contingency Table
a=nansum(double(P>0 & O>0));   b=nansum(double(P>0 & O==0));  % W

% hit and false alarm rates
HIR=a./e;
FAR=b./ne; %rate

% Best Hanssen-Kuipers
BHK=HIR-FAR;

end