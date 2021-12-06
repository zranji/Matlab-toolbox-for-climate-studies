function [y,N] = nanmean(x,dim,w)
%NANMEAN Average or mean ignoring NaNs.
%   NANMEAN(X) returns the average treating NaNs as missing values.  
%   For vectors, NANMEAN(X) is the mean value of the non-NaN
%   elements in X.  For matrices, NANMEAN(X) is a row vector
%   containing the mean value of each column, ignoring NaNs.
%   NANMEAN(X,DIM) takes the mean along the dimension DIM of X, ignoring NaNs.
%   NANMEAN(X,DIM,W) takes the weighted mean along the dimension
%    DIM of X, ignoring NaNs.

if isempty(x) % Check for empty input.
    y = NaN+ones(size(x));
    N = zeros(size(x));
    return
end

if(nargin<2),dim=1;end
if(nargin<3),w=ones(size(x));end



%nans = isnan(x);
%i = find(nans);
i = find(isnan(x));
x(i) = zeros(size(i));

w(i) = zeros(size(i));
%N=sum(~nans,dim);
N=sum(w,dim);

i=find(N==0);
N(i)=1;
if nargin<3
    y=sum(x,dim)./N;
else
    y=sum(x.*w,dim)./N;
end
y(i)=NaN;
if nargout==2
	N(i)=0;   
end
