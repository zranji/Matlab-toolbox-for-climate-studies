function [pValue,corr,newData]=testSerial(data,varargin)
% [pVal,corr,newData]=testSerial(data,varargin)   Wald-Wolfowitz test for serial correlation
% 
% Input
% 	data(:,k)   : Daily data series for each of the 'k' stations.
% 	varargin	: optional parameters
% 	  'missing' - missing parameter for the 'movingAverage' function
%     'period'  - 'day', 'month' or 'year'
% 	
% Output    
% 	pValue      : p-value of the test for each of the stations.
%   corr        : +/- sign of the serial correlation 
%   newData     : Transformed data used in the test
% 
% Examples
% 
% 		pVal=testSerial(data,'period','year');
%       [pVal,corr,dataY]=testSerial(data,'period','year','missing',0.9);

missing=0; 
period='';
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'period', period=varargin{i+1};
        case 'missing', missing=varargin{i+1};
    end
end

[ndata,Nest]=size(data);
pValue=zeros(1,Nest)+NaN;
corr=zeros(1,Nest)+NaN;
newData=[];
k=1;
switch(period)
    case('day')
        k=1;
    case('month')
        k=30;
    case('year')
        k=365;
end

for i=1:Nest
    aux=data(:,i);
    dato=movingAverage(aux,k,'missing',missing);
    newData=[newData, dato];
    dato=dato(find(isnan(dato)==0));
    N=length(dato);
    if N>1
        rangos=zeros(1,N);
        aux1=unique(dato);
        aux2=sort(dato);
        for j=1:length(aux1)
            a=find(aux2==aux1(j));
            b=find(dato==aux1(j));
            if length(a)>1
                rangos(b)=mean(a);
            else
                rangos(b)=a;
            end
        end
        rangos=rangos-mean(rangos);
        rangos=[rangos rangos(1)];
        r=sum(rangos(1:N).*rangos(2:N+1))/sum(rangos.^2);
        corr(i)=((N-1)*r+1)/sqrt(N-1);
        if corr(i)>0
            pValue(i)=2*(1-normcdf(corr(i)));
        end
        if corr(i)<0
            pValue(i)=2*normcdf(corr(i));
        end 
        corr(i)=sign(corr(i));
    end
    
end