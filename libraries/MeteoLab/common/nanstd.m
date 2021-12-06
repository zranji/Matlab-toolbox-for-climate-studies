function [y] = nanstd(x,dim)
%NANSTD Standard deviation ignoring NaNs.
%   NANSTD(X,DIM) takes the standard deviation along the dimension DIM of X,
%     ignoring NaNs.
if(nargin<2),dim=1;end

y=sqrt(nanmean(x.^2,dim)-nanmean(x,dim).^2);
