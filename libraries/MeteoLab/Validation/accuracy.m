function struct=accuracy(struct,X,Y,score,varargin)
%Calculates different accuracy scores
%
% Input:
% - X: ndata*Nnodes matrix with the observations. Timesteps along the columns and stations (or nodes) along the rows.
% - Y: ndata*Nnodes matrix with the forecasts. This matrix must have the same size that X.
% - score: {'mae','maestd','maeiqr','rmse','rmsestd','rmsestd','rmseiqr','maemean','r','rho'} Validation measure	%
% see https://www.meteo.unican.es/trac/esTcena/wiki/ValidacionGCMs for definition of the scores
% Output:
% - struct: string of structures with the same size of the input score. Each structure contains two fields:
% - scoreName: the score's name.
% - scoreValue: 1*Nnodes matrix with the value of the score.

%Example:
%X=rand(1000,10)
%Y=rand(1000,10)
%[struct]=accuracy({'score'},X,Y,{'rmsestd','capullo'});

scale=0;
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'scale', scale=varargin{i+1};
        otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
    end
end
if nargin<3,
    error('too few parameters');
end
for i=1:length(score)
    warn=0;
    disp(score{i})
    switch lower(score{i}),
        case 'mae',
            Z=mae(X,Y);
        case 'maestd',
            Z=mae(X,Y,'scale','std');
        case 'maeiqr',
            Z=mae(X,Y,'scale','iqr');
        case 'maemean',
            Z=mae(X,Y,'scale','mean');
        case 'rmse',
            Z=rmse(X,Y);
        case 'rmsemean',
            Z=rmse(X,Y,'scale','mean');
        case 'rmsestd',
            Z=rmse(X,Y,'scale','std');
        case 'rmseiqr',
            Z=rmse(X,Y,'scale','iqr');
            %calculate Spearman correlation coefficient
        case {'r','spearman'}
            Z=repmat(NaN,1,size(X,2));
            for j=1:size(X,2),Z(j)=testSpearman(X(:,j),Y(:,j));end
            %calculate Pearson correlation coefficient
        case {'rho','pearson'}
            Z=repmat(NaN,1,size(X,2));
            for j=1:size(X,2),Z1=nancorrcoef([X(:,j),Y(:,j)]);Z(j)=Z1(1,2);end
        otherwise, warning(sprintf('Unknown accuracy score: %s (ignored)',score{i})); warn=1;
    end
    if (~warn)
        struct=setfield(struct,lower(score{i}),Z);
    end
end

%%%% MAE %%%%
function Z=mae(X,Y,varargin)
scale=0;
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'scale', scale=varargin{i+1};
        otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i})); warn=1;
    end
end
switch scale
    case {0,'no','noscale'}
        Z=nanmean(abs(Y-X));
    case {'iqr'}
        Z=nanmean(abs(Y-X))./iqr(X);
    case {'std'}
        Z=nanmean(abs(Y-X))./sqrt(nanvar(X));
    case {'mean'}
        Z=nanmean(abs(Y-X))./nanmean(X);
end

%%%% RMSE %%%%
function Z=rmse(X,Y,varargin)
if nargin<2,
    error('too few p1arameters');
end
scale=0;
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'scale', scale=varargin{i+1};
        otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
    end
end
switch scale
    case {0,'no','noscale'}
        Z=sqrt(nanmean((Y-X).^2));
    case {'iqr'}
        Z=sqrt(nanmean((Y-X).^2))./iqr(X);
    case {'std'}
        Z=sqrt(nanmean((Y-X).^2))./sqrt(nanvar(X));
    case {'mean'}
        Z=nanmean(abs(Y-X))./nanmean(X);
end