function struct=statistics(struct,X,stats,dates,varargin)
%calculates basis statistics for input matrix
%   Detailed explanation goes here
block='D';
missing=1;
detrendClass='linear';
for i=1:2:length(varargin)
	switch lower(varargin{i}),
		case 'block', block=varargin{i+1};
		case 'missing', missing=varargin{i+1};
		case 'detrend', detrendClass=varargin{i+1};
		otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
	end
end

for i=1:length(stats)
    warn=0;
	disp(stats{i})
	switch lower(stats{i}),
		case 'max',
			Z=max(X,[],1);
        case 'min',
			Z=min(X,[],1);
        case 'nan',
			Z=100*mean(double(isnan(X)));
        case 'mean',
			Z=nanmean(X);
        case 'median',
			Z=nanmedian(X);
        case 'std',
			Z=nanstd(X);
        case 'iqr',
			Z=iqr(X);
        case 'pct01'
            Z=prctile(X,1);
        case 'pct05'
            Z=prctile(X,5);
        case 'pct10'
            Z=prctile(X,10);
        case 'pct90'
            Z=prctile(X,90);
        case 'pct95'
            Z=prctile(X,95);
        case 'pct99'
            Z=prctile(X,99);
        case 'trend'
            %alternative version without prewhitening
            aggdata = aggregateData(X,datenum(dates),block,'missing',missing);
            [pValue,Z]=testTrend(aggdata);
            %now we prewhiten the seasonal/annual mean time series
            %(Kulkarni & von Storch 1995) to cancel the effect of seriel correlation on trend calculation
%           aggdata = aggregateData(X,datenum(dates),block,'missing',missing);  
%            [ndata,Nest]=size(aggdata);
% 			for i=1:Nest
% 				acorr=autocorr(aggdata(:,i),1);
% 				acorr=acorr(2,1);
% 				serialcorr(i,:) = acorr;
%             end
%             for i=2:ndata
%                 Xnew(i,:)=X(i,:)-X(i-1,:)*serialcorr;
%             end           
%             [pValue,Z]=testTrend(Xnew);
			struct=setfield(struct,'trendpvalue',pValue);
        case 'intervar'
            %calc standard deviation of the detrended aggregated seasonal
            %times series (Giorgi & Francesco 2000)
            aggdata = aggregateData(X,datenum(dates),block,'missing',missing);
            [pValue,trend]=testTrend(aggdata,'test','mannkendall','missing',missing);
            Z=sqrt(nanvar(nandeTrend(aggdata,pValue,'treshold',1,'missing',missing,'trend',detrendClass)));
            % Z=nanstd(detrend(aggdata,detrendClass));
        otherwise, warning(sprintf('Unknown statistic: %s (ignored)',stats{i})); warn=1;
    end
    if (~warn)
	struct=setfield(struct,lower(stats{i}),Z);
    end
end
%Citations

%Kulkarni A & von Storch H (1995): Monte Carlo experiments on the effect of
%serial correlation on the Mann-Kendall test of trend

%Giorgi Francisco (2000)

