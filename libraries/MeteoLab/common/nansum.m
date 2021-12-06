function [y,N] = nansum(x,dim,w)
%NANSUM sum ignoring NaNs.
%   NANSUM(X) returns the sum treating NaNs as missing values.  
%   For vectors, NANSUM(X) is the sum value of the non-NaN
%   elements in X.  For matrices, NANSUM(X) is a row vector
%   containing the sum value of each column, ignoring NaNs.
%   NANSUM(X,DIM) takes the sum along the dimension DIM of X, ignoring NaNs.
%   NANSUM(X,DIM,W) takes the weighted sum along the dimension
%    DIM of X, ignoring NaNs.

if isempty(x) % Check for empty input.
    y = NaN;
    return
end

if(nargin<2),dim=1;end
if(nargin<3),w=ones(size(x));end

i = find(isnan(x));
x(i) = zeros(size(i));

w(i) = zeros(size(i));
N=sum(w,dim);

i=find(N==0);
N(i)=1;
y=sum(x.*w,dim);
y(i)=NaN;
if nargout==2
	N(i)=0;   
end
