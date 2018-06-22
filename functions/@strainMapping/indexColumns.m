function strainmapping = indexColumns(strainmapping)
% indexColumns - Index fitted columns
%
%   syntax: strainmapping = indexColumns(strainmapping)
%       strainmapping - strainMapping file
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
findA = 1;
if ~isempty(strainmapping.a)
    findA = 0;
end

% Check if the a lattice direction is already found, if not find it
if findA
    strainmapping = findLatDir(strainmapping);
end

%% With the found angle find the relaxed coordinates
coor = strainmapping.coordinates(:,1:2);
refCoor = strainmapping.refCoor;
projUnit = strainmapping.projUnit;
teta = strainmapping.teta(1);
a = strainmapping.a(1);
b = strainmapping.b(1);
dir_teta_ab = strainmapping.dirTeta;
space = strainmapping.space;
up = strainmapping.fUpdate;

[indices,types] = STEMindexing(coor,refCoor,projUnit,teta,a,b,dir_teta_ab,space,'all',up);

strainmapping.typesNP = types;
strainmapping.indicesP = indices;

% Remove previous found results
strainmapping.coorExpectedP = [];
strainmapping.latticeAP = [];
strainmapping.latticeBP = [];
strainmapping.eps_xxP = [];
strainmapping.eps_yyP = [];
strainmapping.eps_xyP = [];
strainmapping.omg_xyP = [];
strainmapping.shiftCenAtomP = [];
strainmapping.octahedralTiltP = [];