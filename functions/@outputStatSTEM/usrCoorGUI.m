function strainmapping = usrCoorGUI(output,input)
% usrCoorGUI - Select coordinate and store value in StatSTEM
%
%   syntax: strainmapping = usrCoorGUI(output,input)
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
    if length(output.types)==1
        actType = output.types{1};
    else
        error('Select a column type which should be used to find the central coordinate')
    end
end

projUnit = input.projUnit;
% Determine type for which central coordinate must be found
type = find(strcmp(output.types,actType));
type = type(1);
ind = coor(:,3)==type;
if ~any(ind)
    error(['Cannot select coordinate, no atoms present of type ',actType]);
end

%% Select coordinate
if isempty(input.GUI)
    figure;
    showObservation(input);
end
hold on
plotSelCoordinates(output,type)   
    
% Select axis
ax = gca;
axis(ax);
hold on;
title(ax,'Select coordinate, press ESC to exit')
[x,y] = ginput_AxInFig(ax);
% Update userdata
title(ax,'')
if ~isempty(x)
    coorT = coor(ind,1:2);
    distance = (coorT(:,1)-x).^2+(coorT(:,2)-y).^2;
    indM = find(distance==min(distance));
    refCoor = coorT(indM(1),:);
    % Create strainMapping file
    strainmapping = strainMapping(coor,output.dx,projUnit,refCoor);
    strainmapping.types = input.types;
    strainmapping.actType = actType;
end
deleteImageObject(ax,'Fitted coordinates')
