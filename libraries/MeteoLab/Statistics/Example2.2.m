% Loading precipitation data for Spanish stations
Example1.Network={'GSN'};
Example1.Stations={'Spain.stn'};
Example1.Variable={'Precip'};
date={'1-Jan-1998','31-Dec-1998'};
[precip,Example1]=loadStations(Example1,'dates',date,'ascfile',1);
Example1.Info.Name
station=3;   %Choosing the station to perform the study

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DISCRETE DISTRIBUTIONS

% Precipitation as a binary variable
binaryPrecip=ones(size(precip,1),1);
binaryPrecip(find(precip(:,station)>0),1)=2;

% Precipitation with 5 states
treshold=[-inf 0 2 10 20];
for i=1:size(precip,1)
   discretePrecip(i,1)=max(find(precip(i,station)>treshold));
   % Comparing with Navacerrada precipitation
   discretePrecip2(i,1)=max(find(precip(i,4)>treshold));
end

% Histograms
h1=hist(binaryPrecip,2);
h2=hist(discretePrecip,length(treshold));

figure;
subplot(2,1,1); bar(h1,'hist');
subplot(2,1,2); bar(h2,'hist');

% Histogram of a 2D variable
histo=[];
for i=1:length(treshold),
  h=[];
  ind1=find(discretePrecip==i);
  for j=1:length(treshold),
     ind2=find(discretePrecip2==j);
     c=[];
     for k=1:size(ind2,1),
        c=[c;find(ind1==ind2(k))];
     end
     h=[h;length(c)];
  end
  histo=[histo h];
end
figure
bar3(histo)
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTINUOUS DISTRIBUTIONS

% Exponential density function fitted to data
ind=find(precip(:,station)>0);
x=linspace(min(precip(:,station)),max(precip(:,station)));

mu=mean(precip(ind,station));
fExp=(1/mu)*exp(-x/mu);

% Gamma density function fitted to data
mu=mean(precip(ind,station));
sig2=var(precip(ind,station));
a=mu^2/sig2;
b=sig2/mu;
fGam=(x.^(a-1).*exp(-x/b))/((b^a)*gamma(a));

% Using statistics Toolbox functions
% more efficient parameter's estimation
par=gamfit(precip(ind,station));
fGam2=gampdf(x,par(1,1),par(1,2));

figure; hold on
plot(x,fExp,'k');
plot(x,fGam,'b');
plot(x,fGam2,'r');