function [xpx,ypx] = cpxor(xp1,yp1,xp2,yp2)
%CPXOR  Complex polygon xor.
%   [XPX,YPX] = CPXOR(XP1,YP1,XP2,YP2) performs the polygon
%   xor operation for complex polygons.

%  Written by:  A. Kim
%  Copyright 1996-2002 Systems Planning and Analysis, Inc. and The MathWorks, Inc.
%  $Revision: 1.4 $    $Date: 2002/03/20 21:26:44 $

[xpu,ypu] = cpuni(xp1,yp1,xp2,yp2);
[xpi,ypi] = cpint(xp1,yp1,xp2,yp2);

[xpx,ypx] = cpsub(xpu,ypu,xpi,ypi);
