function struct=validationBinaryDet(struct,O,P,score,varargin)
%
%   struct=validationBinaryDet(struct,O,P);
%   Computes several performance indices for deterministic binary 
%   predictions P and deterministic binary observations O. 
%   The vectors O and P may contain missing data (NaN values). 
%
% Inputs:
%      O:  DxN matrix of discrete observations where D is the number of 
%          predictions (days) and N is the number of stations. 
%      P:  DxN matrix of probabilistic predictions.
%
% Outputs (E=Event, W=warning (prediction). E',W' no event and warning).
%   VAL = 
%      Clim:    Climatological probability, p(E)
%       HIR:    Hit Rate, p(W|E)
%       FAR:    False-Alarm Rate, p(W|E')
%       CAR:    Correct-Alarm Ratio, p(E|W)
%      POFD:    Probability of False Detection, p(E'|W)=1-CAR;
%       RSA:    ROC Skill Area
%        MR:    Miss Ratio, p(E|W')
%       ETS:    Equitable Trheat Score.
%       TSS:    True Skill Statistics.
%        OR:    Odds Ratio
%      ORSS:    Odds Ratio Skill Score
%       EDS:    Extreme Dependency Score
%
% More information in: 
%  S.J. Mason and N.E. Graham, 1999. Conditional Probabilities, Relative Operating Characteristics, 
%  and Relative Operating Levels. Weather and Forecast, 14, 713-725.
%
% Example (a random forecast with no skill):
%      O=rand(365,1)>0.5; P=rand(365,1)>0.5;
%      struct=validationBinaryDet([],O,P,{'Clim';'HIR';'FAR';'CAR';'POFD';'RSA';'MR';'ETS';'TSS';'HSS';'OR';'ORSS';'EDS'})

O=double(O);P=double(P);
warning off MATLAB:divideByZero;
e=nansum(O>0);    %Event
ne=nansum(O==0);  %No event
indScore=[1:length(score)];
[a1,a2]=ismember({'rsa'},lower(score));
if a1
	aux=validationBinaryProb([],O,P,{'rsa'},'graph','no');Z=aux.rsa;
	struct=setfield(struct,score{a2},Z);disp(score{a2})
	indScore=setdiff(indScore,a2(find(a1)));clear a2 a1
end
if find(P>0 & P<1)
    warning('Converting to binary prediction using ''Prob2Det'' function');
    P=Prob2Det(O,P); % Transform Probabilistic data into binary data (1=event, 0 no event) according to its climatology
end
% Contingency Table
a=nansum(double(P>0 & O>0));   b=nansum(double(P>0 & O==0));  % W
c=e-a;                         d=ne-b;                     % W'
for i=indScore
	warn=0;disp(score{i})
	switch lower(score{i}),
		case 'clim',Z=e./(e+ne);% Climatological probability, p(E)
        case 'ratio',Z=nansum(P==0)./ne;  %frec(P=0/O=0)
		case 'hir',Z=a./e;% Hit alarm rates
		case 'far',Z=b./ne;% False alarm rates
		case 'car',Z=a./(a+b);
		case 'pofd',Z=1-a./(a+b);
		case 'mr',Z=b./(c+d);
		case 'ets',%Equitable Threat Score (ETS)
			hrandom=(a+b).*(a+c)./(a+b+c+d);
			Z=(a-hrandom)./(a + b +c - hrandom);
		case 'tss',Z=a./e-(1-a./(a+b));%True Skill Statistics (TSS)
		case 'hss',Z=2.*(a.*d-b.*c)./((a+c).*(c+d) + (a+b).*(b+d));%Heidke's Skill Score (HSS)
		case 'or',Z=a.*d./(b.*c);%Odds Ratio (OR)
		case 'orss',Z=((a.*d)-(b.*c))./((a.*d)+(b.*c));%Odd Ratio Skill Score
		case 'eds',Z=((2.*log(a+c))./log(a))-1;% Extreme Dependency Score (EDS)
		otherwise, warning(sprintf('Unknown validation score: %s (ignored)',score{i})); warn=1;
	end
	if (~warn)
		struct=setfield(struct,score{i},Z);
	end
end
