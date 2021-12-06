function [xi,yi] = ptserr(xi,yi,xa,ya,err)
% PTSERR removes floating point errors of xi and yi by setting them to
% x1 y1 values

%  Copyright 1996-2002 Systems Planning and Analysis, Inc. and The MathWorks, Inc.
%  $Revision: 1.4 $ $Date: 2002/03/20 21:26:52 $

ni = length(xi);  na = length(xa);
Xi = reshape(reshape(repmat(xi,na,1),ni,na)',ni*na,1);
Yi = reshape(reshape(repmat(yi,na,1),ni,na)',ni*na,1);
Xa = repmat(xa,ni,1);
Ya = repmat(ya,ni,1);
ix = find( (abs(Xi-Xa)>0 & abs(Xi-Xa)<=err) );
iy = find( (abs(Yi-Ya)>0 & abs(Yi-Ya)<=err) );
xi(ceil(ix/na)) = Xa(ix);
yi(ceil(iy/na)) = Ya(iy);
