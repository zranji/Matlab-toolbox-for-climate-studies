init;

% EJEMPLOS PERFECTO PROG
obsMeta = {};
obsMeta.Network = {'GSN_demo'};
obsMeta.Variable = {'Tmax'};
[obsData,obsMeta] = loadObservations(obsMeta,'ID',{'8181'});  %Barcelona

dmn = readDomain('../ModelData/NCEP/Iberia_NCEP');
gcmCam = ['./../ModelData/NCEP/Iberia_NCEP/url.txt'];
gcmDates = datevec(datenum('01-Jan-1961'):datenum('31-Dec-2000'));
%gcmCam = [dmn.src 'url.txt'];
%gcmDates = datessea;
[gcmData,dmn,gcmDates] = loadGCM(dmn,gcmCam,'dates',gcmDates,'anHour','Analysis','ds',0);
gcmData = rand(length(gcmDates),length(dmn.nod)*length(dmn.par));

% construir predictando
   ptn = [];
   ptn.meta = obsMeta;
   ptn.data = obsData;

% construir predictor
   ptr = [];
   ptr.meta = dmn;
   % es necesario hacer las transformaciones de datos en el predictor
   [gcmData,gcmDataMn,gcmDataDv] = pstd(gcmData);
   ptr.fields = gcmData;
   % algunos metodos necesitan las PCs. En este caso las invento. Importante: mismo tamaño que fields
   ptr.pc = rand(size(gcmData,1),50);
   ptr.clusteringData = ptr.pc; % opcional, se usa para los metodos con clustering

myCluster = makeClustering(ptr.pc,'kmeans',10,'Norm-2');

% Ejemplo 1: defino un metodo de analogos
   method = [];
   method.type = 'ANALOGES';
   method.properties.InferenceMethod = 'mean';
   method.properties.AnalogueNumber = 1;
   [model,Ytrain] = downTrain(ptr,ptn,method,'datesTrain',datenum('01-Jan-1961'):datenum('31-Dec-1970'),'datesTest',datenum('01-Jan-1980'):datenum('31-Jan-1980'));
   [Ypred] = downSim(ptr,model,'datesTest',datenum('01-Jan-1980'):datenum('31-Jan-1980'));

   datesTest = datenum('01-Jan-1971'):datenum('31-Jan-1971');
   [model,Ytrain] = downTrain(ptr,ptn,method,'datesTrain',datesTest,'datesTest',datesTest);
   fechas = datenum(ptn.meta.StartDate):datenum(ptn.meta.EndDate);
   [ix,a,b] = intersect(datesTest,fechas);
   [Ypred] = downSim(ptr,model,'datesTest',datesTest);
   [Ytrain ptn.data(b,:) Ypred]

   datesTest = datenum('01-Jan-1971'):datenum('31-Jan-1971');
   [model,Ytrain] = downTrain(ptr,ptn,method,'datesTrain',datenum('01-Jan-1971'):datenum('31-Dec-1971'),'datesTest',datesTest);
   fechas = datenum(ptn.meta.StartDate):datenum(ptn.meta.EndDate);
   [ix,a,b] = intersect(datesTest,fechas);
   [Ypred] = downSim(ptr,model,'datesTest',datesTest);
   [Ytrain ptn.data(b,:) Ypred]

% Ejemplo 2: defino un metodo de regresion lineal
   method = [];
   method.type = 'LINEAR_REGRESSION';
   method.properties.NumberOfNearestNeighbours = 5;
   method.properties.NumberOfPCs = 10;
   [model,Ytrain] = downTrain(ptr,ptn,method,'datesTest',datenum('01-Jan-1980'):datenum('31-Dec-1980'));
   [Ypred] = downSim(ptr,model,'datesTest',datenum('01-Jan-1980'):datenum('31-Dec-1980'));
   
% Ejemplo 3: defino un metodo de regresion lineal
   method = [];
   method.type = 'LINEAR_REGRESSION';
   method.properties.NumberOfNearestNeighbours = 5;
   method.properties.NumberOfPCs = 10;
   [model,Ypred] = downTrain(ptr,ptn,method,'datesTrain',datenum('01-Jan-1961'):datenum('31-Dec-1970'));
   
% Ejemplo 4: defino un metodo de regresion lineal con clustering
   method = [];
   method.type = 'LINEAR_REGRESSION';
   clustering = myCluster;
   method.properties.ClusteringMethod = clustering;
   method.properties.NumberOfPCs = 50;
   [model,Ypred] = downTrain(ptr,ptn,method);

% Ejemplo 5: defino un metodo GLMs
   method = [];
   method.type = 'GLM';
   method.properties.ThresholdPrecip = 1;  % en las mismas unidades en las que estan las observaciones
   method.properties.SimOccurrence = 'true';   %'true', 'falsecal', 'falsenocal' (by default 'falsecal')
   method.properties.SimGLM = 'true';   %'true', 'false' (by default 'true')
   method.properties.minrainydays = 5;   %minimum number of rainy days required to adjust the GLM (by default 10)
   [model,Ypred] = downTrain(ptr,ptn,method);

% Ejemplo 6: defino un metodo ELMs
   method = [];
   method.type = 'ELM';
   method.properties.NumberOfNearestNeighbours = 5;
   method.properties.ActivationFunction='sig';
   method.properties.NumberofHiddenNeurons=500;
   [model,Ypred] = downTrain(ptr,ptn,method);

% Ejemplo 7: defino un metodo WTs
   method = [];
   method.type = 'WT';
   clustering = myCluster;
   method.properties.ClusteringMethod = clustering;
   method.properties.InferenceMethod = 'mean';  %'rnd', 'wmean', 'prcXX', 'sim_normal', 'sim_unigam'
   method.properties.ThresholdPrecip = 1; %this property can be specified in case 'InferenceMethod = 'sim_unigam' is used ('thre' = 0.1 by default)
   method.properties.minrainydays = 5; %this property can be specified in case 'InferenceMethod = 'sim_unigam' is used ('minrainydays' = 10 by default)
   [model,Ypred] = downTrain(ptr,ptn,method);

% Ejemplo 8: defino un metodo GLMs condicionado a WT
   method = [];
   method.type = 'GLM';
   method.properties.ThresholdPrecip = 1;  % en las mismas unidades en las que estan las observaciones
   method.properties.SimOccurrence = 'true';   %'true', 'falsecal', 'falsenocal' (by default 'falsecal')
   method.properties.SimGLM = 'true';   %'true', 'false' (by default 'true')
   method.properties.ClusteringMethod = clustering;
   [model,Ypred] = downTrain(ptr,ptn,method);

% Ejemplo 9: defino un metodo ELMs con un clustering y lars 4
   method = [];
   method.type = 'ELM';
   method.properties.NumberOfNearestNeighbours = 5;
   method.properties.ActivationFunction='sig';
   method.properties.NumberofHiddenNeurons=500;
   method.properties.FeatureSelection='lars';
   method.properties.Features=4;
   clustering = myCluster;
   method.properties.ClusteringMethod = clustering;
   [model,YpredTrain] = downTrain(ptr,ptn,method);
   [YpredTest] = downSim(ptr,model);

% Ejemplo 10: defino un metodo de regresion lineal y lars 4
   method = [];
   method.type = 'LINEAR_REGRESSION';
   method.properties.NumberOfNearestNeighbours = 5;
   method.properties.NumberOfPCs = 10;
   method.properties.FeatureSelection='lars';
   method.properties.Features=4;
   [model,Ypred] = downTrain(ptr,ptn,method,'datesTrain',datenum('01-Jan-1961'):datenum('31-Dec-1970'));
   [YpredTest] = downSim(ptr,model);

% Ejemplo 11: defino un metodo de regresion lineal y lars 4 con feature incremental
   method = [];
   method.type = 'LINEAR_REGRESSION';
   method.properties.NumberOfNearestNeighbours = 5;
   method.properties.NumberOfPCs = 10;
   method.properties.FeatureSelection='lars';
   method.properties.Features=4;
   method.properties.FeatureIncremental='true';
   [model,Ypred] = downTrain(ptr,ptn,method,'datesTrain',datenum('01-Jan-1961'):datenum('31-Dec-1970'));
   [YpredTest] = downSim(ptr,model);

% Ejemplo 12: defino un metodo GLMs y lars 1
   method = [];
   method.type = 'GLM';
   method.properties.ThresholdPrecip = 1;  % en las mismas unidades en las que estan las observaciones
   method.properties.SimOccurrence = 'true';   %'true', 'falsecal', 'falsenocal' (by default 'falsecal')
   method.properties.SimGLM = 'true';   %'true', 'false' (by default 'true')
   method.properties.FeatureSelection='lars';
   method.properties.Features=1;
   method.properties.NumberOfNearestNeighbours = 10;
   [model,Ypred] = downTrain(ptr,ptn,method);

% Ejemplo 13: defino un metodo GLMs y lars 1 con feature incremental
   method = [];
   method.type = 'GLM';
   method.properties.ThresholdPrecip = 1;  % en las mismas unidades en las que estan las observaciones
   method.properties.SimOccurrence = 'true';   %'true', 'falsecal', 'falsenocal' (by default 'falsecal')
   method.properties.SimGLM = 'true';   %'true', 'false' (by default 'true')
   method.properties.FeatureSelection='lars';
   method.properties.Features=1;
   method.properties.NumberOfPCs = 2;
   method.properties.NumberOfNearestNeighbours = 10;
   method.properties.FeatureIncremental='true';
   [model,Ypred] = downTrain(ptr,ptn,method);

% Ejemplo 14: defino un metodo ELMs con un clustering y lars 4
   method = [];
   method.type = 'ELM';
   method.properties.NumberOfNearestNeighbours = 5;
   method.properties.ActivationFunction='sig';
   method.properties.NumberofHiddenNeurons=500;
   method.properties.FeatureSelection='lars';
   method.properties.Features=4;
   clustering = myCluster;
   method.properties.ClusteringMethod = clustering;
   [model,YpredTrain] = downTrain(ptr,ptn,method);
   [YpredTest] = downSim(ptr,model);

% Ejemplo 15: defino un metodo NN simple
   method = [];
   method.type = 'NN';
   method.properties.NumberOfNearestNeighbours = 5;
   [model,YpredTrain] = downTrain(ptr,ptn,method);
   [YpredTest] = downSim(ptr,model);
   
% Ejemplo 16: defino un metodo NN con un clustering y lars 4
   method = [];
   method.type = 'NN';
   method.properties.NumberOfNearestNeighbours = 12;
   method.properties.NumberOfPCs = 2;
   method.properties.NumberOfHiddenLayers = 2;
   method.properties.TypeOfHiddenLayers='tansig';
   method.properties.FeatureSelection='lars';
   method.properties.Features=8;
   clustering = myCluster;
   method.properties.ClusteringMethod = clustering;
   [model,YpredTrain] = downTrain(ptr,ptn,method);
   [YpredTest] = downSim(ptr,model);

% Ejemplo 17: defino un metodo de quantile regression para precipitación
	method = [];
	method.type = 'QUANTILE_REGRESSION';
	method.properties.Quantile = 95;
	method.properties.NumberOfNearestNeighbours = 4;
	method.properties.NumberOfPCs = 15;
	method.properties.nnAverage = 'true';
	method.properties.Variable = 'pr';
	method.properties.ThresholdPrecip = 0.1;   
   [model,YpredTrain] = downTrain(ptr,ptn,method);
   [YpredTest] = downSim(ptr,model);

% Ejemplo 18: defino un metodo de quantile regression para temperatura (default)
	method = [];
	method.type = 'QUANTILE_REGRESSION';
	method.properties.Quantile = 95;
	method.properties.NumberOfNearestNeighbours = 4;
	method.properties.NumberOfPCs = 15;
	method.properties.nnAverage= 'true';
   [model,YpredTrain] = downTrain(ptr,ptn,method);
   [YpredTest] = downSim(ptr,model);

str = describeFeatureSelector(model)

%method = readXMLDownscalingMethod('downscaling-method.xml');

% EJEMPLOS BIAS CORRECTION
obsMeta = {};
obsMeta.Network = {'GSN_demo'};
obsMeta.Variable = {'Precip'};
period={'01-Jan-1961','31-Dec-2000'};
[obsData,obsMeta] = loadObservations(obsMeta,'ID',{'8181'},'dates',period);  %Barcelona

%dmn = readDomain('./../ModelData/NCEP/Iberia_NCEP');
gcmCam = ['./../ModelData/NCEP/Iberia_NCEP/url.txt'];
dmn.nod=obsMeta.Info.Location';
dmn.par(1,:)={'TP',0,0};
dmn.startDate='01-Jan-1961';
dmn.endDate='31-Dec-2000';
dmn.step='24:00'; 
gcmDates = datevec(datenum('01-Jan-1961'):datenum('31-Dec-2000'));
[gcmData,dmn,gcmDates] = loadGCM(dmn,gcmCam,'dates',gcmDates,'anHour','Analysis','ds',0);
% leo también SLP para el cluster
dmn1.nod=[-10 50;0 50;-20 45;-10 45;0 45;10 45;-20 40;-10 40;0 40;10 40;-20 35;-10 35;0 35;10 35;-10 30;0 30]';
dmn1.par(1,:)={'SLPd',0,0};
dmn1.startDate='01-Jan-1961';
dmn1.endDate='31-Dec-2000';
dmn1.step='24:00'; 
gcmDates = datevec(datenum('01-Jan-1961'):datenum('31-Dec-2000'));
%gcmDates = datessea;
[slpData,dmn1,slpDates] = loadGCM(dmn1,gcmCam,'dates',gcmDates,'anHour','Analysis','ds',0);

% construir predictando
   ptn = [];
   ptn.meta = obsMeta;
   ptn.data = obsData;

% construir predictor
   ptr = [];
   ptr.meta = dmn;
   ptr.fields = gcmData;
   ptr.clusteringData = slpData; % opcional, se usa para los metodos con clustering

myCluster = makeClustering(slpData,'lamb',27,'location',dmn.nod','center',[-5 40]);


% Ejemplo 1: defino un metodo DELTA
	method = [];
	method.type = 'DELTA';
	method.properties.CorrectionFunction = 'multiplicative'; % 'additive' or 'multiplicative'
	method.properties.NumberOfNearestNeighbours = 1; % number of model nearest grid boxes to correct
	[model,Ytrain] = downTrain(ptr,ptn,method,'datesTrain',datenum('01-Jan-1961'):datenum('31-Dec-1970'),'datesTest',datenum('01-Jan-1980'):datenum('31-Jan-1980'));
	[Ypred] = downSim(ptr,model,'datesTest',datenum('01-Jan-1980'):datenum('31-Jan-1980'));
	
% Ejemplo 2: defino un metodo de SCALING
	method = [];
	method.type = 'SCALING';
	method.properties.CorrectionFunction = 'multiplicative'; % 'additive', 'multiplicative' or 'logarithmic'
	method.properties.NumberOfNearestNeighbours = 1;
	[model,Ytrain] = downTrain(ptr,ptn,method,'datesTrain',datenum('01-Jan-1961'):datenum('31-Dec-1970'),'datesTest',datenum('01-Jan-1980'):datenum('31-Jan-1980'));
	[Ypred] = downSim(ptr,model,'datesTest',datenum('01-Jan-1980'):datenum('31-Jan-1980'));

% Ejemplo 3: defino un metodo de empirical quantile mapping (EQM)
	method = [];
	method.type = 'EQM';
	method.properties.Variable = 'pr'; % 'tas', 'pr'
	method.properties.extrapolation='constant'; % 'constant', 'linear', 'no'
	method.properties.quantiles=1:99;
	method.properties.FreqCorrection = 'true'; % if 'true' performs frequency adjustment (Wilcke et al. 2013)
	method.properties.threshold=0.1; % wet-day precipitation threshold
	method.properties.NumberOfNearestNeighbours = 1;
	[model,Ytrain] = downTrain(ptr,ptn,method,'datesTrain',datenum('01-Jan-1961'):datenum('31-Dec-1970'),'datesTest',datenum('01-Jan-1980'):datenum('31-Jan-1980'));
	[Ypred] = downSim(ptr,model,'datesTest',datenum('01-Jan-1980'):datenum('31-Jan-1980'));

% Ejemplo 4: defino un metodo de adjusted quantile mapping (AQM)
	method = [];
	method.type = 'AQM';
	method.properties.Variable = 'pr'; % 'tas', 'pr'
	method.properties.FreqCorrection = 'true'; % if 'true' performs frequency adjustment (Wilcke et al. 2013)
	method.properties.normFun='prctile'; % normalization function of 'f' parameter. 'prctile' is the quotient of IQR, whereas the quotient of observed and simulated std is used by default
	method.properties.threshold=0.1; % wet-day precipitation threshold
	method.properties.NumberOfNearestNeighbours = 1;
	[model,Ytrain] = downTrain(ptr,ptn,method,'datesTrain',datenum('01-Jan-1961'):datenum('31-Dec-1970'),'datesTest',datenum('01-Jan-1980'):datenum('31-Jan-1980'));
	[Ypred] = downSim(ptr,model,'datesTest',datenum('01-Jan-1980'):datenum('31-Jan-1980'));

% Ejemplo 5: defino un método de quantile mapping paramétrico (gamma) GQM
	method = [];
	method.type = 'GQM';
	method.properties.Variable = 'pr'; % only valid for precipitation
	method.properties.FreqCorrection = 'true'; % if 'true' performs frequency adjustment (Wilcke et al. 2013)
	method.properties.threshold=0.1; % wet-day precipitation threshold
	method.properties.NumberOfNearestNeighbours = 1;
	[model,Ytrain] = downTrain(ptr,ptn,method,'datesTrain',datenum('01-Jan-1961'):datenum('31-Dec-1970'),'datesTest',datenum('01-Jan-1980'):datenum('31-Jan-1980'));
	[Ypred] = downSim(ptr,model,'datesTest',datenum('01-Jan-1980'):datenum('31-Jan-1980'));

% Ejemplo 6: defino un método de quantile mapping paramétrico (gamma+GPD) GPQM
	method = [];
	method.type = 'GPQM';
	method.properties.Variable = 'pr'; % 'tas', 'pr'. For pr (tas) it fits a gamma (normal) for the central distribution and GPD for the values above the 95th percentile (and below the 5th percentile for the lower tail). 5th and 95th percentiles are default values, they can be changed using the property theta.
	method.properties.FreqCorrection = 'true'; % if 'true' performs frequency adjustment (Wilcke et al. 2013)
	method.properties.threshold=0.1; % wet-day precipitation threshold
	method.properties.NumberOfNearestNeighbours = 1;
	[model,Ytrain] = downTrain(ptr,ptn,method,'datesTrain',datenum('01-Jan-1961'):datenum('31-Dec-1970'),'datesTest',datenum('01-Jan-1980'):datenum('31-Jan-1980'));
	[Ypred] = downSim(ptr,model,'datesTest',datenum('01-Jan-1980'):datenum('31-Jan-1980'));

% Ejemplo 7: defino un método de empirical quantile mapping EQM con ventana móvil
	method = [];
	method.type = 'EQM';
	method.properties.Variable = 'pr'; % 'tas', 'pr'
	method.properties.extrapolation='constant'; % 'constant', 'linear', 'no'
	method.properties.quantiles=1:99;
	method.properties.FreqCorrection = 'true'; % if 'true' performs frequency adjustment (Wilcke et al. 2013)
	method.properties.threshold=0.1; % wet-day precipitation threshold
	method.properties.NumberOfNearestNeighbours = 1;
	method.properties.CorrectionWindow = 11; % length (in days) of the moving window
	[model,Ytrain] = downTrain(ptr,ptn,method,'datesTrain',datenum('01-Jan-1961'):datenum('31-Dec-1970'),'datesTest',datenum('01-Jan-1980'):datenum('31-Jan-1980'));
	[Ypred] = downSim(ptr,model,'datesTest',datenum('01-Jan-1980'):datenum('31-Jan-1980'));

% Ejemplo 8: defino un método condicionado a tipos de tiempo (WTs)
	method = [];
	method.type = 'GQM';
	method.properties.Variable = 'pr';
	method.properties.FreqCorrection = 'true'; % if 'true' performs frequency adjustment (Wilcke et al. 2013)
	method.properties.threshold=0.1; % wet-day precipitation threshold
	method.properties.NumberOfNearestNeighbours = 1;
	method.properties.ClusteringMethod = myCluster; % Lamb weather types performed above
	[model,Ytrain] = downTrain(ptr,ptn,method,'datesTrain',datenum('01-Jan-1961'):datenum('31-Dec-1970'),'datesTest',datenum('01-Jan-1980'):datenum('31-Jan-1980'));
	[Ypred] = downSim(ptr,model,'datesTest',datenum('01-Jan-1980'):datenum('31-Jan-1980'));

% Ejemplo 9: ISI-MIP (Hempel et al. 2013)
	dates=datenum('01-Jan-1961'):datenum('31-Dec-2000');
	datesTest=datenum('01-Jan-1980'):datenum('31-Jan-1980');
	datesTrain=datenum('01-Jan-1961'):datenum('31-Dec-1970');
	[common,indTest,aux] = intersect(dates,datesTest);      
	[common2,indTrain,aux2] = intersect(dates,datesTrain);  
	Ypred = isimip(obsData(indTrain,:),gcmData(indTrain,:),gcmData(indTest,:),'datesobs',datenum('01-Jan-1961'):datenum('31-Dec-1970'),'datesfor',datenum('01-Jan-1980'):datenum('31-Jan-1980'),'variable','temperature');
