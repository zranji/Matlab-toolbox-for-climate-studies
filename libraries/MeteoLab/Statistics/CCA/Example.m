%loading EOFs and Observations
dates={'1-Jan-1960','31-Dec-1999'};
dmn=readDomain('Nao');
%dmn=readDomain('Iberia');
[EOF,CP,MN,DV]=getEOF(dmn,'dates',dates);
X=CP';

Observation.Network={'INM'};
Observation.Stations={'completas.stn'};
Observation.Variable={'Rellenos/Vx'};
[data,Observation]=loadStations(Observation,'dates',dates,'zipfile',1);
Y=data(:,1:3:end-20)';

period=30;
%NCP=200;

%calculating moving averages with the specified period
XX=[];YY=[];
for i=1:size(X,1)
   XX(i,:)=movingAverage(X(i,:),period); 
end
for i=1:size(Y,1)
   YY(i,:)=movingAverage(Y(i,:),period);
end
XX=XX(:,1:period:end);
YY=YY(:,1:period:end);

%testing with the last year
ntest=fix(365/period);
train=[1:size(XX,2)-ntest];
test=[size(XX,2)-ntest+1:size(XX,2)];

[F, G, r] = computeCCA(XX(:,train),YY(:,train));

%data projected on new space
Xp=F'*XX;
Yp=G'*YY;

Ype=[];
for j=1:min(size(YY,1),size(XX,1))
   b=regression(Yp(j,train)',[ones(length(train),1) Xp(j,train)']); 
   Ype=[Ype; ([ones(length(test),1) Xp(j,test)']*b)'];
end
Ye=inv(G(:,1:size(G,1))')*Ype;

%Drawing the predicted and observed fields.
show=1;
drawIrregularGrid([Ye(:,show)'; YY(:,test(show))'],Observation.Info.Location(1:3:end-20,:))

%Correlation coefficients between real and predicted spatial patterns
cor=[];
for i=1:size(Ye,2), 
   a=corrcoef(Ye(:,i),YY(:,test(i)));
   cor(i)=a(2,1); 
end
figure; plot(cor)

