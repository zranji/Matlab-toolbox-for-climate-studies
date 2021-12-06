% STATM Compute statistics from 2 series
%
% STATM = allstats(Cr,Cf)
%
% Compute statistics from 2 series considering Cr as the reference.
% 
% Inputs:
%       Cr and Cf are of same length and uni-dimensional. They may contain NaNs.
%
% Outputs:
%       STATM(1,:) => Mean
%       STATM(2,:) => Standard Deviation (scaled by N)
%       STATM(3,:) => Centered Root Mean Square Difference (scaled by N)
%       STATM(4,:) => Correlation
%
% Notes:
%       - N is the number of points where BOTH Cr and Cf are defined
%
%       - NaN are handled in the following way: because this function
%               aims to compair 2 series, statistics are computed with indices
%               where both Cr and Cf are defined.
%
%       - STATM(:,1) are from Cr (ie with C=Cr hereafter)
%         STATM(:,2) are from Cf versus Cr (ie with C=Cf hereafter)
%
%       - The MEAN is computed using the Matlab mean function.
%
%       - The STANDARD DEVIATION is computed as:
%                                 /  sum[ {C-mean(C)} .^2]  \
%                       STD = sqrt|  ---------------------  |
%                                 \          N              /
%
%       - The CENTERED ROOT MEAN SQUARE DIFFERENCE is computed as:
%                                  /  sum[  { [C-mean(C)] - [Cr-mean(Cr)] }.^2  ]  \
%                       RMSD = sqrt|  -------------------------------------------  |
%                                  \                      N                        /
%
%       - The CORRELATION is computed as:
%                             sum( [C-mean(C)].*[Cr-mean(Cr)] ) 
%                       COR = --------------------------------- 
%                                     N*STD(C)*STD(Cr)
%
%       - STATM(3,1) = 0 and STATM(4,1) = 1 by definition !
%
% Created by Guillaume Maze on 2008-10-28.
% Rev. by Guillaume Maze on 2010-02-10: Add NaN values handling, some checking
%                               in the inputs and a more complete help
% Copyright (c) 2008 Guillaume Maze. 
% http://codes.guillaumemaze.org




%
% This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or any later version.
% This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
%

function stats=allstats(X,Y)
        
%%% Check size:
if size(X,1) ~= size(Y,1)
	error('X and Y must be of same length');
end
%%% Check NaNs:
[ndata,N]=size(Y);
stats=struct('mean',repmat(NaN,1,N+1),'std',repmat(NaN,1,N+1),'rmse',repmat(NaN,1,N+1),'rho',repmat(NaN,1,N+1));
%%% STD:
stats.std(1,1)=nanstd(X);
stats.std(1,2:end)=nanstd(Y);
%%% MEAN:
stats.mean(1,:)=nanmean(X);
stats.mean(1,2:end)=nanmean(Y);
%%% RMSD:
stats.rmse(1,:)=sqrt(nanmean(((X-stats.mean(1,1))-(X-stats.mean(1,1))).^2));
stats.rmse(1,2:end)=sqrt(nanmean(((Y-repmat(stats.mean(1,2:end),ndata,1))-repmat(X-stats.mean(1,1),1,N)).^2));
%%% CORRELATIONS:
stats.rho(1,1)=nancorrcoef(X);
for i=1:N
	aux=nancorrcoef([Y(:,i),X]);
	stats.rho(1,i+1)=aux(1,2);
end
