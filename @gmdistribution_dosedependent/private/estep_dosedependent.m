function  [ll, post, logpdf]=estep_dosedependent(log_lh,prob_th)
%ESTEP E-STEP for Gaussian mixture distribution
%   LL = ESTEP(LOG_LH) returns the loglikelihood of data in LL.  LOG_LH
%   is the log of component conditional density weighted by the component
%   probability.
%
%   [LL, POST] = ESTEP(LOG_LH) returns the posterior probability in the
%   matrix POST. POST(i,j) is the posterior  probability of point i
%   belonging to cluster j. 
%
%   [LL, POST] = ESTEP(LOG_LH,PROB_TH) set the probablities that is smaller
%   than PROB_TH to zero.
%
%   [LL, POST, DENSITY] = ESTEP(LOG_LH) returns the logs of the pdf values
%   of data in the vector density.
%
%   Copyright 2007-2016 The MathWorks, Inc.

maxll = max(log_lh,[],2);
%minus maxll to avoid underflow
post = exp(log_lh-maxll);
%density(i) is \sum_j \alpha_j P(x_i| \theta_j)/ exp(maxll(i))
density = sum(post,2);
logpdf = log(density) + maxll;
ll = sum(logpdf); 
post = post./density;%normalize posteriors

%Set small posteriors to zero for efficiency
%Currently, the following steps are only performed in the fitting phase
if nargin > 1
    post(post<(prob_th))=0;
    density = sum(post,2);
    post = post./density;%renormalize posteriors
end
