function struct=validationBinaryProb(struct,O,P,score,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Computes different validation scores for
%   binary observations O and the probabilistic predictions P.
%   The vectors O and P may contain missing data (NaN values).
%
% Inputs:
%      O:  DxN matrix of discrete observations where D is the number of
%          predictions (days) and N is the number of stations.
%      P:  DxN matrix of probabilistic predictions.
%	varargin    - optional parameters
%     'graph'  	{'yes','no'}, to display, or not, graphs (default 'yes').
%     'points'  n, number of points in the ROC and reliability curves (default 20).
%
% Outputs: Struct with the following scores:
%    RSA:  Roc Skill Area, Range: 0 to 1. Perfect score: 1
%    ROC:  Structure with HIR and FAR for the different prob. thresholds
%   BHKS: Best Hanssen-Kuipers Score=>BHKS=HIR(pc) - FAR(pc)
%    BSS:  Brier Skill Score, Range: 0 to 1. Perfect score: 1
%    BSC:  Brier Score of climatology
%    BSP:  Brier Score of predictions
%    reliabilityDiag: Structure with intervals, reliabilities and resolutions used in the reliability and resolution diagrams.
%    EVA:  Economic Value Area, Range: 0 to 1. Perfect score: 1
%     EV:  Structure with Economic Values for the different cost/loss ratios.
%
% Example (a random forecast with no skill):
%      O=rand(365,1)>0.5; P=rand(365,1);
%	  struct=validationBinaryProb([],O,P,{'rsa','roc'});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
delta=20;
graph='yes'; newfigure='yes'; color='k.-';
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'points', delta = varargin{i+1};
        case 'graph', graph=varargin{i+1};
        case 'color', color=varargin{i+1};
        case 'newfigure',newfigure=varargin{i+1};
        otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
    end
end
if nargin<2,
    error('too few parameters');
end
indScore=[1:length(score)];
[a1,a2]=ismember({'rsa';'roc'},score);
if sum(a1(:))>0
    [rsa,roc]=validationROC(O,P,'graph',graph,'points',delta,'newfigure',newfigure,'color',color);
    if a1(1),struct=setfield(struct,score{a2(1)},rsa);disp(score{a2(1)}),end
    if a1(2),struct=setfield(struct,score{a2(2)},roc);disp(score{a2(2)}),end
    indScore=setdiff(indScore,a2(find(a1)));clear a2 a1
end
[a1,a2]=ismember({'bss';'bsc';'bsp'},score);
if sum(a1(:))>0
    [bss,bsc,bsp]=validationBSS(O,P);
    if a1(1),struct=setfield(struct,score{a2(1)},bss);disp(score{a2(1)}),end
    if a1(2),struct=setfield(struct,score{a2(2)},bsc);disp(score{a2(2)}),end
    if a1(3),struct=setfield(struct,score{a2(3)},bsp);disp(score{a2(3)}),end
    indScore=setdiff(indScore,a2(find(a1)));clear a2 a1
end
[a1,a2]=ismember({'eva';'ev'},score);
if sum(a1(:))>0
    [eva,ev]=validationEV(O,P,'graph',graph);
    if a1(1),struct=setfield(struct,score{a2(1)},eva);disp(score{a2(1)}),end
    if a1(2),struct=setfield(struct,score{a2(2)},ev);disp(score{a2(2)}),end
    indScore=setdiff(indScore,a2(find(a1)));clear a2 a1
end
for i=indScore
    warn=0;
    disp(score{i})
    switch lower(score{i}),
        case 'bhks',
            Z=validationBHK(O,P);
        case 'reliabilitydiag',
            Z=validationReliability(O,P,'points',delta,'newfigure',newfigure);
        otherwise, warning(sprintf('Unknown validation score: %s (ignored)',score{i})); warn=1;
    end
    if (~warn)
        struct=setfield(struct,score{i},Z);
    end
end

