function  D2 = mahal(obj,X,dose)
% MAHAL Mahalanobis distance from X to component means.
%    D2 = MAHAL(OBJ,X) returns the Mahalanobis distance (in squared units)
%    from points in X to the mean of each Gaussian component in OBJ. OBJ is
%    a GMDISTRIBUTION object. X is a N-by-D matrix. Rows of X correspond to
%    points, columns correspond to variables. D2(I,J) is the
%    Mahalanobis distance of point I from the mean of component J.
%
%    See also GMDISTRIBUTION, GMDISTRIBUTION/POSTERIOR,
%    GMDISTRIBUTION/CLUSTER.

%    Copyright 2007 The MathWorks, Inc.


% Check for valid input

narginchk(2,2);

checkdata(X,obj);

covNames = { 'diagonal','full'};
CovType = find(strncmpi(obj.CovType,covNames,length(obj.CovType)));
if isa(obj.mu, 'single') && ~isa(X,'single') && ~issparse(X)
    X = cast(X,'single');
end
[~,D2]=wdensity_dosedependent_notML(X,obj.mu, obj.Sigma, obj.PComponents, dose, obj.SharedCov, CovType);

