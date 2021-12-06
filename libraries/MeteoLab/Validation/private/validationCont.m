function struct=validationCont(X,Y,score,varargin)
% This function calculates accuracy measures like the bias {'bias'},
% root mean square error {'rmse'} and mean absolute error {'mae'}.
% To compare the validation results of different stations and/or seasons of
% the year they can optionally be scaled by the Mean Absolute Deviation
% (MatLabs´s function mad.m) of the observations.
%
% In addition, to validate the forecasted climatology, the following
% validation measures are computed:
% -linear error in probability space {'leps'}
% -weighted leps for validating the forecast of extreme/rare
%  events {'lepsext'}: more weight is given to erroneously forcasted
%  rare events.
%   
%  IMPORTANT NOTE:
%  THE WEIGHTS ONLY MAKE SENSE IF A NORMALLY DISTRIBUTED VARIABLE IS
%  VALIDATED. AN UPDATE FOR DAILY PRECIPITATION AND WIND SPEED
%  HAS TO BE DONE IN FUTURE WOKRK.
%
% -mae of the percentiles can be calculated {'maepct'}.
%
% Input:
	% - X: ndata*Nest matrix with the observations. Timesteps along the columns and stations along the rows.
	% - Y: ndata*Nest matrix with the forecasts. This matrix must have the same size that X.
    % - b: number of bin centers the density smoothing is calculated for
        %  when calculating the leps or the lepsext.
	% - score:a cell with the name of the scores, {'bias';'rmse';'mae';'leps';'lepsext';'maepct';'prs'}. To calculate the bias and the rmse {'bias';'rmse'}.
	% - Optional parameters:
		% - scale: {0} or 1. This parameter reescales the station's score with its mean absolute deviation (mad) 
			% respect	the {mean} or median.
		% - flag:  {0} to reescale with the mad respect the mean or 1 to reescale with the mad respect the median.
		% - binswidth: 1*1 or Nest*1 vector with the width of bins.
		% - censoring: A logical vector of the same length of X, indicating which entries are censoring times (default is no censoring).
		% - kernel: The type of kernel smoother to use, chosen from among {'normal'}, 'box', 'triangle' and 'epanechnikov'.
        % - support: Either {'unbounded'} if the density can extend over the whole real line, or 'positive' to restrict it to positive 
			% values, or a two-element vector giving finite lower and upper limits for the support of the density.
		% - weights: Vector of the same length as X, giving the weight to assign to each X value (default is equal weights).
		% - width: The bandwidth of the kernel smoothing window.  The default is optimal for estimating normal densities, but you may 
			% want to choose a smaller value to reveal features such as multiple modes.
		% - function: The function type to estimate, chosen from among 'pdf', {'cdf'}, 'icdf', 'survivor', or 'cumhazard' for the density,
			% cumulative probability, inverse cumulative probability, survivor, or cumulative hazard functions, respectively.
% Output:
	% - struct: string of structures with the same size of the input score. Each structure contains two fields:
		% - scoreName: the score's name.
		% - ScoreValue: 1*Nest matrix with the value of the score. 
%Example:
%X=rand(1000,10)
%Y=rand(1000,10)
%[struct]=validationCont(X,Y,{'lepsext'},'bins',100); 

[ndata,Nest]=size(X);
scale=0;
b=[];
W=[];
flag=0;
censoring=false(ndata,1);
kernel='normal';
support='unbounded';
weights=1/ndata;
width=[];
funct='cdf';
minimum = 1;
step = 1;
maximum = 99;
draw=0;

for i=1:2:length(varargin)
	switch lower(varargin{i}),
		case 'scale', scale=varargin{i+1};
		case 'bins', b=varargin{i+1};
		case 'binswidth', W=varargin{i+1};
		case 'flag', flag=varargin{i+1};
		case 'censoring', censoring=varargin{i+1};
		case 'kernel', kernel=varargin{i+1};
		case 'support', support=varargin{i+1};
		case 'weights', weights=varargin{i+1};
		case 'width', width=varargin{i+1};
		case 'function', funct=varargin{i+1};
		case 'minimum', minimum=varargin{i+1};
		case 'maximum', maximum=varargin{i+1};
		case 'step', step=varargin{i+1};
		case 'draw', draw=varargin{i+1};
		otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
	end
end

if nargin<3,
	error('too few parameters');
end
if isempty(b)
	b=200;
end
if isempty(W)
    W=(max([nanmax(X);nanmax(Y)])-min([nanmin(X);nanmin(Y)]))/(b-1);
% 	W=(max([max(X);max(Y)])-min([min(X);min(Y)]))/(b-1);
end,
for i=1:length(score)
	disp(score{i})
	struct(i).scoreName=score{i};
	switch lower(score{i}),
		case 'mae',
			Z=mae(X,Y,'scale',scale,'flag',flag);
		case 'leps',
			Z=leps(X,Y,W,'censoring',censoring,'kernel',kernel,'support',support,'weights',weights,'width',width,'function',funct);
		case 'lepsext',
			Z=leps(X,Y,W,'bins',b,'censoring',censoring,'kernel',kernel,'support',support,'weights',weights,'width',width,'function',funct);
		case 'bias',
			Z=bias(X,Y,'scale',scale,'flag',flag);
		case 'sigbias',
			Z=sigbias(X,Y);
		case 'rmse',
			Z=rmse(X,Y,'scale',scale,'flag',flag);
        case 'maepct',
            Z=maepct(X,Y,'minimum',minimum,'maximum',maximum,'step',step,'draw',draw);  
		case 'mad',
			Z=mad(X,flag);
		case 'prs',
			Z=prs(X,Y,b,'draw',draw);
		otherwise, warning(sprintf('Unknown accuracy score: %s (ignored)',score{i}));
	end
	struct(i).ScoreValue=Z;
end

%%%% MAEPCT %%%%
function Z=maepct(X,Y,varargin);
if nargin<2,
	error('too few parameters');
end
minimum = 1;
step = 1;
maximum = 99;
draw=0;
for i=1:2:length(varargin)
	switch lower(varargin{i}),
		case 'minimum', minimum=varargin{i+1};
		case 'maximum', maximum=varargin{i+1};
		case 'step', step=varargin{i+1};
		case 'draw', draw=varargin{i+1};
		otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
	end
end

interval = [minimum:step:maximum];
fPct = prctile(Y,interval);
oPct = prctile(X,interval);
maePct = nanmean(abs((fPct-oPct)));
pctDiff = fPct-oPct;
if draw
	surf(pctDiff);
	xlabel('Station'); ylabel('Percentile'); zlabel('Percentile error');
end
Z=maePct;

%%%% MAE %%%%
function Z=mae(X,Y,varargin)
scale=0;
flag=0;
for i=1:2:length(varargin)
	switch lower(varargin{i}),
		case 'scale', scale=varargin{i+1};
		case 'flag', flag=varargin{i+1};
		otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
	end
end
switch scale
	case {0,'no','noscale'}
		Z=nanmean(abs(Y-X));
	case {1,'yes','scale'}
		Z=nanmean(abs(Y-X))./mad(X,flag);
end

%%%% LEPS %%%%
function [Z,ff,fo]=leps(X,Y,W,varargin);

[ndata,Nest] = size(X);
censoring=false(ndata,1);
kernel='normal';
support='unbounded';
weights=1/ndata;
width=[];
funct='cdf';
b=[];draw=0;
for i=1:2:length(varargin)
	switch lower(varargin{i}),
		case 'censoring', censoring=varargin{i+1};
		case 'draw', draw=varargin{i+1};
		case 'bins', b=varargin{i+1};
		case 'kernel', kernel=varargin{i+1};
		case 'support', support=varargin{i+1};
		case 'weights', weights=varargin{i+1};
		case 'width', width=varargin{i+1};
		case 'function', funct=varargin{i+1};
		otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
	end
end
Z=NaN*ones(1,Nest);

if length(W)==1
	W=W*ones(1,Nest);
elseif length(W)<Nest
	error('W must be escalar or an 1xNest vector')
end
for i=1:Nest
	ind=find(~isnan(sum([X(:,i),Y(:,i)],2)));
	if ~isempty(ind) & ~isequal(X(ind,i),Y(ind,i))
		Z(i)=lepssub(X(ind,i),Y(ind,i),W(i),'bins',b,'censoring',censoring(ind),'kernel',kernel,'support',support,'weights',weights,'width',width,'function',funct);
	elseif isequal(X(ind,i),Y(ind,i))
		Z(i)=0;
	end
end
if draw
	cdfDiff = ff'-fo';
	surf(cdfDiff);
	xlabel('Station'); ylabel('Bin'); zlabel('Weighted error in probability space');
end

function [leps,fo,ff,interval] = lepssub(o,f,w,varargin);
ndata=length(f);
censoring=false(ndata,1);
kernel='normal';
support='unbounded';
weights=1/ndata;
width=[];
funct='cdf';
b=[];
for i=1:2:length(varargin)
	switch lower(varargin{i}),
		case 'bins', b=varargin{i+1};
		case 'censoring', censoring=varargin{i+1};
		case 'kernel', kernel=varargin{i+1};
		case 'support', support=varargin{i+1};
		case 'weights', weights=varargin{i+1};
		case 'width', width=varargin{i+1};
		case 'function', funct=varargin{i+1};
		otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
	end
end
maxo = nanmax(o);
maxf = nanmax(f);
maxval = max(maxo,maxf);
mino = nanmin(o);
minf = nanmin(f);
minval = min(mino,minf);
% defines the interval the kernel density estimates are calculated for
interval=[minval:w:maxval];
%Calculates cumulative probabilities for the observations
[fo,XIo]=ksdensity(o,interval,'censoring',censoring,'kernel',kernel,'support',support,'weights',weights,'width',width,'function',funct);
%Calculates cumulative probabilities for the simulations
[ff,XIf]=ksdensity(f,interval,'censoring',censoring,'kernel',kernel,'support',support,'weights',weights,'width',width,'function',funct);
%calculates the absolute error in probability space
if ~isempty(b)
	h=(2*pi)/(b-1);
	int=[-pi:h:pi];
	weights=1./(cos(int)+1);
	fo=fo.*weights;
	ff=ff.*weights;
end
leps=mae(fo',ff');

%%%% BIAS %%%%
function Z=bias(X,Y,varargin)
if nargin<2,
	error('too few p1arameters');
end
scale=0;
flag=0;
for i=1:2:length(varargin)
	switch lower(varargin{i}),
		case 'scale', scale=varargin{i+1};
		case 'flag', flag=varargin{i+1};
		otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
	end
end
switch scale
	case {0,'no','noscale'}
		Z=nanmean(Y-X);
	case {1,'yes','scale'}
		Z=nanmean(Y-X)./mad(X,flag);
end

%%%% SIGBIAS %%%%

function [z] = sigbias(X,Y);

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
z=abs(diffmean./sqrt(vareff));

%%%% RMSE %%%%
function Z=rmse(X,Y,varargin)
if nargin<2,
	error('too few p1arameters');
end
scale=0;
flag=0;
for i=1:2:length(varargin)
	switch lower(varargin{i}),
		case 'scale', scale=varargin{i+1};
		case 'flag', flag=varargin{i+1};
		otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
	end
end
switch scale
	case {0,'no','noscale'}
		Z=sqrt(nanmean((Y-X).^2));
	case {1,'yes','scale'}
		Z=sqrt(nanmean((Y-X).^2))./mad(X,flag);
end

function Z=prs(X,Y,b,varargin)
% Calculates the PRS score
% Input: - X = Observations
%		 - Y = Forecasts. X and Y must be vectors or matrix
% 		 - b = number of bins, 
% only works with its corresponding subfunction <prssub.m>
% default values: b = 200
%
%set default
draw=0;
for i=1:2:length(varargin)
	switch lower(varargin{i}),
		case 'draw', draw=varargin{i+1};
		otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
	end
end
[ndata,Nest]=size(X);
Z=NaN*zeros(Nest,1);
for i=1:Nest
	try
		Z(i,1)=prssub(X(:,i),Y(:,i),b);
	catch
		disp('only NaNs in that column, prs is set to NaN');
	end
end

function Z=prssub(X,Y,b)
% subfunction of prs
% Calculates the Perkins reliability score for vectors:
% Input: - X = Observations
%		 - Y = Forecasts. X and Y must be vectors
% 		 - b = number of bins, 
% 
maxo=max(X);
maxf=max(Y);
maxval=max(maxo,maxf);
mino=min(X);
minf=min(Y);
minval=min(mino,minf);
% defines the interval the kernel density estimates are calculated for
w=(maxval-minval)/(b-1);
interval=minval:w:maxval;
%Calculates cumulative probabilities for the observations
[fo,XIo] = ksdensity(X,interval,'function','pdf');
%Calculates cumulative probabilities for the simulations
[ff,XIf] = ksdensity(Y,interval,'function','pdf');
%calculates the absolute error in probability space
fo=fo./sum(fo);
ff=ff./sum(ff);
Z=sum(min(fo',ff'));

function [density,bins]=pdfplot(data,w)
%set default
if nargin == 1
  w = 200;
%    wg = ones(length(data),1);
end
% if nargin == 2
%    wg = ones(length(data),1);
% end
% data = [data wg];
% data = exciserows(data);
% minval = min(data(:,1));
% maxval = max(data(:,1));
minval = min(data);
maxval = max(data);
w = (maxval - minval)./(w-1);
interval = [minval:w:maxval];
[density,bins] = ksdensity(data,interval);
% [density,bins] = ksdensity(data(:,1),interval);  %plot(bins,density,'linewidth',2);

