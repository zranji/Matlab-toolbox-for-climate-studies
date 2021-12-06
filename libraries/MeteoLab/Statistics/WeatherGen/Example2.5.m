Example.Network={'MyStations'};
Example.Stations={'dailyPrecip.stn'};
Example.Variable={'common'};
[data,Example]=loadStations(Example,'ascfile',1);
data=data(:,1);   % Selecting the first stataion: San Sebastian.

Pre(find(data==0),1)=0;
Pre(find(data>0),1)=1;

c=zeros(2,2); for k=2:size(Pre,1)
   i=Pre(k-1)+1;
   j=Pre(k)+1;
   c(i,j)=c(i,j)+1;
end

p10=c(1,2)/(c(1,1)+c(1,2)); %P(1|0)=P(1,0)/P(0);
p11=c(2,2)/(c(2,1)+c(2,2)); %P(1|1)=P(1,1)/P(1);
p0=sum(Pre(:,1)==0)/size(Pre,1);

N=size(Pre,1); %Length of the simulated series
x=zeros(N,1); u=rand;
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