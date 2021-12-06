function [RSA,ROC,BHKS]=validationROC(O,P,varargin)
%
%   [RSA,ROC,BHKS]=validationROC(O,P,varargin);
%   Computes Relative Operation Characteristics (ROC) for to the
%   binary observations O and the probabilistic predictions P.
%   The vectors O and P may contain missing data (NaN values).
%
% Inputs:
%      O:  DxN matrix of discrete observations where D is the number of
%          predictions (days) and N is the number of stations.
%      P:  DxN matrix of probabilistic predictions.
%	varargin    - optional parameters
%     'graph'  	{'yes','no'}, to display, or not, graphs (default 'yes').
%     'points'  n, number of points in the ROC curve (default 20).
%
% Outputs:
%    RSA:  Roc Skill Area, Range: 0 to 1. Perfect score: 1
%    ROC:  Structure with HIR and FAR for the different prob. thresholds
%    BHKS: Best Hanssen-Kuipers Score=>BHKS=HIR(pc) - FAR(pc)
%
% Example (a random forecast with no skill):
%      O=rand(365,1)>0.5; P=rand(365,1);
%      rsa=validationROC(O,P,'graph','no')

ROC=struct('Clim',[],'HIR',[],'FAR',[],'ProbThreshold',[]);
delta=0.05;
graph=1; newfigure=1; color='k.-';

for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'points', delta = 1/varargin{i+1};
        case 'newfigure', if isequal(varargin{i+1},'no'); newfigure = 0; end
        case 'graph', if isequal(varargin{i+1},'no'); graph=0; end
        case 'color', color=varargin{i+1};
        otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
    end
end

% Resolution of the prediction intervals
probROC=[-inf 0 (delta:delta:1)]';

% Observations-Predictions Contingency Table
[ob,nob,hi,fa]=countROC(O,P,probROC);

% Climatological occurrence probability
ROC.Clim=ob./(nob+ob);

% ROC Curve
ROC.HIR=hi./repmat(ob,[size(hi,1) 1 1]);   % HIt Rate
ROC.FAR=fa./repmat(nob,[size(fa,1) 1 1]);  % False Alarm Rate
ROC.ProbThreshold=probROC;   % probability tresholds
% ROC Skill Area
x=cat(1,ROC.FAR,[zeros([1 size(ROC.FAR,2) size(ROC.FAR,3)]);ones([1 size(ROC.FAR,2) size(ROC.FAR,3)])]);
y=cat(1,ROC.HIR,zeros([2 size(ROC.HIR,2) size(ROC.HIR,3)]));
RSA=ones([1 size(x,2) size(x,3)])+NaN;
RSA(:,:,:)=polyarea(x,y,1)*2-1;

% Best Hanssen-Kuipers Score
BHKS=validationBHK(O,P);

%%%% Graphics
if (graph)
    FAR=nanmean(ROC.FAR,2);HIR=nanmean(ROC.HIR,2);Clim=nanmean(ROC.Clim,2);
    x=cat(1,FAR,[zeros([1 size(FAR,2) size(FAR,3)]);ones([1 size(FAR,2) size(FAR,3)])]);
    y=cat(1,HIR,zeros([2 size(HIR,2) size(HIR,3)]));
    RSAm=ones([1 size(x,2) size(x,3)])+NaN;
    RSAm(:,:,:)=polyarea(x,y,1)*2-1;
    if (newfigure)
        figure
    end
    plot(FAR,HIR,color); hold on    % ROC curve
    plot([Clim Clim],[0,1],'-')             % Climatological frequency
    plot([0 1],[0 1],'-')
    set(gca,'dataaspectratio',[1 1 1])
    title(sprintf('ROC curve. RSA %1.3f',RSAm));
end

