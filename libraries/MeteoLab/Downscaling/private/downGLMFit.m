function Model = downGLMFit(X,Y,indTrain,varargin)
%First function (see also 'downGLMVal') to downscale precipitation using Generalized Linear Models
%(GLMs). A predictive model is learnt by fitting precipitation to a gamma distribution (
%only rainys days are considered).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Examples of calls to the function:
%Model=downGLMFit(X,Y,indTrain,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Inputs:
%Model=downGLMFit(X,Y,indTrain,varargin)
%        - X is the matrix n*m (n=number of timesteps) of predictors. If working
%        with PCs, m would be the number of PCs retained.
%        - Y is the matrix of observed precipitation n*p (n=number
%        of timesteps, p=number of stations or points to be downscaled).
%        - indTrain are the indices (with respect to X and Y) indicating the
%        rows destinated to training.
%Model=downGLMFit(X,Y,indTrain,'dist','gamma','link','logit')
%        Varargin:
%		 - dist (optional argument for 'glmfit'):
%        distribution to which fit the occurrence model; ('gamma' by default).
%		 - link (optional argument for 'glmfit'):
%        link function for the occurrence model; ('log' by default).
%        - umb: threshold beyond which a day is considered rainy (same
%        units as Y, 0.1 by default).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Outputs:
%        - Model is the structure containing the results from the learnt model:
%               Model.dist: fitted distribution.
%               Model.link: link function used.
%               Model.umb: threshold considered for rainy days.
%               Model.stats: coefficients and statistics from the fitting (see 'glmfit' for more info).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dist='gamma';
link='log';
umb=0.1;
minrainydays=10;
% % minprainyd=1; %porcentaje minimo de dias de lluvia (con respecto a los dias del train) pedido para hacer el ajuste
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'dist', dist = varargin{i+1};
        case 'link', link = varargin{i+1};
        case 'umb', umb = varargin{i+1};
        case 'minrainydays', minrainydays = varargin{i+1};
        otherwise
            warning(sprintf('Option ''%s'' not supported. Ignored.',varargin{i}))
    end
end
if ischar(umb)
    umb = str2num(umb);
end
if ischar(minrainydays)
    minrainydays = str2num(minrainydays);
end
%%%
%Inicializo Ypred y Model
Model=[];
Model.dist=dist;
Model.link=link;
Model.umb=umb;
Model.minrainydays=minrainydays;
%%%
%'gamfit' y 'glmfit' no se tragan NaNs!
nnX = find(sum(isnan(X),2) == 0);
%Bucle para recorrer todas las estaciones (puntos)
for isite=1:size(Y,2)
    nnY = find(isnan(Y(:,isite)) == 0);
    nn=intersect(nnX,nnY);
    %     YT = Y(nn,isite);
    %     parhatT=gamfit(YT (YT >= umb));
    %     Model.shapeT(isite)=parhatT(1); clear parhatT
    iTrain = intersect(nn,indTrain);
    
    if ~isempty(iTrain)
        YTrain = Y(iTrain,isite);
        XTrain = X(iTrain,:);
        YTrainRain = YTrain(YTrain >= umb);
        XTrainRain = XTrain(YTrain >= umb,:);
        %     parhatTrain=gamfit(YTrainRain);
        %     Model.shapeTrain(isite)=parhatTrain(1); clear parhatTrain
        
        %         dum =  gamfit(YTrainRain);
        %         Model.shape(isite) = dum(1);
        % %         if length(YTrainRain) >= length(YTrain)*minprainyd/100
        if isempty(YTrainRain)
            Model.stats{isite} = NaN;
        elseif length(YTrainRain) >= minrainydays
            %% ask for a minimum of 'minrainydays' rainy days in the train period in order to adjust the GLM
            [dum1,dum2,stats] = glmfit(XTrainRain,YTrainRain,dist,'link',link);
            Model.stats{isite}=stats;
            clear dum1 dum2 stats
            %% between 1 and 'minrainydays' rainy days in the train period
        elseif length(YTrainRain) >= 1 && length(YTrainRain) < minrainydays
            % %             warning('Less than %0.3f%% of rainy days (rain > %0.3f) in the train period in station %d. Impossible to fit GLM.',minprainyd,umb,isite)
            warning('Less than %d rainy days (rain > %0.3f) in the train period. Impossible to fit GLM.',minrainydays,umb)
            % %             Model.stats{isite} = [];
            % %             r = ceil(rand*length(YTrainRain));
            % %             Model.stats{isite} = YTrainRain(r);  %selecciono un dia de lluvia (de los menos de 5) del train al azar
            %% retain the rain values (between 1 and 'minrainydays' days)
            Model.stats{isite} = YTrainRain;
        end
    else
        warning('No data for training')
        Model.stats{isite} = [];
    end
end
end

