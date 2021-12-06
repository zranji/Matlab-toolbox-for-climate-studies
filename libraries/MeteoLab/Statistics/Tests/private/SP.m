function [pValue,trend,u,newData]=SP(data,varargin)
% [pVal,u,newData]=SP(data,varargin)   Spearman test for serial trend
% 
% Input
% 	data(:,k)   : Daily data series for each of the 'k' stations.
% 	varargin	: optional parameters
% 	  'missing' - missing parameter for the 'movingAverage' function
%     'period'  - 'day', 'month' or 'year'
% 	
% Output    
% 	pValue      : p-value of the test for each of the stations.
%   u           : +/- sign of the serial trend
%   newData     : Transformed data used in the test
% 
% Examples
% 
% 		pVal=SP(data,'period','year');
%       [pVal,u,dataY]=SP(data,'period','year','missing',0.1);

missing=0; 
period='';
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'period', period=varargin{i+1};
        case 'missing', missing=varargin{i+1};
    end
end

[ndata,Nest]=size(data);
pValue=zeros(1,Nest);
trend=zeros(1,Nest);
u=zeros(1,Nest);
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

newData=movingAverage(data,k,'missing',missing);
for i=1:Nest
    dato=newData(find(isnan(newData(:,i))==0),i);
    N=length(dato);
	b=regress(dato,[ones(N,1) [1:N]']);
	trend(i)=b(2);
    rangos=zeros(1,N);
    aux1=unique(dato);
    aux2=sort(dato);
    for l=1:length(aux1)
        a=find(aux2==aux1(l));
        b=find(dato==aux1(l));
        if length(a)>1
            rangos(b)=mean(a);
        else
            rangos(b)=a;
        end
    end 
    Rs=1-((6/(N*(N^2-1)))*sum((rangos-[1:N]).^2));
    var=1/(N-1);
    u(i)=Rs*sqrt(N-1);
    if u(i)>0
        pValue(i)=2*(1-normcdf(u(i)));
    end
    if u(i)<0
        pValue(i)=2*normcdf(u(i));
    end
end
% u=sign(u);