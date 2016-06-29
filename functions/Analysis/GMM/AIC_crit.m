function crit = AIC_crit(mlog,d)
% AIC_crit - the Akaike's Information Criterion
%
%   syntax: crit = AIC_crit(mlog,d)
%       mlog - the maximum log likelihood
%       d    - number of parameters
%       crit - output value criterion
%
% See also: Akaike, IEEE Transactions on Automatic Control 19 (9) p.716

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
crit = 2*mlog+2*d;