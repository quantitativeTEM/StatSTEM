function [post, NlogL] = posterior(obj,X,dose)
% POSTERIOR Posterior probability of components given data.
%    POST = POSTERIOR(OBJ,X) returns POST, a matrix containing
%    estimates of the posterior probability of the components in
%    gmdistribution OBJ given points in X. X is an N-by-D data matrix. Rows
%    of X correspond to points, columns correspond to variables. POST(I,J)
%    is the posterior probability of point I belonging to component J,
%    i.e., Pr{Component J | point I}. 
%
%    POSTERIOR treats NaNs as missing data. Rows of X with NaNs are
%    excluded from the computation.
%
%    [POST,NLOGL] = POSTERIOR(OBJ,X) returns NLOGL, the negative likelihood
%    of the data X given the model contained in OBJ.
%
%    See also GMDISTRIBUTION/CLUSTER, GMDISTRIBUTION/MAHAL,.

%    Copyright 2007 The MathWorks, Inc.


% Check for valid input

narginchk(2,2);
checkdata(X,obj);

%remove NaNs
wasnan=any(isnan(X),2);
hadNaNs=any(wasnan);
if hadNaNs
    warning(message('stats:gmdistribution:posterior:MissingData'));
    X = X( ~ wasnan,:);
end

covNames = { 'diagonal','full'};
CovType = find(strncmpi(obj.CovType,covNames,length(obj.CovType)));
if isa(obj.mu, 'single') && ~isa(X,'single') && ~issparse(X)
    X = cast(X,'single');
end

log_lh = wdensity_dosedepentent_notML(X,obj.mu, obj.Sigma, obj.PComponents, dose, obj.SharedCov, CovType);
[ll, post] = estep_dosedependent_notML(log_lh);

NlogL=-ll;

if hadNaNs
    post= dfswitchyard('statinsertnan',wasnan,post);

end
