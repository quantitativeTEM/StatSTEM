function crit = AIC_Delft_crit(mlog,d)
% AIC_Delft_crit - variation on AIC criterion, GIC Generalised Information
%                  Criterion
%
%   syntax: crit = AIC_Delft_crit(mlog,d)
%       mlog - the maximum log likelihood
%       d    - number of parameters
%       crit - output value criterion
%
% See also: Broersen and Wensink, IEEE Transactions on Signal Processing 41 (1) p. 194

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
crit = 2*mlog+3*d;