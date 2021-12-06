function [xn,in] = nanmin(x,dim)
%NANMIN min function ignoring NaNs.
%   NANMIN (X,DIM) takes the min along the dimension DIM of X, ignoring NaNs.

if isempty(x) % Check for empty input.
    xn = NaN;
    return
end

if(nargin<2),dim=1;end

iN = find(nansum(~isnan(x),dim)==0);
i = find(isnan(x));
x(i)=Inf;
if nargout==1
   xn=min(x,[],dim);
   xn(iN)=NaN;
else
   [xn,in]=min(x,[],dim);
   xn(iN)=NaN;
   in(iN)=NaN;
end

   

