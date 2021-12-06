function [pValue,T,N,K,ST]=testHomogeneityNew(data,varargin)
% [pValue,T,N]=testHomogeneityNew(data,varargin)
% 
% Input
% 	data(:,k)   : Daily data series for each of the 'k' stations.
% 	varargin	: optional parameters
% 	  'missing' - Maximum rate of missing data within each window to be
% 	                  considered not a NaN (movingAverage function). Default zero.
%     'window'  - window size to aggregate the data (e.g. 365 for
%                     years is the data is daily). The default value is 1.
%     'test'    - estatistical test: {'Alexandersson'}, 'Snht', 'Buishand',
%     Pettit or Von Neumann.
%     'significance' - significance level. Depends of method.
%     'params'  - test's parameters.
% 
% Output    
% 	pValue      : p-value of the test for each of the stations.
%   T           : test's statistic.
%   N           : number of data used.
% 
% Examples
% 
% 		pValue=testHomogeneityNew(data,location,'period','year');
%       [pValue,T,N]=testHomogeneityNew(data,location,'period','year','missing',0.9);

missing=0;
window=1;
test='alexandersson';
location=[];
neigh=5;
neighDist=realmax;
commonData=0;
type='ratio';
significance=[];
criticalValue='simulacion';
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'window', window=varargin{i+1};
        case 'missing', missing=varargin{i+1};
        case 'test', test=varargin{i+1};
        case 'location', location=varargin{i+1};
        case 'neigh', neigh=varargin{i+1};
        case 'type', type=varargin{i+1};
        case 'criticalvalue', criticalvalue=varargin{i+1};
        case 'neighdist', neighDist=varargin{i+1};
        case 'commondata', commonData=varargin{i+1};
        case 'significance', significance=varargin{i+1};            
    end
end
[ndata,Nest]=size(data);
pValue=zeros(Nest,1)+NaN;
T=zeros(Nest,1)+NaN;
N=zeros(Nest,1)+NaN;

data=movingAverage(data,window,'missing',missing);

switch lower(test)
    case 'alexandersson'
        [pValue,T,N,K,ST]=testAlexandersson(dato,location,'neigh',neigh,'type',type,'criticalValue',criticalValue);
    case 'buishand'
        [pValue,T,N]=testBuishand(dato);
    case 'pettit'
        [pValue,T,N,K]=testPettit(dato);
    case 'vonneumann'
        [pValue,T,N]=testVonNeumann(dato);
    case 'snht'
        [pValue,T,N,K,ST]=testSnht(dato,'criticalValue',criticalValue);
end

if ~isempty(significance)
    ind=find(pValue>significance);
    pValue(ind)=NaN;
    T(ind)=NaN;
    N(ind)=NaN;
end