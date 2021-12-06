function validation=validatePredictionPrecip(X,Y,varargin)
%Function to validate daily predictions of precipitation. It receives daily observations (X) and daily predictions (Y) as inputs and
%generates a structure with the scores from the validations of the daily data (validation.daily) and the
%'nagg'-daily aggregated data (validation.agg). A graphical panel showing the performance of the predictions is also generated.
%
%Inputs:
%
%X: column vector of observations.
%Y: column vector of predictions.
%
%varargin:
%'thre': theshold defining wet days (0.1 by default).
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
%% por defecto
thre=0.1;
pnanlim=75;  %porcentaje de NaNs permitidos (si se supera este porcentaje todos los scores de validacion son fijados a NaNs)
nagg=10;
aggFun='nanmean';
missing=25;
dbins=10;
dirout='';
%% varargin
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'thre', thre=varargin{i+1};
        case 'nagg', nagg=varargin{i+1};
        case 'aggFun', aggFun=varargin{i+1};
        case 'missing', missing=varargin{i+1};
        case 'dbins', dbins=varargin{i+1};
        case 'dirout', dirout=varargin{i+1};
        otherwise
            warning(sprintf('Optional argument ''%s'' ignored',varargin{i}))
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
s_acc={'r','mae','maemean','maestd','rmse','rmsemean','rmsestd'};
s_relall={'bias','biasstd','rv'};
s_relrain={'kspvalue','ks10pvalue','ks90pvalue','pdfscore'};
%% labels
l_sta={'Mean','Median','Sigma','IQR','Min','Max','P10','P90','Missing'};
l_acc={'r','MAE','nMAE','NMAE','RMSE','nRMSE','NRMSE'};
l_relall={'Bias','NBias','RV'};
l_relrain={'KS-pValue','KS10-pValue','KS90-pValue','PDF-Score'};
%% correccion posibles valores negativos
X(X<0)=0;
if ~isempty(X(X<0))
    warning('on','Negative values in osberved precipitation. Converted to 0.')
end
Y(Y<0)=0;
if ~isempty(Y(Y<0))
    warning('on','Negative values in predicted precipitation. Converted to 0.')
end
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
%% dato binario;
Xbin = NaN(size(X)); Xbin(X<thre,1) = 0; Xbin(X>=thre,1) = 1;
Ybin = NaN(size(Y)); Ybin(Y<thre,1) = 0; Ybin(Y>=thre,1) = 1;
%% validacion diaria
RRX = sum(Xbin(~isnan(Xbin)))*100/sum(~isnan(Xbin));  %Rainfall Rate, (%) (obs)
RRY = sum(Ybin(~isnan(Ybin)))*100/sum(~isnan(Ybin));  %Rainfall Rate, (%) (pred)
sX=statistics({},X,s_sta);
sY=statistics({},Y,s_sta);
if pnanX >= pnanlim || pnanY >= pnanlim
    HIR = NaN;
    FAR = NaN;
else
    aux = validationBinary(Xbin,Ybin);
    HIR = aux.HIR;   % P(p=1|o=1)
    FAR = aux.FAR;   % P(p=1|o=0)
end
clear aux
a=accuracy({},X,Y,s_acc);
%     b=binary({},Xbin,Ybin,s_bin);
Ratio = RRY/RRX;   % Ratio de frecuencias de lluvia; frec(p=1)/frec(o=1)
rall=reliability({},X,Y,s_relall);
if pnanX >= pnanlim || pnanY >= pnanlim
    rrain=reliability({},NaN,NaN,s_relrain);
else
    if sum(X >= thre)==0 || sum(X >= thre)==0
    rrain=reliability({},NaN,NaN,s_relrain);
    else
    rrain=reliability({},X(X>=thre),Y(Y>=thre),s_relrain);
    end
end
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
ragg=reliability({},Xagg,Yagg,s_relall);
ragg=reliability(ragg,Xagg,Yagg,s_relrain);  %Considero toda la serie (el dato agregado se trata como continuo!)
%% panel validacion
%if pnanX < pnanlim && pnanY < pnanlim
    figure
    %% scatter plot observacion-prediccion
    subplot(2,2,1);
    plot(X,Y,'.');
    xlabel('Observed');
    ylabel('Predicted');
    title(sprintf('HIR: %0.3f, FAR: %0.3f, r: %0.3f',HIR,FAR,a.r))
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
    title(sprintf('r: %0.3f',aagg.r))
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
validation.daily.X.scores=[RRX;validation.daily.X.scores]; validation.daily.X.labels=['RR';l_sta'];   %anadio campos especificos precip
validation.daily.Y.scores=cell2mat(struct2cell(sY));  validation.daily.Y.labels=l_sta';
validation.daily.Y.scores=[RRY;validation.daily.Y.scores]; validation.daily.Y.labels=['RR';l_sta'];  %anadio campos especificos precip
validation.daily.acc.scores=cell2mat(struct2cell(a));  validation.daily.acc.labels=l_acc';
validation.daily.acc.scores=[[HIR;FAR];validation.daily.acc.scores]; validation.daily.acc.labels=['HIR';'FAR';l_acc'];  %anadio campos especificos precip
validation.daily.rel.scores=cell2mat(struct2cell(rall));  validation.daily.rel.labels=l_relall';
validation.daily.rel.scores=[Ratio;validation.daily.rel.scores]; validation.daily.rel.labels=['Ratio';validation.daily.rel.labels];  %anadio campos especificos precip
validation.daily.rel.scores=[validation.daily.rel.scores;cell2mat(struct2cell(rrain))]; validation.daily.rel.labels=[validation.daily.rel.labels;l_relrain'];
%% dato agregado
validation.agg.X.scores=cell2mat(struct2cell(sXagg));  validation.agg.X.labels=l_sta';
validation.agg.Y.scores=cell2mat(struct2cell(sYagg));  validation.agg.Y.labels=l_sta';
validation.agg.acc.scores=cell2mat(struct2cell(aagg));  validation.agg.acc.labels=l_acc';
validation.agg.rel.scores=cell2mat(struct2cell(ragg));  validation.agg.rel.labels=[l_relall';l_relrain'];
%% salvo estructura
if ~isempty(dirout)
    eval(sprintf('save %s/validation validation',dirout));
end
end
