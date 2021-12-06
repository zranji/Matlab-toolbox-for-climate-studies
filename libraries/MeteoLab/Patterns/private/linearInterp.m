function F=linearInterp(arg1,nrows,ncols,s,t,ndx,sout,tout)

F=NaN*zeros(1,length(ndx));
ind=find(isnan(arg1(ndx)));
if ~isempty(ind)
    warning([num2str(length(ind)) '(' num2str(100*length(ind)/prod(size(arg1))) '%) NaNs found in the data set: removed for interpolation.'])    
end
ind=setdiff([1:length(ndx)],ind);
ndx=ndx(ind);t=t(ind);s=s(ind);

% Now interpolate, reuse u and v to save memory.
F(ind) =  ( arg1(ndx).*(1-t) + arg1(ndx+1).*t ).*(1-s) + ...
    ( arg1(ndx+nrows).*(1-t) + arg1(ndx+(nrows+1)).*t ).*s;

% Now set out of range values to NaN.
if length(sout)>0, F(sout) = NaN; end
if length(tout)>0, F(tout) = NaN; end

