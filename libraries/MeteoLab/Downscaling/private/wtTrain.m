function MODEL = wtTrain(X,Y,indsTrain,indsTest,method,model,XDataCluster)

MODEL = [];

% if ~ismember(method.properties.InferenceMethod,{'sim_normal','sim_unigam'})
% return;
% end

if isfield(method.properties,'ThresholdPrecip')
    thre = str2num(method.properties.ThresholdPrecip);
else
    thre = 0.1;
end

if isfield(method.properties,'minrainydays')
    minrainydays = str2num(method.properties.minrainydays);
else
    minrainydays = 10;
end

% puntos
nsite = size(Y,2);

for iwt=1:prod(model.clustering.NumberCenters)   % recorremos los tipos de tiempo
    fprintf('... WT %d of %d ... \n',iwt,model.clustering.NumberCenters)
    if strcmp(method.properties.InferenceMethod,'sim_normal')
        for isite = 1:nsite
            if ((isite/100) - fix(isite/100)) == 0
                fprintf('... station %d of %d ... \n',isite,nsite)
            end
            % compute analog days for non-NaN data
            inn = find(sum(isnan(X),2)==0 & ~isnan(Y(:,isite)));  % dias del patron X en los que no hay ningun NaN (indice no-NaN)
            bmu = nan(size(X,1),1);
            bmu(inn) = projectClustering(X(inn,:),model.clustering);  % para cada dia del patron X calculamos cual es su tipo de tiempo mas cercano
            ixTrain = intersect(find(bmu==iwt),indsTrain); % cuales de los dias del train pertenecen al tipo de tiempo iwt
            if  ~isempty(ixTrain)
                %ajusto a una normal
                [muhat, sigmahat] = normfit(Y(ixTrain,isite));
                MODEL.muhat(iwt,isite) = muhat;
                MODEL.sigmahat(iwt,isite) = sigmahat;
            else
                MODEL.muhat(iwt,isite) = NaN;
                MODEL.sigmahat(iwt,isite) = NaN;
            end
        end
    elseif strcmp(method.properties.InferenceMethod,'sim_unigam')
        for isite = 1:nsite
            % compute analog days for non-NaN data
            inn = find(sum(isnan(X),2)==0 & ~isnan(Y(:,isite)));  % dias del patron X en los que no hay ningun NaN (indice no-NaN)
            bmu = nan(size(X,1),1);
            bmu(inn) = projectClustering(X(inn,:),model.clustering);  % para cada dia del patron X calculamos cual es su tipo de tiempo mas cercano
            ixTrain = intersect(find(bmu==iwt),indsTrain); % cuales de los dias del train pertenecen al tipo de tiempo iwt
            if  ~isempty(ixTrain)
                MODEL.frecrain(iwt,isite) = sum(Y(ixTrain,isite) >= thre)/length(ixTrain);
                irain = find(Y(ixTrain,isite) >= thre);
                if isempty(irain) %% any rainy days in the train period
                    parhat = [0 0];
                    % %                 if length(irain) >= round(length(ixTrain)*0.01)
                    %% ask for a minimum of 'minrainydays' rainy days in the train period in order to perform the gamma-fitting
                elseif length(irain) >= minrainydays
                    parhat = gamfit(Y(ixTrain(irain),isite));
                    %% between 1 and 'minrainydays' rainy days in the train period
                elseif length(irain) >= 1 && length(irain) < minrainydays
                    %% retain the rain values (between 1 and 'minrainydays' days)
                    parhat = {Y(ixTrain(irain),isite)};
                end
                MODEL.parhat{iwt,isite} = parhat;
            else  %% no data for training
                MODEL.frecrain(iwt,isite) = NaN;
                MODEL.parhat{iwt,isite} = [NaN NaN];
            end
        end
    end
    MODEL.Y=Y;
end
end

