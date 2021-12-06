function [EOF,PC,MN,DV,PEV,PEVi] = computeEOF(X,varargin)
%computeEOF(X,varargin)
%
%Computes:
%   the Empirical Ortogonal Functions (EOFs) in columns: EOF(:,1) is the first EOF 
%   the Principal Components (PCs), in columns 
%   the mean (MN) and standard deviation (DV) of the data (for the field, or gridbox by gridbox)
%   the cummulative proportion of explained variance by i-th PC (PEV),
%   the explained variance PEVi for each of the parameters, for teh fields reconstructed from 'npc' PCs.
%
%Input data must be given in the following format: X(t,i).
% X(t,:) is the t-th element (observation) in the sample
% X(:,i) is the temporal series of the i-th variable
%
%	varargin	: optional parameters
%       'dmn'    -  domain
%	    'npc'	 -	[number] is the number of PC-EOF retained.
%		'path'	 -  ['path'] is a path to store the resulting variables. If no path
%		'pst' -  ['fields' (default) or 'gridboxes']. 
%                   'gridboxes': Preprocesses the data set fields so that they have zero mean
%                   and standard deviation of 1 at each grid point. 
%                   'fields': standardization variable by variable
%                   (considering the spatial field). For this option a domain must be
%                   provided in the optional parameters as: 'dmn', dmn.
%
%	Examples:
%		dmn=readDomain('Nao');
%       ctl.cam=dmn.src;
%       ctl.fil='era40.ctl';
%       [fields,dmn]=getFieldfromGRIB(ctl,dmn);
%       [EOF,PC,MN,DV,PEV]=computeEOF(fields,'npc',50,'path',dmn.path);
X0 = X;
nd = size(X,1);
NPC=size(X,2);
cam=[];
pst='fields';
dmn=[];
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'ncp', NPC = varargin{i+1}; %deprecated
        case 'npc', NPC = varargin{i+1};
        case 'path', cam = varargin{i+1};
        case 'pst', pst = varargin{i+1};
        case 'dmn', dmn = varargin{i+1};
    end
end
MN=zeros([1,size(X,2)]);
DV=ones([1,size(X,2)]);
if strcmp(pst,'yes') || strcmp(pst,'gridboxes')    
        [X ,MN, DV] = nanpstd(X);    
elseif strcmp(pst,'fields')
    nv=size(dmn.par,1);
    for inv = 1:nv
        indcol = findVarPosition(dmn.par{inv,1},dmn.par{inv,3},dmn.par{inv,2},dmn);
        auxMN = nanmean(nanmean(X(:,indcol)),2);
        auxDV = nanmean(nanstd(X(:,indcol)),2);
        MN(:,indcol) = repmat(auxMN,1,length(indcol));
        DV(:,indcol) = repmat(auxDV,1,length(indcol));
        X(:,indcol) = (X(:,indcol) - repmat(auxMN,nd,length(indcol))) ./ repmat(auxDV,nd,length(indcol));
        clear auxMN auxDV
    end
end
%setStatus('EOF Analysis','Starting');
%Default Option
COV=cov(exciseRows(X));
%n=size(X,2);
%COV=zeros(n);
%disp('Computing covariance matrix...');
%for i=1:n,
%   x=X(:,i);
%   x=x-mean(x);
%   for j=i:n,
%      y=X(:,j);
%      y=y-mean(y);
%      COV(i,j)=(x'*y)/n;
%      COV(j,i)=COV(i,j);
%   end
%end
disp('Computing EOFs...');
[EOF,PEV]=eig(COV);
[PEV,ind]=sort(-diag(PEV));
PEV=cumsum(PEV/sum(PEV))*100;
EOF=EOF(:,ind);

%Option 1. Works with missing data
%COV=nancov(X);
%[u,PEV,EOF]=svd(COV);
%[u,PEV,EOF]=svds(COV,NPC);
%PEV=cumsum(diag(PEV));

%Option 2. Matlab PC function
%[C, SCORE, LATENT, TSQUARE] = PRINCOMP(X)

%Opcion 3: NAG routines
%[PEV,EOF]=g03aaf(X);
%PEV(i,1) eigenvalues of i-th pc
%PEV(i,2) proportion of explained variance by i-th pc
%PEV(i,3) cummulative proportion of explained variance by i-th pc
%PEV(i,4) chi^2 by i-th pc
%PEV(i,5) degrees of freedom for the chi^2 by i-th pc
%PEV(i,6) significance level for the chi^2 by i-th pc
%EOF(:,j)  components of j-th pc

disp('Computing PCs...');
EOF=EOF(:,1:NPC);
PC=X*EOF;
%PC=PC(:,1:NPC);
PEV=PEV(1:NPC,1);
%Matrix of transformed Data

if exist('dmn','var') && isfield(dmn,'par')
XR=PC2Field(PC,EOF,MN,DV);
PEVi=[];
for i=1:size(dmn.par,1)
    ii = findVarPosition(dmn.par{i,1},dmn.par{i,3},dmn.par{i,2},dmn);
    PEVi(i) = nanmean(var(XR(:,ii)) ./ var(X0(:,ii)),2);
end
end

if ~isempty(cam),
    disp([cam]);
    disp('Saving files...');
    eval(['save ' cam 'EOF.mat EOF']);
    eval(['save ' cam 'PC.mat PC']);
    eval(['save ' cam 'PEV.mat PEV']);
    eval(['save ' cam 'MN.mat MN']);
    eval(['save ' cam 'DV.mat DV']);
end

