function PredNew = inflation(Pred,Obs,varargin)
%PredNew = inflation(Pred,Obs,varargin)
%
% Inflation of predictions.
%
% Input : 
%	Pred   : is the m(time)*n(stations) matrix of predictions to be inflated.
%	Obs    : is the m*n matrix of observations.
%
%	varargin    : optional parameters
%		'method'	-	Inflating method 
%                       {'variance'} inflates the variance 
%                       'rank' inflates the centile intervals
%       'intervals' -   number of intervals for rank inflation (between 1 and {100}).
%       'precip'    -   wether or not the data is precipitation ({0}, 1).
%       'reference' -   referece series auxiliar for rank inflation.
%
% Output:
%	PredNew	    : m*n matrix with the inflated predictions.

method='variance';
intervals=100;
predAux=[];
precip=0;
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'method', method = lower(varargin{i+1});
        case 'intervals', intervals=varargin{i+1};
        case 'reference', predAux = varargin{i+1};
        case 'precip', precip = varargin{i+1};
    end
end
if(size(Pred,1)<intervals) 
    intervals=size(Pred,1); 
end

q=[0:ceil(100/intervals):100]';
if (strcmp(method,'variance'))
    s=nanstd(Obs)./nanstd(Pred);
    PredNew=Pred.*repmat(s,[size(Pred,1) 1]);
end
if (strcmp(method,'rank'))
    if (precip)
        if(isempty(predAux)) 
            predAux=rand(size(Pred))*0.001;
            warning('Using random data as reference series in the rank inflation.');
        end
        k=find(Pred==0);
        Pred(k)=predAux(k)/1000;
    end
    PredNew=zeros(size(Obs));
    for noEst=1:size(Obs,2)
        sinNan=find(~isnan(Obs(:,noEst)));
        p=prctile([Obs(sinNan,noEst),Pred(sinNan,noEst)],q);
        qPred=interp1q(p(:,2),q,Pred(:,noEst));
        PredNew(:,noEst)=interp1q(q,p(:,1),qPred);
    end
end
