function VAL=validationReliability(O,P,varargin)
%   VAL=validationReliability(O,P);
%   Computes the Reliability diagram for the
%   binary observations O and the probabilistic predictions P.
%   The vectors O and P may contain missing data (NaN values).
%
% Inputs:
%      O:  DxN matrix of discrete observations where D is the number of
%          predictions (days) and N is the number of stations.
%      P:  DxN matrix of probabilistic predictions.
%	varargin    - optional parameters
%     'points'  n, number of points in the curves (default 10).
%
% Outputs:
%    VAL:  Structure with intervals, reliabilities and resolutions.
%
% Example (a random forecast with no skill):
%      O=rand(365,1)>0.5; P=rand(365,1);
%      rsa=validationReliability(O,P)
VAL=struct('Interval',[],'Reliability',[],'Resolution',[]);
delta=0.1;
newfigure=1;

for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'points', delta = 1/varargin{i+1};
        case 'newfigure', if isequal(varargin{i+1},'no');newfigure = 0; end
        otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
    end
end

probREL=[-Inf delta:delta:1];  
[fbo,fbp]=countREL(O,P,probREL);

[D,N] = size(O);

if N==1 % Single prediction
    VAL.Reliability=nanmean(fbo,2)./nanmean(fbp,2);
    VAL.Interval=[delta/2:delta:1]';
    VAL.Resolution=nanmean(fbp,2)/sum(nanmean(fbp,2));
    
    % Reliability & Resolution diagram
    if (newfigure), figure, end
	rmax=2000; % prob=1
	rmin=30; % prob= 0
	area= rescale([VAL.Resolution;0;1;1/sum(nanmean(fbp,2))],rmin,rmax); 
	scatter(VAL.Interval,VAL.Reliability,area(1:end-3),'c','fill','MarkerFaceColor','k'),
    hold on

    scatter(0.1,0.9,rmax,'c','fill','MarkerFaceColor','k');
    text(0.2,0.9,sprintf('freq=1 (%d cases)',sum(nanmean(fbp,2))));
    scatter(0.1,0.8,area(end),'c','fill','MarkerFaceColor','k');
    text(0.2,0.8,sprintf('freq = 1/%d',sum(nanmean(fbp,2))));
    
    plot([0 1],[0 1],'-'),
    plot([0 1],[mean(O) mean(O)],'-')
    plot([0 1],[mean(O)/2 mean(O)+(1-mean(O))/2],'--b')
    title('Reliability  diagram')
    set(gca,'dataaspectratio',[1 1 1],'xlimmode','manual','xlim',[0 1],'ylimmode','manual','ylim',[0 1])
    hold off
else % Multiple prediction
    warning off MATLAB:divideByZero;
    VAL.Reliability=fbo./fbp;
    VAL.Interval=[delta/2:delta:1]';
    VAL.Resolution=fbp./repmat(sum(fbp,1),size(fbp,1),1);
    
    % Reliability & Resolution diagram
    figure, subplot(1,2,1)
    % Reshape matrix for boxplot function
    Y = reshape(repmat(VAL.Interval,1,N)',N*length(VAL.Interval),1);
    X = reshape(VAL.Reliability',N*length(VAL.Interval),1);
    nonan = intersect(find(~isnan(X)),find(~isnan(Y)));
    boxplot(X(nonan),Y(nonan),'boxstyle','filled','medianstyle','target');
    set(gca,'YLim',[0 1]);
    line(get(gca,'Xlim'),get(gca,'Ylim'),'LineStyle','--','Color',[0 0 0]);
    title('Reliability  diagram')
    
    % Reliability diagram
    subplot(1,2,2),
    Y = reshape(repmat(VAL.Interval(2:end),1,N)',N*length(VAL.Interval(2:end)),1);
    X = reshape(VAL.Resolution(2:end,:)',N*(length(VAL.Interval)-1),1);
    nonan = intersect(find(~isnan(X)),find(~isnan(Y)));
    boxplot(X(nonan),Y(nonan),'boxstyle','filled','medianstyle','target');
    set(gca,'YLim',[0 1]);
    title('Resolution diagram')
end
