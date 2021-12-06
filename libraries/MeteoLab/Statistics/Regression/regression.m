function [c, r2, res] = regression(y,X)
%Linear regression using least squares
%   c = regression(y,X) returns the vector coefficients: y = X b 
%   X is a nxm matrix, y is the nx1 vector of observations. 

[Q, R]=qr(X,0);
c = R\(Q'*y);

if nargout>=2,
    yhat = X*c;
    r2 = norm(yhat-nanmean(y))^2/norm(y-nanmean(y))^2;
    if nargout==3,
        res.mean=nanmean(yhat)-nanmean(y);
        res.std=nanstd(yhat-y);
    end
end

