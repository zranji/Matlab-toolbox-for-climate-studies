function h=myPcolor(varargin)
% plot the matrix M from up to down and from left to right
% surface((1:size(M,2)+1)-0.5,(1:size(M,1)+1)-0.5,zeros(size(M)+1),flipud(M),'FaceColor','texturemap');
%  surface((1:size(M,2)+1)-0.5,(1:size(M,1)+1)-0.5,zeros(size(M)+1),M,'FaceColor','texturemap');

% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});
error(nargchk(1,3,nargs,'struct'))

% do error checking before calling newplot. This argument checking should
% match the surface(x,y,z) or surface(z) argument checking.
if nargs == 2
  error(id('InvalidNumberOfInputs'),...
        'Must have one or three input data arguments.')
end
if isvector(args{end})
  error(id('NonMatrixColorInput'),'Color data input must be a matrix.');
end
if nargs == 3 && LdimMismatch(args{1:3})
  error(id('InputSizeMismatch'),'Matrix dimensions must agree.');
end
for k = 1:nargs
  if ~isreal(args{k})
    error(id('NonRealInputs'),'Data inputs must be real.');
  end
end

cax = newplot(cax);
hold_state = ishold(cax);

if nargs == 1
    x = args{1};x=[[flipud(x) repmat(NaN,size(x,1),1)];repmat(NaN,1,size(x,2)+1)];
    hh = surface(zeros(size(x)),x,'parent',cax);
    [m,n] = size(x);
    lims = [ 1 n 1 m];
elseif nargs == 3
    [x,y,c] = deal(args{1:3});
    if isvector(x) & isvector(y)
        x=[x(:);NaN];x(end)=2*x(end-1)-x(end-2);
        y=[y(:);NaN];y(end)=2*y(end-1)-y(end-2);
    elseif isvector(x)
        x=[x(:);NaN];x(end)=2*x(end-1)-x(end-2);
        y=[[y repmat(NaN,size(y,1),1)];repmat(NaN,1,size(y,2)+1)];
        y(end,:)=2*y(end-1,:)-y(end-2,:);y(:,end)=2*y(:,end-1)-y(:,end-2);
    elseif isvector(y)
        y=[y(:);NaN];y(end)=2*y(end-1)-y(end-2);
        x=[[x repmat(NaN,size(x,1),1)];repmat(NaN,1,size(x,2)+1)];
        x(end,:)=2*x(end-1,:)-x(end-2,:);x(:,end)=2*x(:,end-1)-x(:,end-2);
    else
        x=[[x repmat(NaN,size(x,1),1)];repmat(NaN,1,size(x,2)+1)];
        x(end,:)=2*x(end-1,:)-x(end-2,:);x(:,end)=2*x(:,end-1)-x(:,end-2);
        y=[[y repmat(NaN,size(y,1),1)];repmat(NaN,1,size(y,2)+1)];
        y(end,:)=2*y(end-1,:)-y(end-2,:);y(:,end)=2*y(:,end-1)-y(:,end-2);
    end
    c=[[flipud(c) repmat(NaN,size(c,1),1)];repmat(NaN,1,size(c,2)+1)];
    hh = surface(x,y,zeros(size(c)),c,'parent',cax);
    lims = [min(min(x)) max(max(x)) min(min(y)) max(max(y))];
end
if ~hold_state
    set(cax,'View',[0 90]);
    set(cax,'Box','on');
    axis(cax,lims);
end
if nargout == 1
    h = hh;
end

function ok = LdimMismatch(x,y,z)
[xm,xn] = size(x);
[ym,yn] = size(y);
[zm,zn] = size(z);
ok = (xm == 1 && xn ~= zn) || ...
     (xn == 1 && xm ~= zn) || ...
     (xm ~= 1 && xn ~= 1 && (xm ~= zm || xn ~= zn)) || ...
     (ym == 1 && yn ~= zm) || ...
     (yn == 1 && ym ~= zm) || ...
     (ym ~= 1 && yn ~= 1 && (ym ~= zm || yn ~= zn));

function str = id(str)
str = ['MATLAB:pcolor:' str];

