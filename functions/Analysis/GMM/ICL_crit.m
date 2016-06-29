function crit = ICL_crit(mlog,data,mu,P,var_eq,N,d)
% ICL_crit - the Integrated Classification Likelihood Criterion
%
%   syntax: crit = ICL_crit(mlog,data,mu,P,var_eq,N,d)
%       mlog   - the maximum log likelihood
%       data   - the data
%       mu     - the estimated locations
%       P      - the proportions
%       var_eq - the variance
%       N      - length of data
%       d      - number of parameters
%       crit   - output value criterion
%
% See also: Biernacki et al., Technical Report  3521, INRIA, Rhônes-Alpes, 1998.

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

J = d/2;
pP = zeros(N,J);

for n = 1:N
    for k = 1:J
        pP(n,k) = normaldistribution(data(n),mu(k),var_eq)*P(k);
    end
end
E_w = pP./repmat(sum(pP,2),1,J);
Ew = E_w(:);
index=find(ne(log(Ew),-Inf));
som=0;
for j=1:length(index)
    som = som + sum(sum(Ew(index(j)).*log(Ew(index(j)))));
end
crit = 2*mlog - 2*som + d*log(N);
