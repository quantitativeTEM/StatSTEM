function libcounting = matchLib(output,library,thick)
% matchLib - Simulation based atomcounting
%
%   Apply atomcounting by comparing experimentally measured scattering
%   cross-sections with a library of simulated values
%
%   syntax: libcounting = matchLib(output)
%       output      - outputStatSTEM file
%       library     - A (nx1) vector containing the libary SCS values
%       thick       - Corresponding thickness to library values
%       libcounting - atomCountLib file
%       

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

%% Load library if not present
if nargin<3
    [library,thick] = loadLibrary;
elseif nargin<2
    N = length(library);
    thick = (1:N)';
end

% Library is loaded, create atomCountLib file
libcounting = atomCountLib(output.selCoor,output.selVol,output.dx,library,thick);