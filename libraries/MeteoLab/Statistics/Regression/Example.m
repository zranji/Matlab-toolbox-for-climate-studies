% Reading CPs from NAO domain
%dmn=readDomain('Nao');
dmn=readDomain('Iberia');

[EOF,CP]=getEOF(dmn,'ncp',10);

% Reading temperature from Spanish GSN stations
Example.Network={'GSN'};
Example.Stations={'Spain.stn'};
%Example.Variable={'Temp'};
Example.Variable={'Press'};
[data,Example]=loadStations(Example,'dates',{dmn.startDate,dmn.endDate},'ascfile',1);
Example.Info.Name(4,:)
data=data(:,4); % Taking data for Navacerrada station

j=find(isnan(data)==0); % Selecting days with no missing data
X=[ones(size(j),1), CP(j,:)];
y=data(j,:);

c=regression(y,X);

%Forecasting using the regression
yhat=X*c;
figure
plot([y,yhat])
figure; 
plot(y,yhat,'.k')