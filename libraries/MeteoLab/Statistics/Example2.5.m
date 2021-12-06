Santander= [0 0 1 1 1 1 1 0 1 1 1,...
   1 1 1 0 0 1 0 1 1 1 1 1 0 0,...
   0 1 1 1 0 0 0 0 0 0 0 0 0 0,...
   0 0 0 0 0 1 0 0 1 1 0 1 1 0,...
   0 0 1 1 1 1 1 1 1 0 0 0 1 1,...
   1 1 1 0 1 1 1 1 1 1 1 1 1 1,... 
   1 1 1 1 0 1 1 1 1 0 1 0 1 1,...
   0 1 1 1 1];

Pre(find(Santander==0),1)=0;
Pre(find(Santander>0),1)=1;

c=zeros(2,2);
for k=2:size(Pre,1)
   i=Pre(k-1)+1;
   j=Pre(k)+1;
   c(i,j)=c(i,j)+1;
end

p10=c(1,2)/(c(1,1)+c(1,2)); %P(1|0)=P(1,0)/P(0); 
p11=c(2,2)/(c(2,1)+c(2,2)); %P(1|1)=P(1,1)/P(1); 
p0=sum(Pre(:,1)==0)/size(Pre,1);

N=size(Pre,1); %Length of the simulated series
x=zeros(N,1);
u=rand;
%Simulating the first day
if u<=p0, x(1,1)=1;
else x(1,1)=0;
end
%Simulating the rest of the serie
for i=2:N,
   u=rand;
   if (x(i-1)==0) & (u<=p10)
      x(i,1)=1;
   end
   if (x(i-1)==1) & (u<=p11)
      x(i,1)=1;
   end
end

%Writing the simulated series
x





%%%%%%%% Weather Generators for wind data%%%%%%%%%%%%%%%%%%%%
Example1.Network={'INM'};
%Example1.Stations={'ExampleVx.stn'};
Example1.Stations={'completas.stn'};
Example1.Variable={'Rellenos/Vx'};
date={'1-Jan-1988','31-Dec-1998'};
[data,Example1]=loadStations(Example1,'dates',date,'zipfile',1);
%[data,Example1]=loadStations(Example1,'zipfile',1);



for est=[1 12]%:size(data,2),   % Selecting station: San Sebastian.
   
   par=weibfit(data(:,est)); %ajuste de los parametros con una distribucion weibull
   
   x=linspace(min(data(:,est)),max(data(:,est)));
   
   fweib=weibpdf(x,par(1),par(2)); %calulo la pdf, según los parámetros calculados 
   
   figure; 
   [n]=hist(data(:,est),160); %pdf empírica
   bar(n/sum(n))
   hold on
   plot(x,fweib,'r');    %pdf teórica
 
   r=weibrnd(par(1),par(2),10*length(data(:,est)),1); %simulo datos con la distribución weibull teórica
   
   figure
   subplot(2,1,1);
   y=randperm(size(data,1))';
   plot(data(y,est)) % Original data
   subplot(2,1,2)
   plot(r(1:size(data,1),1))   % Simulated data
end


