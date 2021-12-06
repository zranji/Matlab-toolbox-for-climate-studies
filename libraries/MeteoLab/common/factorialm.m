function M = factorialm (M)
%FACTORIALM Factorial function for matrices.
%   F = FACTORIALM(M) returns the factorial for all positive integers of the matrix M.
%   So,F(i) is the product of all integers from 1 to M(i), i.e. prod(1:M(i)).
%   F has the same size as M. NaNs and Infs in M will yield NaNs in F.
%
%   From the help section of factorial:
%   "Since double precision numbers only have about 15 digits, the answer
%   is only accurate for N <= 21. For larger N, the answer will have the
%   right magnitude, and is accurate for the first 15 digits."
%
%   Example:
%     factorialm([1 6 0 ; NaN  4 -Inf])
%        will return :    1   720     1
%                       NaN    24   NaN
%
%   See also FACTORIAL, PROD, CUMPROD, PERMS, NCHOOSEK
%   and COMBN on the File Exchange.

% Written and tested in Matlab R13
% version 1.0 (jan 2007)
% (c) Jos van der Geest
% email: jos@jasen.nl

% History
% 1.0 (jan 2007). This file was inspired by a post on CSSM in jan 2007.


% check for NaNs, Infs and zeros. These are not flagged as an error, but
% are simply returned.
q = ~(isnan(M(:)) | isinf(M(:))) ;

M(M==0) = 1 ;

if any(q) 
    % Only give an error for negative or non-integer entries
    if (any(M(q) < 0) || any(fix(M(q)) ~= M(q))) 
        error('MATLAB:factorial:MNotPositiveInteger', ...
            'Factorial is only defined for non-negative integers.');
    end
    F = cumprod(1:max(M(q))) ;
    M(q) = F(M(q)) ;
end

M(~q) = NaN ;


