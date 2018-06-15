function strainmapping = getCenCoor(output,input)
% getCenCoor - Find most central coordinate and store value as a strainMapping variable
%
%   syntax: strainmapping = getCenCoor(output,input)
%       input         - inputStatSTEM file
%       output        - outputStatSTEM file
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

%% Find coordinate
% First extract selected coordinates for analysis
coor = output.selCoor;
actType = output.actType;
if isempty(actType)
    actType = input.actType;
end
if isempty(actType)
    actType = output.types{1};
end

projUnit = input.projUnit;
% Determine type for which central coordinate must be found
type = find(strcmp(output.types,actType));
type = type(1);
ind = coor(:,3)==type;
if ~any(ind)
    error(['Cannot determine most central coordinate, no atoms present of type ',actType]);
end

% Select coordinates, selected by user, and find central coordinate
refCoor = findCentralCoor(coor(ind,:));

% Create strainMapping file
strainmapping = strainMapping(coor,output.dx,projUnit,refCoor);
strainmapping.types = input.types;
strainmapping.actType = actType;

