function [nrows,ncols,s,t,ndx,sout,tout] = linearInterpInit(arg1,arg2,arg3,arg4,arg5)
[nrows,ncols] = size(arg1);
mx = prod(size(arg1)); my = prod(size(arg2));
if any([mx my] ~= [ncols nrows]) & ...
        ~isequal(size(arg1),size(arg2),size(arg3))
    error('The lengths of the X and Y vectors must match Z.');
end
if any([nrows ncols]<[2 2]), error('Z must be at least 2-by-2.'); end
s = 1 + (arg4-arg1(1))/(arg1(mx)-arg1(1))*(ncols-1);
t = 1 + (arg5-arg2(1))/(arg2(my)-arg2(1))*(nrows-1);

if any([nrows ncols]<[2 2]), error('Z must be at least 2-by-2.'); end
if ~isequal(size(s),size(t)),
    error('XI and YI must be the same size.');
end

% Check for out of range values of s and set to 1
sout = find((s<1)|(s>ncols));
if length(sout)>0, s(sout) = ones(size(sout)); end

% Check for out of range values of t and set to 1
tout = find((t<1)|(t>nrows));
if length(tout)>0, t(tout) = ones(size(tout)); end

% Matrix element indexing
ndx = floor(t)+floor(s-1)*nrows;

% Compute intepolation parameters, check for boundary value.
if isempty(s), d = s; else d = find(s==ncols); end
s(:) = (s - floor(s));
if length(d)>0, s(d) = s(d)+1; ndx(d) = ndx(d)-nrows; end

% Compute intepolation parameters, check for boundary value.
if isempty(t), d = t; else d = find(t==nrows); end
t(:) = (t - floor(t));
if length(d)>0, t(d) = t(d)+1; ndx(d) = ndx(d)-1; end
d = [];
