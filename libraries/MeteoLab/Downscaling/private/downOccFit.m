function Model = downOccFit(X,Y,indTrain,varargin)
%First function (see also 'downOccVal') to downscale occurrence (1)/non occurrence (0) 
%of precipitation using Generalized Linear Models (GLMs).
%A predictive model is fitted using observations in the train to predict in the test.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Examples of calls to the function:
%Model=downOccFit(X,Y,indTrain,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Inputs:
%Model=downOccFit(X,Y,indTrain,varargin)
%        - X is the matrix n*m (n=number of timesteps) of predictors. If working
%        with PCs, m would be the number of PCs retained.
%        - Y is the matrix of observed precipitation n*p (n=number
%        of timesteps, p=number of stations or points to be downscaled).
%        - indTrain are the indices (with respect to X and Y) indicating the
%        rows destinated to training.
%Model=downOccFit(X,Y,indTrain,'dist','binomial','link','logit')
%        Varargin (optional arguments for 'glmfit' function):
%		 - dist: distribution to which fit the occurrence model; ('binomial' by default).
%		 - link: link function for the occurrence model; ('logit' by default).
%        - umb: threshold beyond which a day is considered rainy (same
%        units as Y, 0.1 by default).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Outputs:
%        - Model is the structure containing the results from the learnt model.
%               Model.dist: fitted distribution.
%               Model.link: link function used.
%               Model.umb: threshold considered for rainy days.
%               Model.stats: statistics from the fitting.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dist='binomial';
link='logit';
umb=0.1;
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'dist', dist = varargin{i+1};
        case 'link', link = varargin{i+1};
        case 'umb', umb = varargin{i+1};
        otherwise
            warning(sprintf('Option ''%s'' not supported. Ignored.',varargin{i}))
    end
end
if ischar(umb)
    umb = str2num(umb);
end
%%%
%Inicializo Ypred y Model
Model=[];
Model.dist=dist;
Model.link=link;
Model.umb=umb;
%%%
%'glmfit' no se traga los NaNs
nnX = find(sum(isnan(X),2) == 0);
%Bucle para recorrer todas las estaciones (puntos)
for isite=1:size(Y,2)
    nnY = find(isnan(Y(:,isite)) == 0);
    nn=intersect(nnX,nnY);
    iTrain=intersect(nn,indTrain);
    if ~isempty(iTrain)
        YTrain=Y(iTrain,isite);
        XTrain=X(iTrain,:);
        prain = sum(YTrain >= umb)/length(YTrain);
        %Regresion logistica para la ocurrencia
        [b,dum,stats] = glmfit(XTrain,YTrain >= umb,dist,link);
        clear b dum
        %%%
        %Guardo los coeficientes y estadisticos del ajuste
        Model.stats{isite}=stats;
        Model.prain(isite)=prain;
        clear b stats prain
        %%%
    else
        warning('No data for training')
        Model.stats{isite} = [];
        Model.prain(isite) = NaN;
    end
end
end

