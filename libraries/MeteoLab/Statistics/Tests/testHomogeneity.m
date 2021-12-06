function [pValue,T,N,K,ST,sigma]=testHomogeneity(data,varargin)
% [pValue,T,N]=testHomogeneity(data,varargin)
% 
% Input
% 	data(:,k)   : Daily data series for each of the 'k' stations.
% 	varargin	: optional parameters 
% 	  'missing' - Maximum rate of missing data within each window to be
% 	                    considered not a NaN (movingAverage function). Default zero.
%          'window' - window size to aggregate the data (e.g. 365 for
%                            years is the data is daily). The default value is 1.
%                'test' - statistical test: {'Alexandersson'}, 'Snht', 'Buishand',
%                           Pettit or Von Neumann.
%'significance' - significance level. Depends of method.
% Pameters only for Alexandersson's test:
%       'location' - longitud and latitud of stations.
%	    'neigh' - minimun number of neighbour to applie the test.
%             'type' - {'ratio'} for precipitation and 'difference' for temeprature. 
%     'neighdist' - distance
%'commondata' - minimun common data for the series.
%'criticalvalue' - {'tabla'} or 'simulation'. Also to Snht Test
% 'referencialseries'  - index of the referencial series.
% Output    
% 	pValue      : p-value of the test for each of the stations.
%   T           : test's statistic.
%   N           : number of data used.
% 
% Examples
% 
% 	pValue=testHomogeneity(data,'window',365,'missing',0.1,'test','snht','criticalValue','tabla');

missing=1;
window=1;
test='alexandersson';
location=[];
neigh=5;
neighDist=realmax;
commonData=0;
type='ratio';
significance=[];
criticalValue='tabla';
dispWaiting=1;
delta=5;
[ndata,Nest]=size(data);
refIndex=[1:Nest];
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'window', window=varargin{i+1};
        case 'missing', missing=varargin{i+1};
        case 'test', test=varargin{i+1};
        case 'location', location=varargin{i+1};
        case 'neigh', neigh=varargin{i+1};
        case 'type', type=varargin{i+1};
        case 'criticalvalue', criticalValue=varargin{i+1};
        case 'neighdist', neighDist=varargin{i+1};
        case 'commondata', commonData=varargin{i+1};
        case 'significance', significance=varargin{i+1};
        case 'delta', delta=varargin{i+1};
        case 'disp', dispWaiting=varargin{i+1};
		case 'referencialseries', refIndex=varargin{i+1};
    end
end

pValue=zeros(Nest,1)+NaN;
T=zeros(Nest,1)+NaN;
N=zeros(Nest,1)+NaN;

data=movingAverage(data,window,'missing',missing);

switch lower(test)
    case 'alexandersson'
        [pValue,T,N,K,ST,sigma]=testAlexandersson(data,location,'neigh',neigh,'neighDist',neighDist,'type',type,'criticalValue',criticalValue,'commonData',commonData,'delta',delta,'referencialseries',refIndex);
    case 'buishand'
        [pValue,T,N,K]=testBuishand(data);
    case 'pettit'
        [pValue,T,N,K]=testPettit(data);
    case 'vonneumann'
        [pValue,T,N]=testVonNeumann(data);
    case 'snht'
        [pValue,T,N,K,ST]=testSnht(data,'criticalValue',criticalValue,'disp',dispWaiting,'delta',delta);
end

if ~isempty(significance)
    ind=find(pValue>significance);
    pValue(ind)=NaN;
    T(ind)=NaN;
    N(ind)=NaN;
end