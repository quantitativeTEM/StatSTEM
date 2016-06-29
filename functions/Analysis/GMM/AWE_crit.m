function crit = AWE_crit(mlog,data,mu,P,var_eq,N,d)
% AWE_crit - the Approximate Weight of Evidence criterion
%
%   syntax: crit = AWE_crit(mlog,data,mu,P,var_eq,N,d)
%       mlog   - the maximum log likelihood
%       data   - the data
%       mu     - the estimated locations
%       P      - the proportions
%       var_eq - the variance
%       N      - length of data
%       d      - number of parameters
%       crit   - output value criterion
%
% See also: Banfield and Raftery, Biometrics 49, p. 803

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
J = d/2;
crit_CLC = CLC_crit(mlog,data,mu,P,var_eq,N,J);
crit = crit_CLC + 2*d*(3/2+log(N));