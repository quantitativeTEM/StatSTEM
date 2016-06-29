function crit = BIC_crit(mlog,d,N)
% BIC_crit - The Bayesian Information Criterion
%
%   syntax: crit = BIC_crit(mlog,d,N)
%       mlog   - the maximum log likelihood
%       d      - number of parameters
%       N      - length of data
%       crit   - output value criterion
%
% See also: Schwarz, Annals of Statistics 6 (2), p. 461

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
crit = 2*mlog+d*log(N);
