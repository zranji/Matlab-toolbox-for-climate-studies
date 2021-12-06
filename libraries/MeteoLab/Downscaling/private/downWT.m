function Ypred=downWT(X,Y,indTrain,indTest,cluster,varargin)
%Function for statistical downscaling conditioned to weather types. First, a weather typing must be carried out (function 'makeClustering')
%over the predictors to characterize the
%different types of large-scale circulation (train period). Then, the
%downscaling is performed (test period) conditioned to these weather types, using different inference methods.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Examples of calls to the function:
%Ypred=downscalingWT(X,Y,indTrain,indTest,cluster,varargin);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Inputs:
%Ypred=downscalingWT(X,Y,indTrain,indTest,cluster,varargin);
%        - X is the matrix n*m (n=number of timesteps) of predictors. If working
%        with PCs, m would be the number of PCs retained.
%        - Y is the matrix of observationsn*p (n=number
%        of timesteps, p=number of stations or points to be downscaled).
%        - indTrain are the indices (with respect to X and Y) indicating the
%        rows destinated to training.
%        - indTest are the indices (with respect to X and Y) indicating the
%        rows destinated to test.
%        - cluster is the clustering in meteolab format (see
%        makeClustering).
%Ypred=downscalingWT(X,Y,indTrain,indTest,cluster,'method','prc75');
%        Varargin (optional arguments):
%		 - method: Inference method for downscaling. Three types can be used:
%   method:
%    'rand', 'rnd' - Random (default). For each day in the test period, the prediction is
%    given as one of the observed days within the corresponding
%    weather type, chosen by random.
%    'mean'  - Mean. The prediction is
%    given as the mean of all observed days within the corresponding
%    weather type.
%    'wmean' - Weighted mean. The prediction is given as a weighted mean
%    (where weights = inverse of the euclidean norm * normalizing constant) of all observed days withing the corresponding
%    weather type.
%    'prcXX' - Percentile XX (where XX is an integer between 0 and 100). The prediction is
%    given as the percentile XX of all observed days within the corresponding
%    weather type.
%    'sim_normal' - For gaussian-distributed variables, i.e, temperatures
%    (simulation from a fitted normal distribution)
%    'sim_unigam' - For binary (0/1) + continuous gamma-distributed
%    variables, i.e., precipitation (simulation from a uniform distribution
%    + a fitted gamma distribution)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Outputs:
%        - Ypred is the matrix ntest*p (n=timesteps in the test period) with the downscaling.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
method='rand';
model=[];
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'method', method = varargin{i+1};
        case 'model', model = varargin{i+1};
    end
end

if strcmp(method(1:3),'prc')
    method_arg = str2double(method(4:end));
    method  = 'prc';
end

if isfield(model.method.properties,'ThresholdPrecip')
    thre = str2num(model.method.properties.ThresholdPrecip);
else
    thre = 0.1;
end
% X and Y should have the same number of rows:
X_orig=X; ndates=size(X_orig,1); clear X
X=[X_orig;repmat(NaN,size(Y,1),size(X_orig,2))];
Y=[repmat(NaN,ndates,size(Y,2));model.MODEL.Y];
% puntos
nsite = size(Y,2);
% inicializo Ypred
Ypred = nan(ndates,nsite);
% compute analog days for non-NaN data
inn = find(sum(isnan(X),2)==0);  % dias del patron X en los que no hay ningun NaN (indice no-NaN)
bmu = nan(size(X,1),1);
bmu(inn) = projectClustering(X(inn,:),cluster);  % para cada dia del patron X calculamos cual es su tipo de tiempo mas cercano
%%%
for iwt=1:prod(cluster.NumberCenters)   % recorremos los tipos de tiempo
    ixTrain = intersect(find(bmu==iwt),indTrain); % cuales de los dias del train pertenecen al tipo de tiempo iwt
    ixTest  = intersect(find(bmu==iwt),indTest); % cuales de los dias del train pertenecen al tipo de tiempo iwt
    ixTrain=ixTrain+ndates;% adaptation of train indices due to the Y transformation
    if ~isempty(ixTest) && ~isempty(ixTrain)
        switch lower(method),
            case {'rand','rnd'}
                r = randperm(length(ixTrain));
                Ypred(ixTest,:) = repmat(Y(ixTrain(r(1)),:),length(ixTest),1);
            case 'mean'
                Ypred(ixTest,:) = repmat(nanmean(Y(ixTrain,:),1),length(ixTest),1);
            case 'wmean'
                [dum, distances]=MLknn(cluster.Centers(iwt,:),X(ixTrain,:),length(intersect(ixTrain,cluster.Group{iwt})),'Norm-2');
                ctenorm=1/sum(1./(distances));   %cte de normalizacion para que la suma de los pesos sea 1
                pesos=ctenorm./distances';   %la suma de los pesos es 1
                Ypred(ixTest,:) = repmat((pesos')*Y(ixTrain,:),length(ixTest),1);
            case 'prc'
                Ypred(ixTest,:) = repmat(prctile(Y(ixTrain,:),method_arg),length(ixTest),1);
            case 'sim_normal'
                for isite = 1:nsite
                    Ypred(ixTest,isite) = normrnd(model.MODEL.muhat(iwt,isite),model.MODEL.sigmahat(iwt,isite),length(ixTest),1);
                end
                clear muhat sigmahat
            case 'sim_unigam'
                bin = nan(length(ixTest),nsite);
                cont = nan(length(ixTest),nsite);
                for isite = 1:nsite
                    if ~isnan(model.MODEL.frecrain(iwt,isite))
                        bin(:,isite) = rand(length(ixTest),1) < model.MODEL.frecrain(iwt,isite); %% simuate occurrence from a uniform distribution
                    else
                        bin(:,isite) = nan(length(ixTest),1);  %% no data for train
                    end
                    parhat = model.MODEL.parhat{iwt,isite};
                    if iscell(parhat)
                        r = ceil(rand(length(ixTest),1)*length(parhat{1}));  %% random rain values
                        cont(:,isite) = parhat{1}(r);
                    else
                        cont(:,isite) = gamrnd(parhat(1),parhat(2),length(ixTest),1);  %% simulate amount from a gamma distribution
                    end
                    clear parhat
                end
                Ypred(ixTest,:) = bin.*cont; %% combine binary and continuous predictions
                clear bin cont
            otherwise
                error('Inference method not known')
        end
    end
end
Ypred=Ypred(indTest,:);
end
