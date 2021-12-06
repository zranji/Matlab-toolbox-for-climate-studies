function struct=reliability(struct,X,Y,score,varargin)

%Calculates bias, pdf-scores and tests de Kolmogorow-Smirnov
%   
%
% Input:
	% - X: ndata*Nest matrix with the observations. Timesteps along the columns and stations along the rows.
	% - Y: ndata*Nest matrix with the forecasts. This matrix must have the same size that X.  
	% {'bias';'biasstd','biasiqr','sigbias','pdfscore','pdf10score','pdf90score','kspvalue','ksscore','ks90pvalue','ks90score','ks10pvalue','ks10score'}
	% see https://www.meteo.unican.es/trac/esTcena/wiki/ValidacionGCMs for definition of the scores 
    
	% - Optional parameters:
		% % - bins: number of bins used for kernel density smoothing, default
        % is 100
		
		
% Output:
	% - struct: string of structures with the same size of the input score. Each structure contains two fields:
		% - scoreName: the score's name.
		% - scoreValue: 1*Nest matrix with the value of the score. 
%Example:
%X=rand(1000,10)
%Y=rand(1000,10)
%[struct]=reliability({'score'},{'pdfscore'},X,Y); 

[nfechas,nest] = size(X);
rtbv = 'full';
[ndata,Nest]=size(X);
scale=0;
b=64;
tau=0.95;
% W=(max([max(X);max(Y)])-min([min(X);min(Y)]))/(b-1);
% censoring=false(ndata,1);
% kernel='normal';
% support='unbounded';
% weights=1/ndata;
% width=[];
% funct='cdf';
% minimum = 1;
% step = 1;
% maximum = 99;
draw=0;

for i=1:2:length(varargin)
	switch lower(varargin{i}),
		case 'scale', scale=varargin{i+1};
		case 'bins', b=varargin{i+1};
        case 'rtbv', rtbv=varargin{i+1};
		case 'tau', tau=varargin{i+1};
% 		case 'binswidth', W=varargin{i+1};		
% 		case 'censoring', censoring=varargin{i+1};
% 		case 'kernel', kernel=varargin{i+1};
% 		case 'support', support=varargin{i+1};
% 		case 'weights', weights=varargin{i+1};
% 		case 'width', width=varargin{i+1};
% 		case 'function', funct=varargin{i+1};
% 		case 'minimum', minimum=varargin{i+1};
% 		case 'maximum', maximum=varargin{i+1};
% 		case 'step', step=varargin{i+1};
		case 'draw', draw=varargin{i+1};
		otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
	end
end

if nargin<3,
	error('too few parameters');
end
for i=1:length(score)
    warn=0;
	disp(score{i})
	switch lower(score{i}),
        case 'bias',
			Z=bias(X,Y);
        case 'biasstd',
			Z=bias(X,Y,'scale','std');
        case 'biasiqr',
			Z=bias(X,Y,'scale','iqr');
        case 'biasmean',
			Z=bias(X,Y,'scale','mean');
		case 'sigbias',
			Z=sigbias(X,Y);
% 		case 'leps',
% 			Z=leps(X,Y,W,'censoring',censoring,'kernel',kernel,'support',support,'weights',weights,'width',width,'function',funct);
% 		case 'lepsext',
% 			Z=leps(X,Y,W,'bins',b,'censoring',censoring,'kernel',kernel,'support',support,'weights',weights,'width',width,'function',funct);
% 		case 'maepct',
%             Z=maepct(X,Y,'minimum',minimum,'maximum',maximum,'step',step,'draw',draw);		
		case 'pdfscore',
			Z=prs(X,Y,b);
        % case 'pdfscoreboot',
			% Z=bootstrp(1000,@prs,X,Y,b); 
        case 'pdf90score',
			Z=prs(X,Y,b,'rtbv','pdf90');
        % case 'pdf90scoreboot',
			% Z=bootstrp(1000,@prs,X,Y,b,'rtbv','pdf90'); 
        case 'pdf10score',
			Z=prs(X,Y,b,'rtbv','pdf10');
        % case 'pdf10scoreboot',
			% Z=bootstrp(1000,@prs,X,Y,b,'rtbv','pdf10'); 
        case {'ksscore','kspvalue'}
            [pVal,kScore]=calcKS(X,Y,'rtbv','full');
			switch lower(score{i}),
				case {'ksscore'}
					Z=kScore;
				case {'kspvalue'}
					Z=pVal;
			end
        case {'ks5score','ks5pvalue'}
            [pVal,kScore]=calcKS(X,Y,'rtbv','pdf05');
			switch lower(score{i}),
				case {'ks5score'}
					Z=kScore;
				case {'ks5pvalue'}
					Z=pVal;
			end
        case {'ks10score','ks10pvalue'}
            [pVal,kScore]=calcKS(X,Y,'rtbv','pdf10');
			switch lower(score{i}),
				case {'ks10score'}
					Z=kScore;
				case {'ks10pvalue'}
					Z=pVal;
			end
        case {'ks90score','ks90pvalue'}
            [pVal,kScore]=calcKS(X,Y,'rtbv','pdf90');
			switch lower(score{i}),
				case {'ks90score'}
					Z=kScore;
				case {'ks90pvalue'}
					Z=pVal;
			end
        case {'ks95score','ks95pvalue'}
            [pVal,kScore]=calcKS(X,Y,'rtbv','pdf95');
			switch lower(score{i}),
				case {'ks95score'}
					Z=kScore;
				case {'ks95pvalue'}
					Z=pVal;
			end
        case {'cmscore','cmpvalue'}
            [pVal,kScore]=calcCM(X,Y,'rtbv','full');
			switch lower(score{i}),
				case {'cmscore'},Z=kScore;
				case {'cmpvalue'},Z=1-pVal;
			end
        case {'cm5score','cm5pvalue'}
            [pVal,kScore]=calcCM(X,Y,'rtbv','pdf05');
			switch lower(score{i}),
				case {'cm5score'},Z=kScore;
				case {'cm5pvalue'},Z=1-pVal;
			end
        case {'cm10score','cm10pvalue'}
            [pVal,kScore]=calcCM(X,Y,'rtbv','pdf10');
			switch lower(score{i}),
				case {'cm10score'},Z=kScore;
				case {'cm10pvalue'},Z=1-pVal;
			end
        case {'cm90score','cm90pvalue'}
            [pVal,kScore]=calcCM(X,Y,'rtbv','pdf90');
			switch lower(score{i}),
				case {'cm90score'},Z=kScore;
				case {'cm90pvalue'},Z=1-pVal;
			end
        case {'cm95score','cm95pvalue'}
            [pVal,kScore]=calcCM(X,Y,'rtbv','pdf95');
			switch lower(score{i}),
				case {'cm95score'},Z=kScore;
				case {'cm95pvalue'},Z=1-pVal;
			end
        case 'rv'
            Z=nanvar(Y)./nanvar(X);
		case 'riqr'
            Z=iqr(Y)./iqr(X);
		case {'cqvss','qvss'}
            Z=qvss(X,Y,tau);
		otherwise, 
			if strmatch('biasipr',lower(score{i}))
				aux=score{i};
				pp1=str2num(aux(1,8:9));pp2=str2num(aux(1,10:11));
				Z=bias(X,Y,'scale','ipr','lower',pp1,'upper',pp2);
			else
				warning(sprintf('Unknown accuracy score: %s (ignored)',score{i}));warn=1;
			end
    end
    if (~warn)
		struct=setfield(struct,lower(score{i}),Z);
    end
end

%%%% BIAS %%%%
function Z=bias(X,Y,varargin)
if nargin<2,
	error('too few p1arameters');
end
scale=0;pp1=25;pp2=75;
for i=1:2:length(varargin)
	switch lower(varargin{i}),
		case 'scale', scale=varargin{i+1};		
		case 'lower', pp1=varargin{i+1};		
		case 'upper', pp2=varargin{i+1};		
		otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
	end
end
switch scale
	case {0,'no','noscale'}
		Z=nanmean(Y)-nanmean(X);
	case {'iqr'}
		Z=(nanmean(Y)-nanmean(X))./iqr(X);
	case {'ipr'}
		Z=(nanmean(Y)-nanmean(X))./(prctile(X,pp2)-prctile(X,pp1));
    case {'std'}
		Z=(nanmean(Y)-nanmean(X))./nanstd(X);
    case {'mean'}
		Z=(nanmean(Y)-nanmean(X))./nanmean(X);
end


% %%%% SIGBIAS %%%%
% 
function Z=sigbias(X,Y);

DIFF=X-Y;
diffmean=nanmean(DIFF);
vardiff=nanvar(DIFF);
[n,p]=size(DIFF);
lag=NaN*zeros(1,p);
for i=1:p
	ind=find(~isnan(DIFF(:,i)));
	acf=nancorrcoef([DIFF(1:end-1,i) DIFF(2:end,i)]);
	lag(i)=acf(2,1);
end
neff=n*(1-lag)./(1+lag);
vareff=vardiff./neff;
Z=abs(diffmean./sqrt(vareff));

%%%%% PDF-score %%%%%
function Z=prs(X,Y,b,varargin)
% Calculates the PRS score
% Input: - X = Observations
%		 - Y = Forecasts. X and Y must be vectors or matrix
% 		 - b = number of bins, only works with its corresponding subfunction <prssub.m>
%
%set default
[nX,nest] = size(X);
[nY,nest] = size(Y);
rtbv = 'full';
for i=1:2:length(varargin)
	switch lower(varargin{i}),
		case 'rtbv', rtbv=varargin{i+1};				
		otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
	end
end
X=sort(X);Y=sort(Y);
switch lower(rtbv),
        case 'full'
			indX=[1:nX];indY=[1:nY];
        case 'pdf10'
            indX=[1:ceil(nX/10)];indY=[1:ceil(nY/10)];
        case 'pdf90'
            indX=[nX-floor(nX/10):nX];
            indY=[nY-floor(nY/10):nY];
		otherwise, warning(sprintf('Unknown range: %s (ignored)',rtbv));
end
X=X(indX,:);
Y=Y(indY,:);
Z=NaN*zeros(1,nest);
ind=find(~isnan(nanmean(X)) & ~isnan(nanmean(Y)));
if ~isempty(ind)
	Z(ind)=prssub(X(:,ind),Y(:,ind),b);
end

function Z=prssub(X,Y,b)
% subfunction of prs
% Calculates the Perkins reliability score for vectors:
% Input: - X = Observations
%		 - Y = Forecasts. X and Y must be vectors
% 		 - b = number of bins, 
maxo=max(X,[],1);
maxf=max(Y,[],1);
maxval=max([maxo;maxf],[],1);
mino=min(X,[],1);
minf=min(Y,[],1);
minval=min([mino;minf],[],1);
% defines the interval the kernel density estimates are calculated for
w=(maxval-minval)/(b-1);
for i=1:size(X,2)
	interval=minval(i):w(i):maxval(i);
	%Calculates cumulative probabilities for the observations
	[fo,XIo] = ksdensity(X(:,i),interval,'function','pdf');
	%Calculates cumulative probabilities for the simulations
	[ff,XIf] = ksdensity(Y(:,i),interval,'function','pdf');
	%calculates the absolute error in probability space
	fo=fo./sum(fo);
	ff=ff./sum(ff);
	Z(i)=sum(min(fo',ff'));
end

%function to calculate KS distance and pValue
function [pVal,kStat] = calcKS(X,Y,varargin)

[nX,nest]=size(X);
[nY,nest]=size(Y);
rtbv = 'full';
for i=1:2:length(varargin)
	switch lower(varargin{i}),
		case 'rtbv', rtbv=varargin{i+1};				
		otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
	end
end
X=sort(X);
Y=sort(Y);
switch lower(rtbv),
        case 'full'
			indX=[1:nX];indY=[1:nY];
        case 'pdf05'
            indX=[1:ceil(nX/5)];
            indY=[1:ceil(nY/5)];
        case 'pdf10'
            indX=[1:ceil(nX/10)];
            indY=[1:ceil(nY/10)];
        case 'pdf90'
            indX=[nX-floor(nX/10):nX];
            indY=[nY-floor(nY/10):nY];
        case 'pdf95'
            indX=[nX-floor(nX/5):nX];
            indY=[nY-floor(nY/5):nY];
		otherwise, warning(sprintf('Unknown range: %s (ignored)',rtbv));
end
X=X(indX,:);Y=Y(indY,:);
pVal=NaN*zeros(1,nest);
kStat=NaN*zeros(1,nest);
ind=find(~isnan(nanmean(X)) & ~isnan(nanmean(Y)));
for i=1:length(ind)
	[h,pVal(ind(i)),kStat(ind(i))]=kstest2(X(find(~isnan(X(:,ind(i)))),ind(i)),Y(find(~isnan(Y(:,ind(i)))),ind(i)));
end

%function to calculate Craner Von Mises distance and pValue
function [pVal,cmStat] = calcCM(X,Y,varargin)

[nX,nest]=size(X);[nY,nest]=size(Y);
rtbv = 'full';
for i=1:2:length(varargin)
	switch lower(varargin{i}),
		case 'rtbv', rtbv=varargin{i+1};				
		otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
	end
end
X=sort(X);Y=sort(Y);
switch lower(rtbv),
        case 'full'
			indX=[1:nX];indY=[1:nY];
        case 'pdf05'
            indX=[1:ceil(nX/5)];
            indY=[1:ceil(nY/5)];
        case 'pdf10'
            indX=[1:ceil(nX/10)];
            indY=[1:ceil(nY/10)];
        case 'pdf90'
            indX=[nX-floor(nX/10):nX];
            indY=[nY-floor(nY/10):nY];
        case 'pdf95'
            indX=[nX-floor(nX/5):nX];
            indY=[nY-floor(nY/5):nY];
		otherwise, warning(sprintf('Unknown range: %s (ignored)',rtbv));
end
X=X(indX,:);Y=Y(indY,:);
pVal=repmat(NaN,1,nest);cmStat=repmat(NaN,1,nest);
ind=find(~isnan(nanmean(X)) & ~isnan(nanmean(Y)));
for i=1:length(ind)
	[h,pVal(ind(i)),cmStat(ind(i))]=cmtest2(X(find(~isnan(X(:,ind(i)))),ind(i)),Y(find(~isnan(Y(:,ind(i)))),ind(i)));
end

%%%% QVSS %%%% 
function Z=qvss(X,Y,tau,varargin)
% calculates the (censored) quantile verification skill score for predicted series from quantile regression. The censored version is used for censored predicted precipitation series, but the calculation is the same.
% Input: - X = Observations
%		 - Y = Forecasts. X and Y must be vectors or matrices
% 		 - tau = percentile that has been predicted in the quantile regression [0-1].
[ndata,nest]=size(X);
Z=repmat(NaN,1,nest);
if nargin<2,
	error('too few p1arameters');
end
for i=1:2:length(varargin)
	switch lower(varargin{i}),
		case 'tau', tau=varargin{i+1};		
		otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
	end
end
for i=1:nest
	y=X(:,i);
	betaX=Y(:,i);
	% término de forecast
	u=y-betaX;
	for j=1:ndata
		if u(j)>0 | u(j)==0
			rho_for(j)=tau*u(j);
		else
			rho_for(j)=(1-tau)*u(j);
		end
	end
	qvs_for(i)=nansum(abs(rho_for'));
	% término de referencia
	obs_pct=prctile(y,tau*100);
	v=y-obs_pct;
	for j=1:ndata
		if v(j)>0 | v(j)==0
			rho_ref(j)=tau*v(j);
		else
			rho_ref(j)=(1-tau)*v(j);
		end
	end
	qvs_ref(i)=nansum(abs(rho_ref'));
	% quantile verification skill score
	Z(i)=1-(qvs_for(i)/qvs_ref(i));
end


%%%%Additional stuff%%%%

% %%%% MAEPCT %%%%
% function Z=maepct(X,Y,varargin);
% if nargin<2,
% 	error('too few parameters');
% end
% minimum = 1;
% step = 1;
% maximum = 99;
% draw=0;
% for i=1:2:length(varargin)
% 	switch lower(varargin{i}),
% 		case 'minimum', minimum=varargin{i+1};
% 		case 'maximum', maximum=varargin{i+1};
% 		case 'step', step=varargin{i+1};
% 		case 'draw', draw=varargin{i+1};
% 		otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
% 	end
% end
% 
% interval = [minimum:step:maximum];
% fPct = prctile(Y,interval);
% oPct = prctile(X,interval);
% maePct = nanmean(abs((fPct-oPct)));
% pctDiff = fPct-oPct;
% if draw
% 	surf(pctDiff);
% 	xlabel('Station'); ylabel('Percentile'); zlabel('Percentile error');
% end
% Z=maePct;
% 

% %%%% LEPS %%%%
% function [Z,ff,fo]=leps(X,Y,W,varargin);
% 
% [ndata,Nest] = size(X);
% censoring=false(ndata,1);
% kernel='normal';
% support='unbounded';
% weights=1/ndata;
% width=[];
% funct='cdf';
% b=[];draw=0;
% for i=1:2:length(varargin)
% 	switch lower(varargin{i}),
% 		case 'censoring', censoring=varargin{i+1};
% 		case 'draw', draw=varargin{i+1};
% 		case 'bins', b=varargin{i+1};
% 		case 'kernel', kernel=varargin{i+1};
% 		case 'support', support=varargin{i+1};
% 		case 'weights', weights=varargin{i+1};
% 		case 'width', width=varargin{i+1};
% 		case 'function', funct=varargin{i+1};
% 		otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
% 	end
% end
% Z=NaN*ones(1,Nest);
% 
% if length(W)==1
% 	W=W*ones(1,Nest);
% elseif length(W)<Nest
% 	error('W must be escalar or an 1xNest vector')
% end
% for i=1:Nest
% 	ind=find(~isnan(sum([X(:,i),Y(:,i)],2)));
% 	if ~isempty(ind) & ~isequal(X(ind,i),Y(ind,i))
% 		Z(i)=lepssub(X(ind,i),Y(ind,i),W(i),'bins',b,'censoring',censoring(ind),'kernel',kernel,'support',support,'weights',weights,'width',width,'function',funct);
% 	elseif isequal(X(ind,i),Y(ind,i))
% 		Z(i)=0;
% 	end
% end
% if draw
% 	cdfDiff = ff'-fo';
% 	surf(cdfDiff);
% 	xlabel('Station'); ylabel('Bin'); zlabel('Weighted error in probability space');
% end
% 
% function [leps,fo,ff,interval] = lepssub(o,f,w,varargin);
% ndata=length(f);
% censoring=false(ndata,1);
% kernel='normal';
% support='unbounded';
% weights=1/ndata;
% width=[];
% funct='cdf';
% b=[];
% for i=1:2:length(varargin)
% 	switch lower(varargin{i}),
% 		case 'bins', b=varargin{i+1};
% 		case 'censoring', censoring=varargin{i+1};
% 		case 'kernel', kernel=varargin{i+1};
% 		case 'support', support=varargin{i+1};
% 		case 'weights', weights=varargin{i+1};
% 		case 'width', width=varargin{i+1};
% 		case 'function', funct=varargin{i+1};
% 		otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
% 	end
% end


% maxo = nanmax(o);
% maxf = nanmax(f);
% maxval = max(maxo,maxf);
% mino = nanmin(o);
% minf = nanmin(f);
% minval = min(mino,minf);
% % defines the interval the kernel density estimates are calculated for
% interval=[minval:w:maxval];
% %Calculates cumulative probabilities for the observations
% [fo,XIo]=ksdensity(o,interval,'censoring',censoring,'kernel',kernel,'support',support,'weights',weights,'width',width,'function',funct);
% %Calculates cumulative probabilities for the simulations
% [ff,XIf]=ksdensity(f,interval,'censoring',censoring,'kernel',kernel,'support',support,'weights',weights,'width',width,'function',funct);
% %calculates the absolute error in probability space
% if ~isempty(b)
% 	h=(2*pi)/(b-1);
% 	int=[-pi:h:pi];
% 	weights=1./(cos(int)+1);
% 	fo=fo.*weights;
% 	ff=ff.*weights;
% end
% leps=mae(fo',ff');

