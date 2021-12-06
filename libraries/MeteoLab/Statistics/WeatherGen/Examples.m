Example1.Network={'GSN'};
Example1.Stations={'Spain.stn'};
Example1.Variable={'Precip'};
date={'1-Jan-1998','31-Dec-1998'};
[data,Example1]=loadStations(Example1,'dates',date,'ascfile',1);
data=data(:,1);   % Selecting the first stataion: San Sebastian.

%umbral=[0,0.5,10,20,inf];
umbral=[0,0.5,inf];

% Ocurrence of precipitation (discrete variable) Markov process.
disc=weatherGen(data,umbral,0,10*size(data,1),'markov');
figure;
plot(disc(1:365,1))

% Precipitation amount (continuous variable)
[disc,cont]=weatherGen(data,umbral,1,10*size(data,1),'wg');
plot(disc(1:365,1))   % Symbolic (discrete)
figure
subplot(2,1,1);
plot(data(1:end,1)) % Original
subplot(2,1,2)
plot(cont(1:size(data,1),1))   % Simulated
