function obj = addPeaks(obj,type)
% addPeaks - Callback for adding peak locations manually
%
%   syntax: obj = addPeaks(obj,type)
%       obj  - inputStatSTEM file
%       type - selected type of coordinates to add (name)
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if nargin<2
    type = obj.actType;
end

if isempty(obj.GUI)
    figure;
    showObservation(obj);
    hold on
    plotCoordinates(obj)
end
%% Select axis
ax = gca;
axis(ax);
hold on;

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
colr = colorAtoms(type);

%% Start adding
title(ax,'Add peak locations, press ESC to exit')
hold(ax, 'on')
abort = 0;
h_pan = pan(gcf);
h_cursor = datacursormode(gcf);

% Get scale marker
scaleMarker = obj.mscale;
msize = coorMarkerSize('.',scaleMarker);

% add first point and enable buttons
h_newPeaks = [];
coordinates = [];
while abort==0
    [x,y] = ginput_AxInFig(ax,h_pan,h_cursor);
    if isempty(x)
        abort = 1;
    else
        if ~isempty(h_newPeaks)
            delete(h_newPeaks)
        end
        coordinates = [coordinates;[x y type]];
        h_newPeaks = plot(coordinates(:,1),coordinates(:,2),'.','Color',colr,'MarkerSize',msize,'Tag','Input coordinates');
    end
end

title(gca,'')
hold(ax, 'off');

obj.coordinates = [obj.coordinates;coordinates];
