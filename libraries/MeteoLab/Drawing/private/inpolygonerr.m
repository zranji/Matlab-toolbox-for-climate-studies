function in = inpolygonerr(x,y,xv,yv,err)
%INPOLYGONERR evaluates inpolygon function taking into account floating
% point errors

%  Copyright 1996-2002 Systems Planning and Analysis, Inc. and The MathWorks, Inc.
%  $Revision: 1.4 $    $Date: 2002/03/20 21:26:46 $

% evaluate at 9 points: [nw,n,ne,w,c,e,sw,s,se]
in = .5*ones(size(x));
n = length(x);
x = repmat([x-err, x, x+err],1,3);
y = [repmat(y+err,1,3), repmat(y,1,3), repmat(y-err,1,3)];
inp = inpolygon(x,y,xv,yv);
in(all(inp'==1)') = 1;  % in
in(all(inp'==0)') = 0;  % out

% this works for single point
% x = zeros(3,3);  y = zeros(3,3);
% x(:,1) = xp - xp*err;  x(:,2) = xp;  x(:,3) = xp + xp*err;
% y(1,:) = yp + yp*err;  y(2,:) = yp;  y(3,:) = yp - yp*err;
% inp = inpolygon(x,y,xv,yv);
% if all(inp(:)==1)
% 	in = 1;
% elseif all(inp(:)==0)
% 	in = 0;
% else
% 	in = .5;
% end
