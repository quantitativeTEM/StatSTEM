function obj = autoAssignTypes(obj,varargin)
% autoAssignTypes - automatically assign column type by using a projected
% unit cell
%
%   Use functions of other StatSTEMfile classes to index columns. Use indices 
%   to assign column types
%
%   syntax: obj = autoAssignTypes(obj)
%       obj - inputStatSTEM file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K. H. W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% First create an outputStatSTEM file;
Ncol = length(obj.coordinates(:,1));
output = outputStatSTEM(obj.coordinates,ones(Ncol,1),ones(Ncol,1),0,obj.dx);
output.types = obj.types;

% Find a- and b-direction
strainmapping = getCenCoor(output,obj);
strainmapping = findLatDir(strainmapping);

coor = strainmapping.coordinates(:,1:2);
refCoor = strainmapping.refCoor;
projUnit = strainmapping.projUnit;
teta = strainmapping.teta(1);
a = strainmapping.a(1);
b = strainmapping.b(1);
dir_teta_ab = strainmapping.dirTeta;
space = strainmapping.space;

[~,types] = STEMindexing(coor,refCoor,projUnit,teta,a,b,dir_teta_ab,space,'allNoWarn',0,10000);

indT = types==0;
types(indT)=1;

obj.coordinates(:,3) = types;
coorTot = obj.coordinates;
% Check if column names are the same, if so they should be of the same type
atomNames = unique(projUnit.atom2D,'stable');
for i=1:length(atomNames)
    typInt = find(strcmp(projUnit.atom2D,atomNames{i}));
    for j=1:length(typInt)
        indInt = coorTot(:,3)==typInt(j);
        obj.coordinates(indInt,3) = i;
    end
end
obj.types = atomNames;
obj.actType = obj.types{1};
