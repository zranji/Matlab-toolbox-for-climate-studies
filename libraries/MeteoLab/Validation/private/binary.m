function struct=binary(struct,X,Y,score)
%Calculates different reliability scores (for binary (0/1) observations and binary (0/1) predictions). 
%
% Input:
% - X: ndata*Nest matrix with binary (0/1) observations. Timesteps along the columns and stations along the rows.
% - Y: ndata*Nest matrix with binary (0/1) forecasts. This matrix must have the same size that X.
% - score: {'freq','ratio','far'} Validation measure; 'freq' is the
% freqency of OBSERVED dry days.
% see https://www.meteo.unican.es/trac/esTcena/wiki/ValidacionGCMs for definition of the scores
% Output:
% - struct: string of structures with the same size of the input score. Each structure contains two fields:
% - scoreName: the score's name.
% - scoreValue: 1*Nest matrix with the value of the score.

%Example:
%X=rand(1000,10); X=X>0.5;
%Y=rand(1000,10); Y=Y>0.5;
%struct=binary([],X,Y,{'ratio','far'});

% scale=0;
% for i=1:2:length(varargin)
% 	switch lower(varargin{i}),
% 		case 'scale', scale=varargin{i+1};
% 		otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
% 	end
% end
if nargin<3,
    error('too few parameters');
end

%Hago double X e Y por si acaso vienen como logics
X=double(X);
Y=double(Y);

for i=1:length(score)
    warn=0;
    disp(score{i})
    switch lower(score{i}),
       case 'freq'
            Z=nansum(X==0)./size(X,1);  %frec(X=1)
        case 'ratio'
            Z=nansum(Y==0)./nansum(X==0);  %frec(Y=0/X=0)
        case 'far'
            Z=nansum(Y>0 & X==0)./nansum(X==0);  %p(Y=1 | X=0)
        otherwise, warning(sprintf('Unknown score: %s (ignored)',score{i})); warn=1;
    end
    if (~warn)
        struct=setfield(struct,lower(score{i}),Z);
    end
end
