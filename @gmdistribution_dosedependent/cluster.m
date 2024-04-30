function [idx,NlogL,post,logpdf,mahalaD]=cluster(obj,X,dose)
%GMDISTRIBUTION/CLUSTER Cluster data for Gaussian mixture distribution.
%   IDX = CLUSTER(OBJ,X) partitions the points in the N-by-D data matrix X
%   into K clusters determined by the K components of the Gaussian mixture
%   distribution defined by OBJ. In the matrix X, Rows of X correspond to
%   points, columns correspond to variables. CLUSTER returns an N-by-1
%   vector IDX containing the cluster index of each point. The cluster
%   index refers to the component giving the largest posterior probability
%   for the point.
%
%   CLUSTER treats NaNs as missing data. Rows of X with NaNs are
%   excluded from the partition.
%
%   [IDX,NLOGL] = CLUSTER(OBJ,X) returns NLOGL, the negative of the
%   log-likelihood of the X.
%
%   [IDX,NLOGL,POST] = CLUSTER(OBJ,X) returns POST, a matrix containing the
%   posterior probability of each point for each component. POST(I,J) is
%   the posterior probability of point I belonging to component J, i.e.,
%   Pr{component J | point I}. 
%
%   [IDX,NLOGL,POST,LOGPDF] = CLUSTER(OBJ,X) returns LOGPDF, a vector of
%   length N containing estimates of the logs of probability density
%   function (PDF). LOGPDF(I) is the log of the PDF of point I. The PDF
%   value of point I is the sum of p(point I | component J)*Pr{component J}
%   taken over all components, where p() is the multivariate normal pdf. 
%
%   [IDX,NLOGL,POST,LOGPDF,MAHALAD] = CLUSTER(OBJ,X) returns MAHALAD, a
%   N-by-K matrix containing the Mahalanobis distance in squared units.
%   MAHALAD(I,J) is the Mahalanobis distance of point I from the mean of
%   component J.
%
%   See also FITGMDIST, GMDISTRIBUTION.

%   Copyright 2007-2013 The MathWorks, Inc.


% Check for valid input

narginchk(2,2);
checkdata(X,obj);

%remove NaNs
wasnan=any(isnan(X),2);
hadNaNs=any(wasnan);
if hadNaNs
    warning(message('stats:gmdistribution:cluster:MissingData'));
    X = X( ~ wasnan,:);
end

covNames = { 'diagonal','full'};
CovType = find(strncmpi(obj.CovType,covNames,length(obj.CovType)));
if isa(obj.mu, 'single') && ~isa(X,'single') && ~issparse(X)
    X = cast(X,'single');
end
if nargout > 4
  [log_lh, mahalaD]=wdensity_dosedependent_notML(X,obj.mu, obj.Sigma, obj.PComponents, dose, obj.SharedCov, CovType);
else
  log_lh=wdensity_dosedependent_notML(X,obj.mu, obj.Sigma, obj.PComponents, dose, obj.SharedCov, CovType); 
end
[ll, post,logpdf] = estep_dosedependent_notML(log_lh);
[~,idx] = max (post,[],2);
NlogL=-ll;

if hadNaNs
    if nargout < 3 % Only idx and NlogL are requested
       idx = dfswitchyard('statinsertnan',wasnan,idx);
    elseif nargout < 4 %Only idx, NlogL and post are requested
       [idx,post] = dfswitchyard('statinsertnan',wasnan,idx,post);
    elseif nargout < 5 % idx,NlogL,post,logpdf are requested
       [idx,post,logpdf] = dfswitchyard('statinsertnan',wasnan,idx,post, logpdf);
    else %all are requested
       [idx,post,logpdf,mahalaD] = dfswitchyard('statinsertnan',wasnan,idx,post,logpdf,mahalaD);
    end
end

