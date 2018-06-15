function obj = flipContrastImage(obj)
% flipContrastImage - invert the contrast in the image
%
%   syntax: obj = selectPartImage(obj)
%       obj  - inputStatSTEM file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

obj.obs = -obj.obs;


