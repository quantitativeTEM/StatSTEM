function obj = removeAllPeaks(obj)
% removeAllPeaks - Callback for removing all peak locations
%
%   syntax: obj = removeAllPeaks(obj)
%       obj - inputStatSTEMfile
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

%% Store input structures without coordinates
obj.coordinates = [];
