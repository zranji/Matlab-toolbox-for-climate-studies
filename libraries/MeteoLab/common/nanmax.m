function [xx,ix] = nanmax(x,dim)
%NANMAX max function ignoring NaNs.
%   NANMAX (X,DIM) takes the max along the dimension DIM of X, ignoring NaNs.

if isempty(x) % Check for empty input.
    xx = NaN;
    return
end

if(nargin<2),dim=1;end

iN = find(nansum(~isnan(x),dim)==0);
i = find(isnan(x));
x(i)=-Inf;
if nargout==1
   xx=max(x,[],dim);
   xx(iN)=NaN;
else
   [xx,ix]=max(x,[],dim);
   xx(iN)=NaN;
   ix(iN)=NaN;
end
   

