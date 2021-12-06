function Ypred = downGLMVal(X,Model,indTest,varargin)
%Second function (see also 'downGLMFit) to downscale precipitation using Generalized Linear Models
%(GLMs). The 'Model' returned by 'downGLMFit' is used to predict.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Examples of calls to the function:
%Ypred=downGLMVal(X,Y,Model,indTest)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Inputs:
%Ypred = downGLMVal(X,Y,Model,indTest);
%        - X is the matrix n*m (n=number of timesteps) of predictors. If working
%        - Y is the matrix of observed precipitation n*p (n=number
%        of timesteps, p=number of stations or points to be downscaled).
%        - indTest are the indices (with respect to X and Y) indicating the
%        rows destinated to test.
%        - Model is the model returned by 'downGLMFit'.
%Ypred = downGLMVal(X,Y,Model,indTest,'sim','false');
%        Varargin:
%		 - sim: 'true' (by default) to simulatea rainfall amount, 'false'
%		 to not simulate.
%        - m: size of the ensemble of simulations (m=1 by default). It is
%        only considered if sim = 'true'.
%        - pec: percentil used for correction of simulated extremes, e.g., pec
%        = 95 (pec = '' by default, i.e., no extremes correction).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Outputs:
%        - Ypred is the matrix ntest*p (n=timesteps in the test period) of
%        donwscaled precipitation (test period).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rand('seed',sum(clock));
sim='true';
% per='all';
m=1;
pec = '';  %% percentil usado para corregir la simulacion de los extremos (por defecto no se corrigen los extremos)
sup = 10^4; %% cota superior para evitar outliers 'raros' predichos
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'sim', sim = varargin{i+1};
            %         case 'per', per = varargin{i+1};
        case 'm', m = varargin{i+1};
        case 'pec', pec = varargin{i+1};
        case 'sup', sup = varargin{i+1};
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

%% inicializo salida
if strcmp(sim,'true')
    Ypred = nan(length(indTest),m,size(Model.stats,2));
else
    Ypred = nan(length(indTest),size(Model.stats,2));
end
%nnX = find(sum(isnan(X),2) == 0);
%[dum iTest] = intersect(nnX,indTest);
%XTest=X(iTest,:);
%Bucle para recorrer todas las estaciones (puntos)
indNaNX=find(sum(isnan(X(indTest,:)),2)>0);

for isite=1:size(Model.stats,2)
    %Predecimos el valor esperado para el test, utilizando el modelo
    %aprendido con 'downGLMFit' -- 'glmval' asume el mismo parametro de forma
    %(inverso del parametro de dispersion calculado por 'glmfit' y guardado en 'Model')
    %para todos los dias y para cada dia da una media distinta --> lo que
    %cambia de dia en dia es el parametro de escala
    % % %     if ~isempty(Model.stats{isite})
    if isstruct(Model.stats{isite})
        Yp = glmval(Model.stats{isite}.beta,X(indTest,:),Model.link);
        Yp(indNaNX)=NaN; % La funcion glmval asigna un 0 a los dias con NaNs en el predictor.
% % %         %% cota superior para outliers 'raros'
% % %         Yp(Yp > sup) = NaN;
        
        if strcmp(sim,'true')
            % OPTION 1. Theoretical implementation (by default)
            %% http://www.mathworks.es/matlabcentral/newsreader/view_thread/241404
            %% http://www.mathworks.es/matlabcentral/newsreader/view_thread/237941
            %% GLM assumes that var=f(mu)*s. For gamma, f(mu)=mu^2
            phi=(Model.stats{isite}.s).^2;
            shape1 = 1/phi;   %'s' es el parametro de dispersion estimado por el GLM en el train
            scale1 = Yp.*phi; %Yp./shape1;
            %sprintf('shape %3.2f scale %3.2f',shape,scale)
            
            % OPTION 2. Empirical implementation
            % Does not work properly since variance do not decompose into predicted + residual
            vemp=nanstd(Model.stats{isite}.resid).^2;
            shape2=Yp.^2./vemp;
            scale2=vemp./Yp;
            
            % % %             % OPTION 3. Forcing the mean and variance, but accounting for
            % % %             % the predicted variance.
            % % %             vv=phi*mean(Yp)^2-var(Yp);   % phi*mean(Yp)^2 is the total variance
            % % %             shape3=Yp.^2/vv;
            % % %             scale3=vv./Yp;
            
            if isempty(pec)
                %simulacion de acuerdo al modelo teorico: mantengo el
                %parametro de forma fijo
                scale = scale1;
                shape = shape1;
            else
                % MIXED OPTION
                %simulacion hibrida teorica-empirica:
                %mantengo el parametro de forma fijo para todos aquellos
                %valores predichos (valor esperado) por debajo del
                %percentil 'pec', mientras que lo dejo variar (de acuerdo
                %al valor calculado en 'OPTION 2') para los
                %valores por encima del percentil 'pec'
                % TODO - Reimplement in GLMtrain. threshold=Inf -> standard implementation
                scale=scale1; shape=shape1*ones([length(scale) 1]);
                ii=find(Yp>prctile(Yp, str2double(pec)));  %% OJO: correcion de extremos!
                scale(ii)=scale2(ii); shape(ii)=shape2(ii);
            end
            clear scale1 shape1 scale2 shape2
            
            Ypp=nan(length(indTest),m,1);
            for iens=1:m
                clear temp
                temp = gamrnd(shape,scale);
                %temp = gamrnd(k,teta);
                %temp(temp < Model.umb) = Model.umb;
                Ypp(:,iens,1)=temp;
            end
            Ypp(indNaNX,:,1)=NaN;
            Ypred(:,:,isite) = Ypp; clear Ypp
        elseif strcmp(sim,'false')
            %Damos como prediccion el valor predicho por el GLM (valor esperado)
            Ypred(:,isite) = Yp; clear Yp
            Ypred(indNaNX,isite)=NaN;            
        end
    else
        if isempty(Model.stats{isite})  %%no data for train
            warning('No data for training. GLM could not be fitted; predictions = NaN')
            if strcmp(sim,'true')
                Ypred(:,:,isite)=nan(length(indTest),m,1);
            else
                Ypred(:,isite)=nan(length(indTest),1);
            end
        elseif isnan(Model.stats{isite})  %%zero rainy days in the train period --> predictions = 0
            if strcmp(sim,'true')
                Ypred(:,:,isite)=zeros(length(indTest),m,1);
            else
                Ypred(:,isite)=zeros(length(indTest),1);
            end
        elseif sum(~isnan(Model.stats{isite})) >= 1  %%between 1 and 'Model.minrainydays' rainy days in the train period
            warning('GLM could not be fitted (less than %d days with rain > %0.3f). Predictions = One rain value chosen at random',Model.minrainydays,Model.umb)
            if strcmp(sim,'true')
                r = ceil(rand(length(indTest),m)*length(Model.stats{isite}));
                Ypred(:,:,isite) = Model.stats{isite}(r);
            else
                r = ceil(rand(length(indTest),1)*length(Model.stats{isite}));
                Ypred(:,isite) = Model.stats{isite}(r);
            end
            
        end
    end
end
if m==1 && strcmp(sim,'true')
    %Paso Ypred de celda a matriz
    Ypred=squeeze(Ypred);
end
        %% cota superior para outliers 'raros'
        Ypred(Ypred > sup) = NaN;
end

