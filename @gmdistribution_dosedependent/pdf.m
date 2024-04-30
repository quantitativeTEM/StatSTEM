function y=pdf(obj,X,dose)
% PDF PDF for a Gaussian mixture distribution.
%    Y = PDF(OBJ,X) returns Y, a vector of length N containing the
%    probability density function (PDF) for the gmdistribution OBJ,
%    evaluated at the N-by-D data matrix X. Rows of X correspond to points,
%    columns correspond to variables. Y(I) is the PDF value of point I.
%
%    See also GMDISTRIBUTION, GMDISTRIBUTION/CDF.

%   Copyright 2007 The MathWorks, Inc.


% Check for valid input

narginchk(2,2);
checkdata(X,obj);

covNames = { 'diagonal','full'};
CovType = find(strncmpi(obj.CovType,covNames,length(obj.CovType)));
if isa(obj.mu, 'single') && ~isa(X,'single')&& ~issparse(X)
    X = cast(X,'single');
end
log_lh = wdensity_dosedependent_notML(X,obj.mu, obj.Sigma, obj.PComponents, dose, obj.SharedCov, CovType);
y =  sum(exp(log_lh),2);
