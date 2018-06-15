function abortFit(obj)
% DisableBut - Button callback for aborting fitting procedure
%
%   syntax: DisableBut(obj)
%       obj - Reference to StatSTEMfile
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Disable the abort button
set(obj.GUI,'Userdata',0)