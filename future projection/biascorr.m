function [SIMprojCTL_eQM,SIMproj45_eQM,SIMproj85_eQM]= biascorr(obs_tmean,SIMcontrol,SIMproj45,SIMproj85)
%% Loading the observations
step='M';
StartDate=obs_tmean.Time(1);
EndDate=obs_tmean.Time(end);
mm=ismember(month(obs_tmean.Time),2);
obs_tmean.Time(mm)=dateshift(obs_tmean.Time(mm),'end','day',13);
obs_tmean.Time(~mm)=dateshift(obs_tmean.Time(~mm),'end','day',14);
dailyList=datestr(obs_tmean.Time,'yyyymmdd');
StructTmean=struct('step',step,'StartDate',StartDate,'EndDate',EndDate,...
    'dailyList',dailyList);
obsDates=datenum(StructTmean.StartDate:calmonths(1):StructTmean.EndDate);
ptnTmean = [];
ptnTmean.meta = StructTmean;  
ptnTmean.data = obs_tmean.Var1; 

%% Loading the control/historical simulation:
step='M';
StartDate=SIMcontrol.Time(1);
EndDate=SIMcontrol.Time(end);
dailyList=datestr(SIMcontrol.Time,'yyyymmdd');
dmn1=struct('step',step,'StartDate',StartDate,'EndDate',EndDate,...
    'dailyList',dailyList);
predDates=datenum(dmn1.StartDate:calmonths(1):dmn1.EndDate);
ptrCTL = [];
ptrCTL.meta = dmn1;  
ptrCTL.fields = SIMcontrol.Var1; 

%% Loading the future climate: RCP85 and RCP45
step='M';
StartDate=SIMproj85.Time(1);
EndDate=SIMproj85.Time(end);
dailyList=datestr(SIMproj85.Time,'yyyymmdd');
dmn1=struct('step',step,'StartDate',StartDate,'EndDate',EndDate,...
    'dailyList',dailyList);
sim85Dates=datenum(dmn1.StartDate:calmonths(1):dmn1.EndDate);
ptrRCP85 = [];
ptrRCP85.meta = dmn1;  
ptrRCP85.fields = SIMproj85.Var1; 

step='M';
StartDate=SIMproj45.Time(1);
EndDate=SIMproj45.Time(end);
dailyList=datestr(SIMproj45.Time,'yyyymmdd');
dmn1=struct('step',step,'StartDate',StartDate,'EndDate',EndDate,...
    'dailyList',dailyList);
sim45Dates=datenum(dmn1.StartDate:calmonths(1):dmn1.EndDate);
ptrRCP45 = [];
ptrRCP45.meta = dmn1;  
ptrRCP45.fields = SIMproj45.Var1; 

%% Example for eQM
method = [];
method.type = 'EQM';
method.properties.Variable ='tas';
method.properties.extrapolation='constant';
method.properties.quantiles=1:99;
method.properties.NumberOfNearestNeighbours = 1;
% datesCTL=datenum([datetime('01-Jan-1961'):calmonths(1):datetime('31-Dec-2005')']);
datesCTL=datenum(StructTmean.StartDate:calmonths(1):StructTmean.EndDate);
[model_eQM]=downTrain(ptrCTL,ptnTmean,method,'datesTrain',datesCTL);
% Historical
[SIMprojCTL_eQM] = downSim(ptrCTL,model_eQM,'datesTest',datesCTL);
% RCPs
datesRCP=datenum([datetime('01-Jan-2006'):calmonths(1):datetime('31-Dec-2100')']);
[SIMproj45_eQM] = downSim(ptrRCP45,model_eQM,'datesTest',datesRCP);
[SIMproj85_eQM] = downSim(ptrRCP85,model_eQM,'datesTest',datesRCP);

% Example for isimp
SIMprojCTL_isimip=isimip(obs_tmean.Var1,SIMcontrol.Var1,SIMcontrol.Var1,'datesobs',obsDates','datesfor',datesCTL','variable','temperature');
SIMproj45_isimip=isimip(obs_tmean.Var1,SIMcontrol.Var1,SIMproj45.Var1,'datesobs',obsDates','datesfor',datesRCP','variable','temperature');
SIMproj85_isimip=isimip(obs_tmean.Var1,SIMcontrol.Var1,SIMproj85.Var1,'datesobs',obsDates','datesfor',datesRCP','variable','temperature');
%% delta
method = [];
method.type = 'DELTA';
method.properties.Variable = 'tas';
method.properties.extrapolation='constant';
method.properties.CorrectionFunction = 'additive';
method.properties.quantiles=1:99;
method.properties.NumberOfNearestNeighbours = 1;
[model_delta]=downTrain(ptrCTL,ptnTmean,method,'datesTrain',datesCTL);
% Historical
[SIMprojCTL_delta] = downSim(ptrCTL,model_delta,'datesTest',datesCTL);
% RCPs
[SIMproj45_delta] = downSim(ptrRCP45,model_delta,'datesTest',datesRCP);
[SIMproj85_delta] = downSim(ptrRCP85,model_delta,'datesTest',datesRCP);

%% scaling
method = [];
method.type = 'SCALING';
method.properties.Variable = 'tas';
method.properties.CorrectionFunction = 'additive';
method.properties.extrapolation='constant';
method.properties.quantiles=1:99;
method.properties.NumberOfNearestNeighbours = 1;
[model_scaling]=downTrain(ptrCTL,ptnTmean,method,'datesTrain',datesCTL);
% Historical
[SIMprojCTL_scaling] = downSim(ptrCTL,model_scaling,'datesTest',datesCTL);
% RCPs
[SIMproj45_scaling] = downSim(ptrRCP45,model_scaling,'datesTest',datesRCP);
[SIMproj85_scaling] = downSim(ptrRCP85,model_scaling,'datesTest',datesRCP);

%% aQM
method = [];
method.type = 'AQM';
method.properties.Variable = 'tas';
method.properties.extrapolation='constant';
method.properties.quantiles=1:99;
method.properties.NumberOfNearestNeighbours = 1;
[model_aQM]=downTrain(ptrCTL,ptnTmean,method,'datesTrain',datesCTL);
% Historical
[SIMprojCTL_aQM] = downSim(ptrCTL,model_aQM,'datesTest',datesCTL);
% RCPs
[SIMproj45_aQM] = downSim(ptrRCP45,model_aQM,'datesTest',datesRCP);
[SIMproj85_aQM] = downSim(ptrRCP85,model_aQM,'datesTest',datesRCP);

% %% gpQM
% method = [];
% method.type = 'GPQM';
% method.properties.Variable = 'tas';
% method.properties.extrapolation='constant';
% method.properties.quantiles=1:99;
% method.properties.NumberOfNearestNeighbours = 1;
% [model_gpQM]=downTrain(ptrCTL,ptnTmean,method,'datesTrain',datesCTL);
% % Historical
% [SIMprojCTL_gpQM] = downSim(ptrCTL,model_gpQM,'datesTest',datesCTL);
% % RCPs
% [SIMproj45_gpQM] = downSim(ptrRCP45,model_gpQM,'datesTest',datesRCP);
% [SIMproj85_gpQM] = downSim(ptrRCP85,model_gpQM,'datesTest',datesRCP);

%% plot
% We build the annual series with the function aggregateData:
dates=datenum([datetime('01-Jan-1979'):calmonths(1):datetime('31-Dec-2100')]');
dailyMatrix=repmat(NaN,length(dates),10);
[aux,I1,I2]=intersect(dates,datesCTL);
dailyMatrix(I1,:)=repmat([SIMprojCTL_delta(I2,1) SIMprojCTL_scaling(I2,1) SIMprojCTL_eQM(I2,1) SIMprojCTL_aQM(I2,1) SIMprojCTL_isimip(I2,1)],1,2);
[aux,J1,J2]=intersect(dates,datesRCP);
dailyMatrix(J1,1:5)=[SIMproj85_delta(J2,1) SIMproj85_scaling(J2,1) SIMproj85_eQM(J2,1) SIMproj85_aQM(J2,1) SIMproj85_isimip(J2,1)];
dailyMatrix(J1,6:10)=[SIMproj45_delta(J2,1) SIMproj45_scaling(J2,1) SIMproj45_eQM(J2,1) SIMproj45_aQM(J2,1) SIMproj45_isimip(J2,1)];
[annualObs,annualDates]=aggregateData(obs_tmean.Var1,obsDates,'Y','aggFun','nanmean','missing',1);
[annualPrd,annualDates]=aggregateData(SIMcontrol.Var1,predDates,'Y','aggFun','nanmean','missing',1);
[annualSim85,annualDates]=aggregateData(SIMproj85.Var1,sim85Dates,'Y','aggFun','nanmean','missing',1);
[annualSim45,annualDates]=aggregateData(SIMproj45.Var1,sim45Dates,'Y','aggFun','nanmean','missing',1);
[annualMatrix,annualDates]=aggregateData(dailyMatrix,dates,'Y','aggFun','nanmean','missing',1);
% We make a first/basic plot of the projections
ydates=unique(year(dates));yctl=unique(year(datesCTL));yrcp=unique(year(datesRCP));
[aux,I1,I2]=intersect(ydates,yctl);[aux,J1,J2]=intersect(ydates,yrcp);
indices{1}=[1:5];indices{2}=[6:10];
boundary{1,1}={'min','max'};boundary{2,1}={'min','max'};
colorSG=[0 63 209;254 53 43]/255;
h=figure;drawSpread(annualMatrix,'xvalues',[1979:2100]','indexesg',indices,'colorsg',colorSG,'lines','no','boundary',boundary);
hold on,plot([1979:2004],annualObs(:,1),':k','linewidth',2),plot(1979:2004,annualPrd(:,1),'--k','linewidth',2),
plot(2006:2100,annualSim85(:,1),'--b','linewidth',2),plot(2006:2100,annualSim45(:,1),'--r','linewidth',2),
plot(2006:2100,nanmean(annualMatrix(J1,1:5),2),'-b','linewidth',2),plot(2006:2100,nanmean(annualMatrix(J1,6:10),2),'-r','linewidth',2),
title('Mean Daily Temperature (ºC)');legend('RCP85','RCP45','Observations','historical','RCP85','RCP45','RCP85-BC','RCP45-BC','location','northwest');axesPosition=get(gca,'Position');