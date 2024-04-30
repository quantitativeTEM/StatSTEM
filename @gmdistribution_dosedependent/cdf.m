function y=cdf(obj,X,dose)
%CDF CDF for the Gaussian mixture distribution.
%   Y=CDF(OBJ,X) returns Y, a vector of length N containing the values of
%   the cumulative distribution function (CDF) for the gmdistribution OBJ,
%   evaluated at the N-by-D data matrix X. Rows of X correspond to points,
%   columns correspond to variables. Y(I) is the cdf value of point I.
%
%   See also GMDISTRIBUTION, GMDISTRIBUTION/PDF.

%   Copyright 2007 The MathWorks, Inc.


% Check for valid input


narginchk(2,2);
checkdata(X,obj);

covNames = { 'diagonal','full'};
CovType = find(strncmpi(obj.CovType,covNames,length(obj.CovType)));

y = zeros(size(X,1),1);
if obj.SharedCov
    if CovType==1 %diagonal covariance
        for j=1:obj.NComponents
            c = normcdf(X(:,1),obj.mu(j,1), sqrt(obj.Sigma(1,1)+obj.mu(j,1)/dose));
            for t=2:obj.NDimensions
                c = c .* normcdf(X(:,t),obj.mu(j,t), sqrt(obj.Sigma(1,t)+obj.mu(j,t)/dose)) ;
            end
            y = y + obj.PComponents(j) * c;
        end
    else%full covariance
        for j=1:obj.NComponents
            y = y + obj.PComponents(j) * mvncdf(X,obj.mu(j,:),obj.Sigma+obj.mu(j,:)/dose);
        end
    end
else %different covariance for each component
    if CovType==1 %diagonal covariance
        for j=1:obj.NComponents
             c = normcdf(X(:,1),obj.mu(j,1), sqrt(obj.Sigma(1,1,j)+obj.mu(j,1)/dose));
             for t=2:obj.NDimensions
                c = c .* normcdf(X(:,t),obj.mu(j,t), sqrt(obj.Sigma(1,t,j)+obj.mu(j,t)/dose)) ;
             end
            y = y + obj.PComponents(j) * c;
        end
    else%full covariance
        for j=1:obj.NComponents
            y = y + obj.PComponents(j) * mvncdf(X,obj.mu(j,:),obj.Sigma(:,:,j)+obj.mu(j,:)/dose);
        end
    end
end

