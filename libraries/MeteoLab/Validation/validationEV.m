
function [EVA,EV]=validationEV(O,P,varargin);
%
%   VAL=validationEV(O,P,varargin);
%   Computes the Economic Value (EV) for to the
%   binary observations O and the probabilistic predictions P.
%   The vectors O and P may contain missing data (NaN values).
%
% Inputs:
%      O:  DxN matrix of discrete observations where D is the number of
%          predictions (days) and N is the number of stations.
%      P:  DxN matrix of probabilistic predictions.
%	varargin    - optional parameters
%     'graph'  	{'yes','no'}, to display, or not, graphs (default 'yes').
%       'ROC'   ROC structure used to determine EV (see 'validationROC' function).
%
% Outputs:
%    EVA:  Economic Value Area, Range: 0 to 1. Perfect score: 1
%     EV:  Structure with Economic Values for the different cost/loss ratios.
%
% Example (a random forecast with no skill):
%      O=rand(365,1)>0.5; P=rand(365,1);
%      rsa=validationEV(O,P,'graph','yes')

EV=struct('Clim',[],'CL',[],'EVs',[],'Envelope',[]);
ROC=[];
graph=1;ratios=1000;

for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'ROC', ROC = varargin{i+1};
        case 'graph', if isequal(varargin{i+1},'no'); graph=0; end;
        case 'ratios',  ratios = varargin{i+1};
        otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
    end
end

% Computing the ROC curve
if (isempty(ROC))
    [RSA,ROC]=validationROC(O,P,'graph','no');
end
Nest=length(RSA);EV=struct('Clim',ROC.Clim,'CL',linspace(0,1,ratios),'EVs',repmat(NaN,[length(ROC.ProbThreshold) ratios Nest]),'Envelope',repmat(NaN,Nest,ratios),'ProbThreshold',repmat(NaN,Nest,ratios));
for i=1:Nest
    CLm=min(EV.CL,EV.Clim(i));
    aux=(ones(size(ROC.HIR(:,i)))*CLm-ROC.HIR(:,i)*EV.Clim(i)*EV.CL-ROC.FAR(:,i)*(1-EV.Clim(i))*EV.CL-(1-ROC.FAR(:,i))*EV.Clim(i)*ones(size(EV.CL)))./(ones(size(ROC.FAR(:,i)))*(CLm-EV.Clim(i)*EV.CL));
    EV.EVs(:,:,i)=aux;[EV.Envelope(i,:) ind]=max(aux,[],1);
    % Decision Threshold (probability threshold of the maximum EV).
    EV.ProbThreshold(i,:)=ROC.ProbThreshold(ind)';
end
EV.Envelope(EV.Envelope<0)=0;
EVA=polyarea(repmat(EV.CL,Nest,1),EV.Envelope,2)';

HIR=nanmean(ROC.HIR,2); FAR=nanmean(ROC.FAR,2); ProbThreshold=ROC.ProbThreshold;Clim=nanmean(ROC.Clim,2);
% EV.CL=linspace(0,1,ratios);        % Cost/Losses Ratios
CLm=min(EV.CL,Clim);

EVs=(ones(size(HIR))*CLm-HIR*Clim*EV.CL-FAR*(1-Clim)*EV.CL-(1-HIR)*Clim*ones(size(EV.CL)))./(ones(size(HIR))*(CLm-Clim*EV.CL));
[Envelope ind]=max(EVs,[],1);Envelope(Envelope<0)=0;EVAm=polyarea(EV.CL,Envelope,2);

%%%% Graphics
if (graph)
    figure;
    plot(EV.CL,EVs')
    hold on
    plot(EV.CL,Envelope,'k','LineWidth',2);
    plot([Clim Clim],[0,1],'k');
    set(gca,'dataaspectratio',[1 1 1],'xlimmode','manual','xlim',[0 1],'ylimmode','manual','ylim',[0 1])
    title(sprintf('Economic Value curve. Area %1.3f',EVAm))
end
end