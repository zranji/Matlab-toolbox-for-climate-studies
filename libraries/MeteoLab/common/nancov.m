function [c,n] = nancov(x,varargin)
%NANCOV cov function ignoring NaNs.
%s=varargin is the min. number of common observations 
%to generate a robust covariance
i=double(isnan(x));
x=x-repmat(nanmean(x,1),[size(x,1) 1]);
x(find(i))=0;
i=double(~i);
c=x'*x;
n=i'*i;
if isempty(varargin);s=1;else s=varargin{1};end
c(find(n<=s))=NaN;
c=c./(n-1);

