% Loading hourly data from MyStations (available in the CD)
% Temperature in Oviedo (Spain)
Example.Network={'MyStations'};
Example.Stations={'hourlyData.stn'}; 
Example.Variable={'Common'};
[data,Example]=loadStations(Example,'ascfile',1);
drawObservations(data,Example.Info.Location,Example.Info.Name);

% Fitting the autoregressive model using ARfit package from:
% http://www.gps.caltech.edu/~tapio/arfit/
[w, A]=arfit(data,2,7); 
% The order is automatically selected from 2 to 7.
lt=1; dat=data(1:lt:end,1); %Resampling to foreact at lead time 'lt' 
k=size(A,2);  % Order of the model
lag=[];
for i=1:k+1
   lag=[lag; dat(i:end-(k+1)+i,1)'];
end

X=lag(1:k,:)'; % Lagged input variables
Y=lag(k+1,:)'; % Predicted values

pred=w+X*flipud(A');
figure;
plot(pred,Y,'.k')
figure
plot([pred Y])
error=mean(abs(Y-pred))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The error as a function of sample time (from hour to day)

maxlt=24;  %Maximum lead time time 20 hours

error=[];
for lt=1:maxlt
   dat=data(1:lt:end,1); 
   [w, A]=arfit(dat,2,7); 
   k=size(A,2);
   lag=[];
   for i=1:k+1
      lag=[lag; dat(i:end-(k+1)+i,1)'];
   end
   
   X=lag(1:k,:)';    
   Y=lag(k+1,:)';    
   pred=w+X*flipud(A');
   error=[error; mean(abs(Y-pred))]; 
end
figure
plot([1:maxlt],error,'r')