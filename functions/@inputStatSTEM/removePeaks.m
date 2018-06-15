function obj = removePeaks(obj)
% removePeaks - Callback for removing peak locations manually
%
%   syntax: obj = removePeaks(obj)
%       obj - inputStatSTEMfile
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if isempty(obj.coordinates)
    % Nothing to remove
    return
end

if obj.GUI==0
    showObservation(obj);
    hold on
    plotCoordinates(obj)   
end

%% Select axis
ax = gca;
axis(ax);
hold on;

% Find color of selected type to add
types = (1:max(obj.coordinates(:,3)))';
colr = zeros(max(types),3);
for k=types
    colr(k,:) = colorAtoms(k);
end

%% Start removing
title(ax,'Remove peak locations, press ESC to exit')
hold(ax,'on')
abort = 0;
h_pan = pan(gcf);
h_cursor = datacursormode(gcf);

% Get scale marker
scaleMarker = obj.mscale;
msize = coorMarkerSize('.',scaleMarker);

% Find plotted coordinates in axes
chld = get(ax,'Children');
ind = strcmp(get(chld,'Tag'),'Input coordinates');
h_peaks = chld(ind);

while abort==0
    [x,y] = ginput_AxInFig(ax,h_pan,h_cursor);
    if isempty(x)
        abort = 1;
    else
        distance = (obj.coordinates(:,1)-x).^2+(obj.coordinates(:,2)-y).^2;
        obj.coordinates = obj.coordinates(distance~=min(distance),:);
        for k=1:length(h_peaks)
            if h_peaks(k)~=0
                delete(h_peaks(k))
            end
        end
        clear h_peaks
        for k=1:max(obj.coordinates(:,3))
            indices = obj.coordinates(:,3)==k;
            if any(indices)
                h_peaks(k) = plot(obj.coordinates(indices,1),obj.coordinates(indices,2),'.','Color',colr(k,:),'MarkerSize',msize,'Tag','Input coordinates');
            else
                h_peaks(k)=0;
            end
        end
    end
    if isempty(obj.coordinates)
        abort = 1;
    end
end
title(ax,'')
hold(ax,'off');