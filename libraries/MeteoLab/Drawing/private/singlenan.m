function [lat,lon] = singlenan(lat,lon)
% SINGLENAN removes duplicate nans in lat-long vectors

%  Copyright 1996-2002 Systems Planning and Analysis, Inc. and The MathWorks, Inc.
%  $Revision: 1.3 $ $Date: 2002/03/20 21:26:53 $

if ~isempty(lat)
    nanloc = isnan(lat);	[r,c] = size(nanloc);
    nanloc = find(nanloc(1:r-1,:) & nanloc(2:r,:));
    lat(nanloc) = [];  lon(nanloc) = [];
end
