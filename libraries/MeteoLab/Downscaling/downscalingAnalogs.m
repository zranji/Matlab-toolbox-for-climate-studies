function [Ypred,cluster,indang] = downscalingAnalogs(X,Y,indTrain,indTest,varargin)

% Make a prediction based on analogs
%  Input and output arguments ([]'s are optional): 
%    X: matrix [p x n] where:
%       p = number of samples
%       n = number of features of each sample
%    Y: matrix [p x q] where:
%       p = number of samples
%       q = number of individual predictands
%    indTrain: vector with the index of the samples (rows) 
%              of X and Y used for trainning
%    indTest: vector with the index of the samples (rows) 
%             of X and Y used for testing
%    [argID, (string) See below
%    value]  (varies) 
%
% Here are the valid argument IDs and corresponding values:
%   'numan'  (scalar): Maximun number of analogs (by default 30 for no cluster and the whole set for cluster)
%   'method' (string): Type of regression:
%          'mean':   Mean (default)
%          'wmean':  Distance weighted mean
%          'prcXX':  Percentile where XX indicates the percentile
%          'rand':   Random
%   'cluster'   (struct): Cluster with the meteolab struct (use makeClustering function)
%	    cluster.NumberCenters: Number of Centers of the Clustering
%	    cluster.Type: Type of Clustering ('kmeans' or 'som')
%	    cluster.Centers: Centers or Prototypes of the Clustering
%	    cluster.PatternsGroup: Cluster that belongs each pattern in Data (by rows)
%	    cluster.PatternDistanceGroupCenter: Distance of each pattern to the center of the cluster
%	    cluster.SizeGroup: Size of each cluster
%	    cluster.Group: Patterns from DATA that belongs to each cluster.
%   'window'    (scalar): Length of exclusion window (by default 0)
%   'display'   (string): 'on' (default) or 'off'. Display process info or not

Ypred = [];
%HH=[];
dispOk = 'on';
error(nargchk(4,14,nargin));
cluster = '';
method  = 'mean';
numan   = [];
prct    = 75;
window  = 10;
if (size(X,1)~=size(Y,1))
    error('X and Y dimenssions must match');
end
i=1;
while i<=length(varargin), 
  argok = 1;
  switch varargin{i},
     case 'numan',      i=i+1; numan = varargin{i}; 
     case 'method',     i=i+1; method = varargin{i}; 
        if (strmatch('prc',method)) prct=str2num(method(4:end));
            if (isempty(prct)) error('Percentile argument not valid'); end
            method = 'prc'; 
        end
     case 'cluster',    i=i+1; cluster = varargin{i}; 
     case 'display',    i=i+1; dispOk = varargin{i};
     case 'window',     i=i+1; window = abs(varargin{i}); window = min(window,size(X,1)-2);
     otherwise argok=0;
  end
  if ~argok, 
    disp(['Ignoring invalid argument #' num2str(i+1)]); 
  end
  i = i+1; 
end

if (strcmp(dispOk,'on'))
    dispOk=1;
else
    dispOk=0;
end

% if cluster
useCluster = 0;
if ~isempty(cluster)
    if (dispOk) disp('Reading cluster...'); end
    if (isfield(cluster,'Centers')~=1)
        error('Error reading cluster');
    end
    if (size(cluster.Centers,2)~=size(X,2))
        error('X and cluster centers dimensions must agree');
    end
    if (dispOk) disp('Calculating BMUs...'); end
    [bmus] = MLknn(X,cluster.Centers,1,2);
    useCluster = 1;
end

if (useCluster)
    if (dispOk) disp(['Analogs with cluster']);end
    NC=size(cluster.Centers,1);
    if(window==0)
        n=histc(bmus(indTrain),[1:size(cluster.Centers,1)]);
        [Yc,indang] = regression_int([X(indTrain,:);cluster.Centers],Y(indTrain,:),...
            1:length(indTrain),length(indTrain)+(1:NC),method,n,prct,0,dispOk);
        %Ypred = regression_int([cluster.Centers;X(indTest,:)],Yc,...
        %    1:size(cluter.Centers,1),size(cluter.Centers,1)+(1:length(indTrain)),method,1,prct,0,dispOk);
        Ypred=Yc(bmus(indTest),:);
        %if we are interested in cluster details of the data
        if(nargout>1)
            cluster.CentersFreqTrain=nan*ones(size(cluster.Centers,1),1);
            cluster.CentersFreqTrain(:)=n(:);
            cluster.CentersProbTrain=cluster.CentersFreqTrain/nansum(cluster.CentersFreqTrain,1);
            cluster.CentersPtndTrain=Yc;
            cluster.CentersFreqTest=histc(bmus(indTest),[1:size(cluster.Centers,1)]);
            cluster.CentersProbTest=cluster.CentersFreqTest/nansum(cluster.CentersFreqTest,1);
        end
    else
        %if we are interested in cluster details of the data
        if(nargout>1)
            cluster.CentersFreqTrain=nan*ones(size(cluster.Centers,1),1);
            cluster.CentersFreqTest=nan*ones(size(cluster.Centers,1),1);
        end
        Ypred = zeros(length(indTest),size(Y,2))+NaN;
        for nc = 1:size(cluster.Centers,1)
            [indsTr]  = find(bmus==nc);
            indsTr = intersect(indsTr,indTrain);
            if (dispOk) disp([' Analogs in cluster #' num2str(nc) ' with ' num2str(length(indsTr)) ' samples']);end            
            [indsTe] = find(bmus==nc);
            indsTe = intersect(indsTe,indTest);
            if isempty(numan) 
				numanC = length(indsTr); 
			else
				numanC = numan;
			end
            [Ypred(indsTe,:),indang] = regression_int(X,Y,indsTr,indsTe,method,numanC,prct,window,dispOk);
            if(nargout>1)
                cluster.CentersFreqTrain(nc)=length(indsTr);
                cluster.CentersFreqTest(nc)=length(indsTe);
            end
        end
        if(nargout>1)
            cluster.CentersProbTrain=cluster.CentersFreqTrain/nansum(cluster.CentersFreqTrain,1);
            cluster.CentersProbTest=cluster.CentersFreqTest/nansum(cluster.CentersFreqTest,1);
        end
    end
else
    if (dispOk) disp([' Analogs without cluster with ' num2str(length(indTrain)) ' samples']);end
	if isempty(numan) numan = 30; end
    [Ypred,indang] = regression_int(X,Y,indTrain,indTest,method,numan,prct,window,dispOk);
end

if (dispOk) disp('Finished'); end



function [Yhat,indAng] = regression_int(X,Y,indTrain,indTest,method,numan,prct,windowLength,dispOk)

Xtrain=X(indTrain,:);
Xtest=X(indTest,:);

Prdc.Type  = 'Det';
Prdc.NumA  = numan;

if(windowLength==0)
    Prdc.IndEx = [];
else    
    Prdc.IndEx = indTest;
end

Prdc.NEx   = floor((windowLength-1)/2);

if(size(numan,1)>1)
    NA=numan;
else
    NA=7*numan;
end

%if (any(NA(:)>length(indTrain)))
%    NA=min(NA,repmat(length(indTrain),size(NA)));
%    if (dispOk)
%        warning('  Too many analogs requested');
%    end
%end    

Yhat = zeros(size(Xtest,1),size(Y,2));
if(NA>size(Xtrain,1)) NA = size(Xtrain,1); end
[indAng,distAng] = MLknn(Xtest,Xtrain,NA,2);

indAng=indTrain(indAng);

switch method,
 case 'mean',
    Yhat = prediccionDetWm(indAng,ones(size(distAng)),Y,Prdc);
 case {'wm','wmean'}
    Yhat = prediccionDetWm(indAng,1./distAng,Y,Prdc);     
 case 'prc',
    Prdc.Umb = prct/100;
    Yhat = prediccionDetPercentile(indAng,distAng,Y,Prdc);     
 case 'rand'
    Yhat = prediccionRand(indAng,Y,numan);
 otherwise error('  Method not valid');
end

function Y1=prediccionRand(indAnlg,Y0,na)
[ndy,ne]=size(Y0);
nd=size(indAnlg,1);
if ((ne ~= 1 & ne~=size(Y0,2)) | (nd~=1 & nd~=size(indAnlg,1)))
   error(['Las dimensiones de NumA no son las correctas: ' num2str([nd ne])]);
end
Y1=repmat(NaN,size(indAnlg,1),size(Y0,2));
for l=1:size(indAnlg,1)   
	ni=indAnlg(l,:);
	i=find(ni>=1 & ni<=ndy);
	ni=ni(i);
	i=find(sum(double(isnan(Y0(ni,:))),2)==0);
	ni=ni(i);
	sni=min([na,length(ni)]);
	sni=randperm(sni);
	Y1(l,:)=Y0(ni(sni(1)),:);
end
