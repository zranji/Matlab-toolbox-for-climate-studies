function [Ypred, Pocc] = downOccVal(X,Model,indTest,varargin)
%Second function (see also 'downOccFit') to downscale occurrence (1)/non occurrence (0)
%of precipitation using Generalized Linear Models (GLMs).
%The 'Model' returned by 'downGLMFit' is used to predict.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Examples of calls to the function:
%Ypred = downOccVal(X,Y,Model,indTest);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Inputs:
%Ypred = downOccVal(X,Y,Model,indTest);
%        - X is the matrix n*m (n=number of timesteps) of predictors. If
%        working with PCs, m would be the number of PCs retained.
%        - Y is the matrix of observed precipitation n*p (n=number
%        of timesteps, p=number of stations or points to be downscaled).
%        - indTest are the indices (with respect to X and Y) indicating the
%        rows destinated to test.
%        - Model is the model returned by 'downOccFit'.
%Ypred = downOccVal(X,Y,Model,indTest,'sim','false');
%        Varargin (optional arguments for 'glmfit' function):
%		 - sim: 'true' to simulate occurrence by comparing with random probabilities (if P > rand --> Occ = 1),
%        'false' (default) to not simulate (if P > climatological adjusted threshold --> Occ = 1).
%        - m: size of the ensemble of simulations (m=1 by default). It is
%        only considered if sim = 'true'.
%        - threprob: probability threshold considered to predict rain/no
%        rain, e.g., threprob = 0.5. It is only considered when sim = 'true'. By default
%        threprob is not specified (which would correspond to sim =
%        'false').
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Outputs:
%        - Ypred is the matrix ntest*p (n=timesteps) of
%        donwscaled occurrence (1)/non occurrence (0) of precipitation (test period).
%        - Pocc is the matrix ntest*p (n=timesteps) of probabilities [0, 1](test period).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rand('seed',sum(clock));
sim = 'false';
m = 1;
threprob = '';  %%umbral considerado en la simulacion de la ocurrencia (if P > threprob --> Occ = 1)
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'sim', sim = varargin{i+1};
        case 'm', m = varargin{i+1};
        case 'threprob', threprob = varargin{i+1};
        otherwise
            warning(sprintf('Option ''%s'' not supported. Ignored.',varargin{i}))
    end
end

if ischar(m)
    m = str2num(m);
end
if ~strcmp(sim,'true') && m~=1
    warning('Option sim = %s, m will be set to 1',sim)
end

step = 0:0.001:1;  %necesario para ajustar la ocurrencia en funcion de un umbral climatologico (sim='false')

%% para mantener la retrocompatibilidad
if strcmp(sim, 'falsecal')
    sim = 'false';
    threprob = '';
elseif strcmp(sim, 'falsenocal')
    sim = 'false';
    threprob = 0.5;
end

%% inicializo salida
Pocc = nan(length(indTest),size(Model.stats,2));
if strcmp(sim,'true')
    Ypred = nan(length(indTest),m,size(Model.stats,2));
else
    Ypred = nan(length(indTest),size(Model.stats,2));
end
indNaNX=find(sum(isnan(X(indTest,:)),2)>0);
%Bucle para recorrer todas las estaciones (puntos)
for isite=1:size(Model.stats,2)
    if ~isempty(Model.stats{isite})
        P = glmval(Model.stats{isite}.beta,X(indTest,:),Model.link,Model.stats{isite});
        P(indNaNX)=NaN;% La funcion glmval asigna un 0 a los dias con NaNs en el predictor.
        Pocc(:,isite) = P;
        if strcmp(sim,'true')
            %% opcion simulacion 1 (dist. uniforme)
            Yp=nan(length(indTest),m,1);
            for iens=1:m
                %% simulo probabilidades al azar (desde una distribucion uniforme),
                %% y si la probabilidad predicha, P, es mayor que el
                %% numero aleatorio doy Occ = 1
                %                 Yp(:,iens) = P > rand(1,length(indTest))';
                %% simulo desde una binomial con numero intentos=1 y prob. exito = P (dist. Bernouilli)
                Yp(:,iens,1)=binornd(1,P);
            end
            Yp(indNaNX,:,1)=NaN;
            Ypred(:,:,isite) = Yp;
        elseif strcmp(sim,'false')
            if isempty(threprob)
                %% opcion no simular (umbral climatologico)
                clear aux
                for istep = 1:length(step)
                    aux(istep) = sum(P > step(istep))/length(P);
                end
                clim = min(step(find(abs(aux-Model.prain(isite)) == min(abs(aux-Model.prain(isite))))));
                Ypred(:,isite) = P > clim;
            else
                %% opcion no simular (umb = 'threprob')
                Ypred(:,isite) = P > str2double(threprob);
            end
            Ypred(indNaNX,isite)=NaN;
        end
    else
        warning('Model could not be fitted due to lack of training data. Predictions = NaN')
        if strcmp(sim,'true')
            Ypred(:,:,isite)=nan(length(indTest),m,1);
        else
            Ypred(:,isite)=nan(length(indTest),1);
        end
    end
end
if m==1 && strcmp(sim,'true')
    %Paso Ypred de celda a matriz
    Ypred=squeeze(Ypred);
end
end

