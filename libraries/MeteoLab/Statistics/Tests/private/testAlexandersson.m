function [pValue,T,N,K,validNeig,sigma]=testAlexandersson(data,location,varargin)
% [pValue,T,N]=testAlexandersson(data,location,varargin)
% 
% Alexanderson test for homogeneity (5 points are removed at the begining and end).
% If only the 'neigh' parameter is given, a fixed number of neighbors is considered.
% If 'neighDist' and 'commonData' are specified then the reference series will be based
% on the stations within the the neighborhood radio 'neighDist' with a larger
% number of coincident data, with a minimum of 'commonData' simultaneous data
% for all the considered neighbors.
%
% Input
% 	data(:,k)       : Data series for each of the 'k' stations.
%   location(k,:)   : Position of the k-th station.
% 	varargin	    : optional parameters
%     'type'        - {'ratio'} or 'difference'
%     'window'      - window size to aggregate the data (e.g. 365 for
%                     years is the data is daily). The default value is 1.
% 	  'missing'     - Maximum rate of missing data within each window to be
% 	                  considered not a NaN (movingAverage function). Default zero.
% 	  'neigh'       - number of neighbors for the test (default 5).
%     'neighDist'   - radial distance of neighbourhood (in degrees).
%     'commonData'  - minimun number of common aggregated data (0 by default).
%     'criticalValue' - {'simulacion'} or 'tabla'. Argument for the auxiliar function testSnht. 
%     'delta' - {5}    

% Output    
% 	pValue      : pValue of the hipotesis 'the station is homogeneous' for each of the stations. 
%                 Low values correspond to inhomogeneous stations.
%   T           : statistic of Alexandersson's test
%   N           : sample size used to run the test
%   K	         : year of posible shift
%   validNeig : number of neighbours
%   sigma    : standart deviation of referencial series.
% Examples
% 
% 		pValue=testAlexandersson(data,location,'period','year');
%       [pValue,T,N]=testAlexandersson(data,location,'period','year','missing',0.9);

missing=0;
window=1;
neigh=5;
neighDist=realmax;
commonData=0;
type='ratio';
criticalValue='tabla';
delta=5;
[nData,nStation]=size(data);
refIndex=[1:nStation];
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'type', type=varargin{i+1};
        case 'window', window=varargin{i+1};
        case 'missing', missing=varargin{i+1};
        case 'neigh', neigh=varargin{i+1};
        case 'neighdist', neighDist=varargin{i+1};
        case 'commondata', commonData=varargin{i+1};
        case 'delta', delta==varargin{i+1};
		case 'criticalvalue', criticalValue=varargin{i+1};
		case 'referencialseries', refIndex=varargin{i+1};
    end
end

[nData,nStation]=size(data);
pValue=zeros(nStation,1)+NaN;
validNeig=zeros(nStation,1)+NaN;
T=zeros(nStation,1)+NaN;
N=zeros(nStation,1)+NaN;
K=zeros(nStation,1)+NaN;
sigma=zeros(nStation,1)+NaN;

dataA=movingAverage(data(:,:),window,'missing',missing);
for j=1:nStation
    % dis=sqrt((location(:,1)-location(j,1)).^2+(location(:,2)-location(j,2)).^2);
    dis=sqrt((location(refIndex,1)-location(j,1)).^2+(location(refIndex,2)-location(j,2)).^2);
    int=find(dis<=neighDist & dis>0);
    serie=dataA(:,j);
    if (commonData==0)
        aux=sort(dis(int));
        [dis,ind]=intersect(dis,aux(2:min(neigh+1,length(aux))));  %Taking the 5 closest neighbors
        seriesRef=dataA(:,refIndex(ind));
        commonInd=1:size(serie,1);
    else
        seriesRef=dataA(:,refIndex(int));
        [ind,ndata,serie,seriesRef]=testHomogeneitySelect(serie,seriesRef,neigh,commonData);
        commonInd=find(nansum(double(~isnan([serie seriesRef])),2)==size(seriesRef,2)+1);
    end
    if(isempty(seriesRef))
        validNeig(j)=0;
        Q=serie;
    else
		m=nanmean(serie(commonInd));
        ms=nanmean(seriesRef(commonInd,:));
        aux=nancorrcoef([serie,seriesRef],2);
        rho=aux(1,2:end);
        valid=find(~isnan(rho));
        Q=NaN*ones(size(seriesRef,1),1);
        for i=1:size(seriesRef,1)
            aa=intersect(find(~isnan(seriesRef(i,:))),valid);
            if (~isempty(aa) & ~isnan(serie(i)))
				coef=nansum(rho(aa).^2);
                switch type
                    case ('ratio')
                        Q(i)=coef*serie(i)/(m*(nansum((seriesRef(i,aa).*rho(aa).^2)./ms(aa))));
                    case ('difference')
                        Q(i)=serie(i)-nansum((seriesRef(i,aa)-ms(aa)+m).*rho(aa).^2)/coef;
                end
            end
        end
        validNeig(j)=length(ind);
    end
	[pValue(j),T(j),N(j),K(j)]=testSnht(Q,'criticalValue',criticalValue,'delta',delta,'disp',0);
	sigma(j)=nanstd(Q);
    if (mod(j-1,floor(nStation/10))==0) disp([num2str(j) '/' num2str(nStation)]); end
end