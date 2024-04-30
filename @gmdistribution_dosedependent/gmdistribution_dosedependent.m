classdef gmdistribution_dosedependent < classreg.learning.internal.DisallowVectorOps
%GMDISTRIBUTION Gaussian mixture distribution class.
%   An object of the GMDISTRIBUTION class defines a Gaussian mixture
%   distribution, which is a multivariate distribution that consists of a
%   mixture of one or more multivariate Gaussian distribution components.  The
%   number of components for a given GMDISTRIBUTION object is fixed.  Each
%   multivariate Gaussian component is defined by its mean and covariance, and
%   the mixture is defined by a vector of mixing proportions.
%
%   To create a Gaussian mixture distribution by specifying the
%   distribution parameters, use the GMDISTRIBUTION constructor. To fit a
%   Gaussian mixture distribution model to data, use FITGMDIST.
%
%   GMDISTRIBUTION properties:
%   A Gaussian mixture distribution with K components, in D dimensions, has
%   the following properties:
%      NumVariables          - Number of variables(dimensions).
%      DistributionName      - Name of the distribution.
%      NumComponents         - Number of mixture components.
%      ComponentProportion   - Mixing proportion of each component.
%      CovarianceType        - Type of the component covariance matrices.
%      SharedCovariance      - A logical indicating whether all the component covariance are the same.
%      mu                    - Matrix of component means.
%      Sigma                 - Component covariance
%
%   A Gaussian mixture distribution object created by fitting to data using
%   FITGMDIST also has the following properties:
%      NegativeLogLikelihood   - Negative of the log-likelihood value.
%      AIC                     - Akaike information criterion value.
%      BIC                     - The Bayes information criterion value.            
%      Converged               - Whether the algorithm is converged. 
%      ProbabilityTolerance    - The probability tolerance
%      NumIterations           - Number of iterations.
%      RegularizationValue     - Regularization value.
%
%   GMDISTRIBUTION methods:
%      cdf            - CDF for the Gaussian mixture distribution.
%      cluster        - Cluster data for Gaussian mixture distribution.
%      mahal          - Mahalanobis distance to component means.
%      gmdistribution - Create a Gaussian mixture model.
%      pdf            - PDF for Gaussian mixture distribution.
%      posterior	  - Posterior probabilities of components.
%      random         - Random numbers from Gaussian mixture distribution
%
%
%   See also FITGMDIST

%   Reference:   McLachlan, G., and D. Peel, Finite Mixture Models, John
%                Wiley & Sons, New York, 2000.

%   Copyright 2007-2013 The MathWorks, Inc.

 properties(GetAccess=public, SetAccess=protected, Hidden =true)
      NDimensions = 0; 
       DistName = 'gaussian mixture distribution';
       NComponents = 0;  % number of mixture components
       PComponents = zeros(0,1); % NComponents-by-1 vector of proportions
       SharedCov = [];
       Iters = [];       % The number of iterations
       RegV = 0;
       NlogL=[];         % Negative log-likelihood
       CovType = [];
 end
 
 
 properties(GetAccess=public, SetAccess=protected, Dependent=true)
%NumVariables Number of variables.
%   The NumVariables property specifies the number of features for each of
%   the multivariate Gaussian components in the mixture distribution.
%
%   See also GMDISTRIBUTION.
     NumVariables
   
%DistributionName Name of the distribution.
%   The DistributionName property specifies the name of the distribution
%   'gaussian mixture distribution'.
%
%   See also GMDISTRIBUTION.
        DistributionName
         
%NumComponents  Number of mixture components
%   The NumComponents property specifies the number of mixture components.
%
%   See also GMDISTRIBUTION.
       NumComponents
       
%ComponentProportion The mixing proportion of each component.
%The ComponentProportion property is a vector containing the mixing
%proportion of each component.
%
%   See also GMDISTRIBUTION.
    ComponentProportion
    
%SharedCovariance Whether all the component covariance are the same.
%   The SharedCovariance property is true if all the component covariance
%   matrices are restricted to be the same (pooled covariance); false
%   otherwise.
%
%   See also GMDISTRIBUTION.
    SharedCovariance
    
%NumIterations Number of iterations.  
%   The NumIterations property is an integer indicating the The number of
%   iterations taken by the fitting algorithm.
%
%   See also GMDISTRIBUTION.
     NumIterations
     
%RegularizationValue Regularization value
%   The RegularizationValue property is the value supplied for the
%   'RegularizationValue' input parameter for FITGMDIST.
 RegularizationValue
 
% Negative of the log-likelihood value.  
%   The NegativeLogLikelihood property contains the negative of the
%   log-likelihood of the fit.
%
%   See also GMDISTRIBUTION.
NegativeLogLikelihood

%CovarianceType Type of the covariance matrices.
%   The CovarianceType property is a string 'diagonal' if the component
%   covariance matrices are restricted to be diagonal; 'full' otherwise.
%
%   See also GMDISTRIBUTION.
CovarianceType
 end
 
 properties(GetAccess='public', SetAccess='protected')      
%mu Matrix of component means.
%   The mu property is a NumComponents-by-NumVariables matrix of component
%   means.
%
%   See also GMDISTRIBUTION.
        mu = [];          % NumComponents-by-NumVariables array for means
        
%Sigma Component covariance   
%   The Sigma property is an array or a matrix containing the component
%   covariance matrices. The value is one of the following for a Gaussian
%   mixture distribution with K components, in D dimensions:
%   *  A D-by-D-by-K array if there are no restrictions on the form of
%      covariance. In this case, Sigma(:,:,J) is the covariance matrix of
%      component J.
%   *  A 1-by-D-by-K array if the covariance matrices are restricted to be
%      diagonal, but not restricted to be same across components. In this
%      case Sigma(:,:,J) contains the diagonal elements of the covariance
%      matrix of component J.
%   *  A D-by-D matrix if the covariance matrices are restricted to be the
%      same across components, but not restricted to be diagonal. In this
%      case, the value is the common covariance matrix.
%   *  A 1-by-D vector if the covariance matrices are restricted to be
%      diagonal and to be the same across components.  In this case, the
%      value is the diagonal elements of the common covariance matrix.
%
%   See also GMDISTRIBUTION.
        Sigma = [];       % Covariance
                
%AIC The Akaike information criterion value.
%   The AIC property contains Akaike information criterion value, defined
%   as  2*NlogL + 2*(the number of estimated parameters), where NlogL is
%   the value of the NLogL property.
%
%   See also GMDISTRIBUTION.
        AIC = [];         % Akaike information criterion
        
%BIC The Bayes information criterion value.
%   The BIC property contains the Bayes information criterion value. It is
%   defined as 2*NlogL + (the number of estimated parameters * log(N)),
%   where  where NlogL is the value of the NLogL property, and N is the
%   number of observations.
%
%   See also GMDISTRIBUTION.
        BIC = [];         % Bayes information criterion
        
%Converged A logical value indicating whether the algorithm converged. 
%   The Converged property is true if the fitting algorithm converged;
%   false if the algorithm did not converge.
%
%   See also GMDISTRIBUTION.
        Converged = [];   % Has the EM converged  
 
% ProbabilityTolerance The probability tolerance
%   The ProbabilityTolerance property is the value provided for the
%   'ProbabilityTolerance' input for FITGMDIST.
       ProbabilityTolerance = [];
        
 end
   
   methods
       function nd = get.NumVariables(this)
           nd = this.NDimensions;
       end
        function this =set.NumVariables(this,n)
           this.NDimensions = n;
       end
       
       function n = get.DistributionName(this)
           n = this.DistName;
       end
       
       function nc = get.NumComponents(this)
           nc = this.NComponents;
       end
       
       function  p = get.ComponentProportion(this)
           p = this.PComponents;
       end
       
       function i = get.NumIterations(this)
           i = this.Iters;
       end
       
       function tf = get.SharedCovariance(this)
           tf = this.SharedCov;
       end
       
       function v = get.RegularizationValue(this)
           v = this.RegV;
       end
       
       function n = get.NegativeLogLikelihood(this)
           n = this.NlogL;
       end
       
       function t = get.CovarianceType(this)
            t = this.CovType;
       end
   end
   
    methods
        function obj = gmdistribution_dosedependent(mu, Sigma, p)
        %GMDISTRIBUTION Create a Gaussian mixture model.
        %   GM = GMDISTRIBUTION(MU,SIGMA,P) creates a distribution
        %   consisting of a mixture of multivariate Gaussian components,
        %   given values for the components' distribution parameters.  To
        %   create a Gaussian mixture distribution by fitting to data, use
        %   FITGMDIST.
        %
        %   The number of components and the dimension of the distribution are
        %   implicitly defined by the sizes of the inputs MU, SIGMA, and P.
        %
        %   MU is K-by-D matrix specifying the mean of each component, where K
        %   is the number of components, and D is the number of dimensions.  MU(J,:)
        %   is the mean of component J.
        %
        %   SIGMA specifies the covariance matrix of each component.  SIGMA is one
        %   of the following:
        %
        %      * A D-by-D-by-K array if there are no restrictions on the form of the
        %        covariance matrices.  In this case, SIGMA(:,:,J) is the covariance
        %        matrix of component J.
        %      * A 1-by-D-by-K array if the covariance matrices are restricted to be
        %        diagonal, but not restricted to be same across components.  In this
        %        case, SIGMA(:,:,J) contains the diagonal elements of the covariance
        %        matrix of component J.
        %      * A D-by-D matrix if the covariance matrices are restricted to be the
        %        same across components, but not restricted to be diagonal.  In this
        %        case, SIGMA is the common covariance matrix.
        %      * A 1-by-D vector if the covariance matrices are restricted to be
        %        diagonal and the same across components.  In this case, SIGMA contains
        %        the diagonal elements of the common covariance matrix.
        %
        %   P is 1-by-K vector specifying the mixing proportions of each component.  If
        %   P does not sum to 1, GMDISTRIBUTION normalizes it.  The default is equal
        %   proportions if P is not given.
        %
        %   The inputs MU, SIGMA, and P are stored in the mu, Sigma, and PComponents
        %   properties, respectively, of GM.
        %
        %   Example:  Create a 2-component Gaussian mixture model.
        %
        %            mu = [1 2;-3 -5];
        %            Sigma = cat(3,[2 0; 0 .5],[1 0; 0 1]);
        %            mixp = ones(1,2)/2;
        %            gm = gmdistribution(mu,Sigma,mixp);
        %
        %   See also GMDISTRIBUTION, FITGMDIST.
        
            if nargin==0
                return;
            end

            if nargin < 2
                error(message('stats:gmdistribution:TooFewInputs'));
            end
            if ~ismatrix(mu) || ~isnumeric(mu)
                error(message('stats:gmdistribution:BadMu'));
            end

            [k,d] = size(mu);
            if nargin < 3 || isempty(p)
                p = ones(1,k);
            elseif ~isvector(p) || length(p) ~= k
                error(message('stats:gmdistribution:MisshapedMuP'));
            elseif any(p <= 0)
                error(message('stats:gmdistribution:InvalidP'));
                      
            elseif size(p,1) ~= 1
                p = p'; % make it a row vector
            end

            p = p/sum(p);

            [d1,d2,k2] = size(Sigma);
            if  k2 == 1
                if d1 == 1 %diagonal covariance
                    if d2 ~= d
                        error(message('stats:gmdistribution:MisshapedSharedDiagCov'));
                    elseif any(Sigma<0)
                        error(message('stats:gmdistribution:BadDiagCov'));
                    end
                    obj.CovType = 'diagonal';

                else %full covariance
                    if ~isequal(size(Sigma),[d d])
                        error(message('stats:gmdistribution:MisshapedSharedCov'));
                    end
                    [~,err] = cholcov(Sigma);
                    if err ~= 0
                        error(message('stats:gmdistribution:BadSharedCov'));
                    end
                    obj.CovType = 'full';
                end

                obj.SharedCov = true;
                
            else %different covariance
                if k2 ~= k
                    error(message('stats:gmdistribution:MisshapedMuCov'));
                end
                if d1 == 1 %diagonal covariance
                    if d2 ~= d
                        error(message('stats:gmdistribution:MisshapedDiagCov'));
                     end
                    for j = 1:k
                        %check whether the covariance matrix is positive definite
                        if any(Sigma(:,:,j)<0)
                            error(message('stats:gmdistribution:BadDiagCov'));
                        end
                    end
                    obj.CovType = 'diagonal';
                else
                    if d1 ~= d || d2 ~= d
                        error(message('stats:gmdistribution:MisshapedCov'));
                    end
                    for j = 1:k
                        % Make sure Sigma is a valid covariance matrix
                        % check for positive definite
                        [~,err] = cholcov(Sigma(:,:,j));
                        if err ~= 0
                            error(message('stats:gmdistribution:BadCov'));
                        end
                    end
                    obj.CovType = 'full';
                end
                obj.SharedCov = false;
            end

            obj.NDimensions = d;
            obj.NComponents = k;
            type = superiorfloat(mu,Sigma,p);
            obj.PComponents = cast(p,type);
            obj.mu = cast(mu,type);
            obj.Sigma = cast(Sigma,type); 
            
        end % constructor
    end

    methods(Static = true,Hidden)
        obj = fit_dosedependent(X,k,dose,varargin);
    end

    methods(Hidden = true, Static = true)
        function a = empty(varargin)
            throwUndefinedError();
        end
    end
   
end % classdef

 
function throwUndefinedError()
st = dbstack;
name = regexp(st(2).name,'\.','split');
error(message('stats:gmdistribution:UndefinedFunction', name{ 2 }, mfilename));
end

