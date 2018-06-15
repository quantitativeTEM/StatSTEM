function strainmapping = getTetaAB(strainmapping)
% getTetaAB - Find teta, a, b for strain mapping and improve if asked by fitting
%
%   syntax: strainmapping = getTetaAB(strainmapping)
%       strainmapping - strainMapping file

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if strainmapping.impByFit
    strainmapping = STEMrefPar(strainmapping);
else
    strainmapping.aP = strainmapping.projUnit.a;
    strainmapping.errAP = 0;
    strainmapping.bP = strainmapping.projUnit.b;
    strainmapping.errBP = 0;
end