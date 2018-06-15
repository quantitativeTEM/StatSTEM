function obj = keepPeaks(obj)
% addPeaks - Callback for selecting and keeping peak locations manually
%
%   syntax: obj = keepPeaks(obj)
%       obj - inputStatSTEM file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if obj.GUI==0
    figure;
    showObservation(obj);
    hold on
    plotCoordinates(obj)   
end

%% Select axis
ax = gca;
hold(ax,'on');

%% Start selecting area
title(ax,'Select region, press ESC to exit')
coor = gregion_AxInFig();
title(ax,'')
if ~isempty(coor)
    in = inpolygon(obj.coordinates(:,1),obj.coordinates(:,2),coor(:,1),coor(:,2));
    obj.coordinates = obj.coordinates(in,:);
end
hold(ax,'off');