% Examples of statistical tests to detect 
% trends (Mann-Kendall)
% serial correlation (Wald-Wolfowitz)
% homogeneity (Alexandersson)

% Loading the data for the example (123 stations over Spain)

Net.Network={'INM'};
Net.Stations={'CompletasBuenas.stn'};
Net.Variable={'Precip0707'};
[data,Net]=loadStations(Net,'zipfile',1);

% Buscamos outliers y los eliminamos de los datos:

data=testOutlier(data,'range',3,'variable','precipitacion');

% Serial correlation test (Wald-Wolfowitz):

[pVal,corr,dataY]=testSerial(data,'period','year','missing',0.1);
figure; drawStationsValue(Net,pVal','resolution','high');
title('Wald-Wolfowitz Test for Serial Correlation')
figure; drawStationsValue(Net,corr);
i=find(pVal<0.01);Net1=Net;Net1.Info.Location=Net1.Info.Location(i,:);
figure; drawStationsValue(Net1,pVal(i)','resolution','high');

% Mann-Kendall trend test:
[pValue,trend]=testTrend(data,'test','MannKendall','period','year','missing',0.1);
title('Test de Mann-Kendall')
figure;drawStationsValue(Net,pValue,'resolution','high')
figure;drawStationsValue(Net,trend,'resolution','high')
i=find(pValue<0.01);
Net1=Net;Net1.Info.Location=Net1.Info.Location(i,:);
figure; drawStationsValue(Net1,pValue(i)','resolution','high');

% Looking for the series with lower p values

a=intersect(find(pValue<0.05),find(trend==1));
b=intersect(find(pValue<0.05),find(trend==-1));
c=intersect(find(pValue<0.05),find(trend==0));
positiva=a(find(pValue(a)==min(pValue(a))));
negativa=b(find(pValue(b)==min(pValue(b))));
if ~isempty(c)
    notend=c(find(pValue(c)==min(pValue(c))));
else
    notend=min(find(pValue==max(pValue)));
end

% Alexanderson (removing tendendcy):

notrend=zeros(size(data,2),1);
pValue2=zeros(size(data,2),1);
T=zeros(size(data,2),1);
N=zeros(size(data,2),1);
for i=1:size(data,2)
    [dataOut,dato]=detrend(data(:,i),pValue(i),'period','year','treshold',0.05,'missing',0.1);
    [pValue2(i),T(i),N(i)]=snht(dataOut,'period','day','missing',0);
    notrend(i)=testTrend(dataOut,'test','MannKendall','period','day','missing',0);
    switch(i)
        case(positiva)
             figure,plot(dato),title('tendencia positiva')
        case(negativa)
             figure,plot(dato),title('tendencia negativa')
        case(notend)
             figure,plot(dato),title('no existe tendencia')
     end
%      if i==minWW & pValue3(minWW)<0.05
%          figure,plot(dato(1:end-1),dato(2:end),'.'),title('Serie con correlacion')
%      end
%      if i==maxWW
%          figure,plot(dato(1:end-1),dato(2:end),'.'),title('Serie sin correlacion')
%      end
     i
end
figure;drawStationsValue(Net,pValue2,'resolution','high')
title('Test de Salto de Alexandersson')

% Test de Homogeneidad usando la correlacion con las vecinas:
location=Net.Info.Location;
pValue3=testHomogeneity(data,location,'period','year','missing',0);
figure;drawStationsValue(Net,pValue3,'resolution','high')
title('Test de Homogeneidad de Alexandersson')