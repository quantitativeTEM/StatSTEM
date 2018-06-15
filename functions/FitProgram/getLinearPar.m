function thetalin = getLinearPar(Ga,obs,s,fitzeta,zeta)
% getLinearPar - determine linear parameter of gaussian peaks
%
%   A more detailed explanation will follow
%
%   syntax: thetalin = getLinearPar(Ga,obs,s,fitzeta,zeta)
%       Ga      - Matrix containing columns with all gaussian peaks
%       obs     - observation
%       s       - number of pixels in observation
%       fitzeta - boolean indicating whether background should be fitted
%       zeta    - background value (if fitzeta if 0)
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
if fitzeta
    Ga(:,end) = ones(s,1);
    zeta = 0;
end
GaT = Ga';
GaTGa = GaT*Ga;
GaTobs = GaT*(obs-zeta);
thetalin = GaTGa\GaTobs;