function validation=validatePrediction(X,Y,varargin)
%Function to validate daily predictions (for precipitation see function 'validatePredictionPrecip').
%It receives daily observations (X) and daily predictions (Y) as inputs and
%generates a structure with the scores from the validations of the daily data (validation.daily) and the
%'nagg'-daily aggregated data (validation.agg). A graphical panel showing the performance of the predictions is also generated.
%
%
%Inputs:
%
%X: column vector of observations.
%Y: column vector of predictions.
%
%varargin:
%'pnanlim': maximum percentage of missing data allowed to calculate validation scores (75 by default).
%'nagg': number of timesteps (days) considered for aggregation (10 by
%default).
%'aggFun': type of aggregation; 'nanmean',
%'nansum' (default)`, 'nanmin','nanmax'.
%'missing': maximun percentage of missing data (i.e. NaN) permitted per
%group for the aggregation (25 by default).
%'dbins': number of bins considered for plotting PDFs (10 by
%default).
%'dirout': path of the desired directory to save output structure and
%panel.
%
%Output:
%
%validation.daily: Structure with the next fields:
%validation.daily.X: Descriptive statistics related to the observations.
%validation.daily.Y: Descriptive statistics related to the predictions.
%validation.daily.acc: Statistics related to the accuracy of the
%predictions.
%validation.daily.rel: Statistics related to the distributional similarity
%between observations and predictions.
%
%validation.agg: Structure analogue to 'validation.daily' but for the 'nagg'-daily aggregated
%data.
%%%
%% varargin
pnanlim=75;  %porcentaje de NaNs permitidos (si se supera este porcentaje todos los scores de validacion son fijados a NaNs)
nagg=10;
aggFun='nanmean';
missing=25;
dbins=100;
dirout='';
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'nagg', nagg=varargin{i+1};
        case 'aggFun', aggFun=varargin{i+1};
        case 'missing', missing=varargin{i+1};
        case 'dbins', dbins=varargin{i+1};
        case 'dirout', dirout=varargin{i+1};
    end
end
%% tamanio muestra
if length(X) == length(Y)
    n = length(X);
else
    error('X and Y must have the same size')
end
%% scores
s_sta={'mean','median','std','iqr','min','max','pct10','pct90','nan'};
s_acc={'rho','mae','maemean','maestd','rmse','rmsemean','rmsestd'};
s_rel={'bias','biasstd','rv','kspvalue','ks10pvalue','ks90pvalue','pdfscore'};
%% labels
l_sta={'Mean','Median','Sigma','IQR','Min','Max','P10','P90','Missing'};
l_acc={'rho','MAE','nMAE','NMAE','RMSE','nRMSE','NRMSE'};
l_rel={'Bias','NBias','RV','KS-pValue','KS10-pValue','KS90-pValue','PDF-Score'};
%% comprobacion NaNs
pnanX = sum(isnan(X))/length(X)*100;
pnanY = sum(isnan(Y))/length(Y)*100;
if pnanX >= pnanlim
    warning(sprintf('More than 75%% (%0.2f%%) of the observations are NaNs',pnanX))
    X = nan(size(X));
end
if pnanY >= pnanlim
    warning(sprintf('More than 75%% (%0.2f%%) of the observations are NaNs',pnanY))
    Y = nan(size(Y));
end
%% validacion diaria
sX=statistics({},X,s_sta);
sY=statistics({},Y,s_sta);
a=accuracy({},X,Y,s_acc);
r=reliability({},X,Y,s_rel);
%% observaciones agregadas
Xagg=[];
for iblock = 1:nagg:n
    if iblock+nagg-1 <= n
        aux = X(iblock:iblock+nagg-1);
        if sum(isnan(aux)) < round(missing/100*nagg)
            Xagg = [Xagg; eval(sprintf('%s(aux)',aggFun))];
        else
            Xagg = [Xagg; NaN];
        end
    end
end
%% predicciones agregadas
Yagg=[];
for iblock = 1:nagg:n
    if iblock+nagg-1 <= n
        aux = Y(iblock:iblock+nagg-1);
        if sum(isnan(aux)) < round(missing/100*nagg)
            Yagg = [Yagg; eval(sprintf('%s(aux)',aggFun))];
        else
            Yagg = [Yagg; NaN];
        end
    end
end
%% comprobacion NaNs
pnanXagg = sum(isnan(Xagg))/length(Xagg)*100;
pnanYagg = sum(isnan(Yagg))/length(Yagg)*100;
if pnanXagg >= pnanlim
    warning(sprintf('More than 75%% (%0.2f%%) of the observations are NaNs',pnanXagg))
    Xagg = nan(size(Xagg));
end
if pnanYagg >= pnanlim
    warning(sprintf('More than 75%% (%0.2f%%) of the predictions are NaNs',pnanYagg))
    Yagg = nan(size(Yagg));
end
%% validacion agregada
sXagg=statistics({},Xagg,s_sta);
sYagg=statistics({},Yagg,s_sta);
aagg=accuracy({},Xagg,Yagg,s_acc);
ragg=reliability({},Xagg,Yagg,s_rel);
%% panel validacion
%if pnanX < pnanlim && pnanY < pnanlim
    figure
    %% scatter plot observacion-prediccion
    subplot(2,2,1);
    plot(X,Y,'.');
    xlabel('Observed');
    ylabel('Predicted');
    title(sprintf('rho: %0.3f',a.rho))
    m = nanmin([X;Y]);
    M = nanmax([X;Y]);
    if ~sum(isnan([m M])) && m~=M
        set(gca,'XLim',[m M]);
        set(gca,'YLim',[m M]);
        line([m M],[m M],'Color',[0 0 0]);
    end
    %% plot PDFs observada y predicha
    subplot(2,2,2);
    [dpYagg,binYagg] = pdfplot(Yagg,dbins);
    [dpXagg,binXagg] = pdfplot(Xagg,dbins);
    plot(binXagg,dpXagg,'-k');hold on; plot(binYagg,dpYagg,'-r');
    legend({sprintf('Observed%d',nagg),sprintf('Predicted%d',nagg)},'FontSize',6);
    xlabel(sprintf('Observed%d & Predicted%d',nagg,nagg))
    ylabel('Probability Density');
    title(sprintf('KS-pValue: %0.3f, PDF-Score: %0.3f',ragg.kspvalue,ragg.pdfscore))
    %% scatter plot observacion-prediccion (dato agregado)
    subplot(2,2,3);
    plot(Xagg,Yagg,'.');
    xlabel(sprintf('Observed%d',nagg));
    ylabel(sprintf('Predicted%d',nagg));
    title(sprintf('rho: %0.3f',aagg.rho))
    m = nanmin([Xagg;Yagg]);
    M = nanmax([Xagg;Yagg]);
    if ~sum(isnan([m M])) && m~=M
        set(gca,'XLim',[m M]);
        set(gca,'YLim',[m M]);
        line([m M],[m M],'Color',[0 0 0]);
    end
    %% Q-Q plot observacion-prediccion (dato agregado)
    subplot(2,2,4);
    qqplot(Xagg,Yagg,1:100);
    hold on;
    m = nanmin([Xagg;Yagg]);
    M = nanmax([Xagg;Yagg]);
    if ~sum(isnan([m M])) && m~=M
        set(gca,'XLim',[m M]);
        set(gca,'YLim',[m M]);
        line([m M],[m M],'Color',[0 0 0]);
    end
    xlabel(sprintf('Observed%d percentiles',nagg));
    ylabel(sprintf('Predicted%d percentiles',nagg));
    title('Q-Q Plot')
    %% salvo panel
    if ~isempty(dirout)
        eval(sprintf('print -dpng ''%s/validation''',dirout));
        disp('Panel has been saved to disk')
        close
    end
%end
%% estructura de salida
%% dato diario
validation.daily.X.scores=cell2mat(struct2cell(sX));  validation.daily.X.labels=l_sta';
validation.daily.Y.scores=cell2mat(struct2cell(sY));  validation.daily.Y.labels=l_sta';
validation.daily.acc.scores=cell2mat(struct2cell(a));  validation.daily.acc.labels=l_acc';
validation.daily.rel.scores=cell2mat(struct2cell(r));  validation.daily.rel.labels=l_rel';
%% dato agregado
validation.agg.X.scores=cell2mat(struct2cell(sXagg));  validation.agg.X.labels=l_sta';
validation.agg.Y.scores=cell2mat(struct2cell(sYagg));  validation.agg.Y.labels=l_sta';
validation.agg.acc.scores=cell2mat(struct2cell(aagg));  validation.agg.acc.labels=l_acc';
validation.agg.rel.scores=cell2mat(struct2cell(ragg));  validation.agg.rel.labels=l_rel';
%% salvo estructura
if ~isempty(dirout)
    eval(sprintf('save %s/validation validation',dirout));
end
end

