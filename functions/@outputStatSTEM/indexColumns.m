function strainmapping = indexColumns(output,input,strainmapping)
% indexColumns - Index fitted columns
%
%   syntax: strainmapping = indexColumns(output,input,strainmapping)
%       strainmapping - strainMapping file
%       output        - outputStatSTEM file
%       input         - inputStatSTEM file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Check nargin, if strainMapping field is present check if reference
% coordinate and a,b-directions are found
findRef = 1;
findA = 1;
if nargin==3
    if ~isempty(strainmapping.refCoor)
        findRef = 0;
    end
    if ~isempty(strainmapping.a)
        findA = 0;
    end
end

% Check if a reference coordinate is already generated, if not find it
if findRef
    if output.optRefCoor==0
        strainmapping = getCenCoor(output,input);
    else
        strainmapping = usrCoorGUI(output,input);
    end
end

% Check if the a lattice direction is already found, if not find it
if findA
    strainmapping = findLatDir(strainmapping);
end

%% With the found angle find the relaxed coordinates
strainmapping = indexColumns(strainmapping);