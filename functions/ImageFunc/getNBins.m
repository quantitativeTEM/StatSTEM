function N = getNBins(data)
% getNBins - Compute the number of bins in a histogram
%
% syntax: N = getNBins(data)
%   data - data to be shown in a histogram
%   N    - number of bins
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: A. De Backer, K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

N = ceil(min(length(data)/3,150));