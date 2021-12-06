function [RPS,RPSS]= validationRPS(O,P)
%
% [RPS,RPSS]= validationRPS(O,P)
% Computes Ranked Probabilty Score (RPS) and Skill Score (RPSS);
% Requires: \toolbox\matlab\elmat and \toolbox\matlab\datafun
%
% Inputs:
%   O: DxN matrix of discrete observations where D is the number of 
%         predictions (days) and N is the number of stations. 
%         For example, O(1,5)=3 means that the 3th category was observed
%         in the first day and 5th station.
%   P: DxNxM matrix of probabilistic predictions where D is the number
%         of predictions, N is the number of stations and M is the number
%         of categories.
%         For example, pred(1,5,3)=0.12 means that the probability of the 
%         3th category, in the first day and 5th station is 0.12.
% Outputs:
%   RPS:  Ranked Probability Score
%         How well did the probability forecast predict the category that 
%         the observation fell into?
%         Range: 0 to 1.  Perfect score: 0
%         http://www.bom.gov.au/bmrc/wefor/staff/eee/verif/verif_web_page.html#RPS
%   RPSS: Ranked Probability Skill Score
%         What is the relative improvement of the probability forecast over 
%         climatology in predicting the category that the observations fell into?
%         Range: minus infinity to 1, 0 indicates no skill when 
%         compared to the reference forecast. Perfect score: 1
%         http://www.bom.gov.au/bmrc/wefor/staff/eee/verif/verif_web_page.html#RPSS
%
% Acknowledgements. We are grateful to Raul Marcos, from the University of Barcelona, 
% for help us to correct this function.
% 
% More information in: 
%  Epstein, E.S., 1969. A scoring system for probability forecasts 
%  of ranked categories. Journal of Applied Meteorology 8, 985-987.
%
% Example (a random forecast with no skill):
%      O=ceil(rand(365,1)*2); 
%      P(:,:,1)=rand(365,1); P(:,:,2)=1-P(:,:,1);
%      [RPS,RPSS]=validationRPS(O,P)

size_o = size(O);
size_p = size(P);
if (size_o(1)~=size_p(1) | size_o(2)~=size_p(2))
    error('obsr and pred two first dimensions must agree.');
end

if (~isempty(find(P<0)) | ~isempty(find(P-1>eps)))
    error('pred values must be between 0 and 1');
end

if (sum(P,3) - 1 > eps)
    error('not a probabilistic forecast');
end

classes = unique(O); % different classes
M = max(size_p(3),length(classes));    % number of classes
N = size_o(2);       % number of stations
D = size_o(1);       % number of predictions
if M>size_p(3)
    P1 = zeros(D,N,M);P1(:,:,1:size_p(3))=P;P=P1;clear P1
    size_p(3)=M;
end
% O is an indicator (0=no, 1=yes) for the 
% observation, station and category
Ob = zeros(D,N,M);
for m=1:length(classes)
    [i,j] = find(O == classes(m));
    k = repmat(m,size(i));
    inds = sub2ind(size(Ob),i,j,k);
    Ob(inds) = 1;
end

% Compute the cumulative probability for both O and P
Ob = cumsum(Ob,3);
P = cumsum(P,3);

% Ranked Probability Score
RPS = sum((Ob-P).^2,3)/(M-1);
RPS = mean(RPS,1);

% Reference Ranked Probability Score
if (nargout>=2)
    freq  = histc(O,classes)/D;
    O_ref = shiftdim(repmat(freq',[1 1 D]),2);
    O_ref = cumsum(O_ref,3);
    RPS_ref = sum((O_ref-Ob).^2,3)/(M-1);
    RPS_ref = mean(RPS_ref,1);
    
    % Ranked Probability Skill Score
    RPSS = 1 - RPS./RPS_ref;
end