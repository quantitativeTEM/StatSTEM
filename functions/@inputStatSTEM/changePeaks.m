function obj = changePeaks(obj,type)
% changePeaks - Changing atom type of peaks manually
%
%   syntax: changePeaks(hObject,event,h)
%       obj - inputStatSTEM file
%       type - selected type of coordinates to add (name)
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------


if nargin<2
    type = obj.actType;
end

if obj.GUI==0
    figure;
    showObservation(obj);
    hold on
    plotCoordinates(obj)   
end

% Find color of selected type to add
if isempty(type)
    type = 1;
else
    ind = find(strcmp(obj.types,type));
    if ~isempty(ind)
        type = ind(1);
    else
        type = 1;
    end
end

%% Select axis
ax = gca;
hold(ax,'on');

% Start changing type
title('Select region, press ESC to exit')
coor = gregion_AxInFig();
title(ax,'')
if ~isempty(coor)
    in = inpolygon(obj.coordinates(:,1),obj.coordinates(:,2),coor(:,1),coor(:,2));
    obj.coordinates(in,3) = type;
end
hold(ax,'off');