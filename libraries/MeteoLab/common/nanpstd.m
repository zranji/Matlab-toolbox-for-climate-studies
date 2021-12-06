function [z,mn,dv] = nanpstd(d)
%PSTD Standadized z score.
%   [Z MN DV] = PSTD(D) returns the deviation of each column of D from its mean, MN, 
%   normalized by its standard deviation, DV. This is known as the Z score of D.
%   For a column vector V, z score is Z = (V-MN)./DV
%
%   PSTD is commonly used to preprocess data before computing distances for 
%   cluster analysis.
[m,n] = size(d);

if m == 1
   m = n;
   d = d';
end
mn=nanmean(d);
dv=nanstd(d);
md = repmat(mn,m,1);
sd = repmat(dv,m,1);
sd(sd==0) = 1; % all the numerator will be zero in such case.

z = (d-md)./sd;

