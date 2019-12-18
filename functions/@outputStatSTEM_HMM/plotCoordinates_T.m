function plotCoordinates_T(obj)
% plotCoordinates - plot input coordinates in image
%
%   syntax - plotCoordinates(obj)
%       obj - outputStatSTEM_HMM file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% First check whether coordinates are present
SliderT = findobj(gcf, 'type', 'uicontrol','style','slider');
t = round(get(SliderT(end), 'Value'));
coor = obj.coordinates_T(:,1:3,t);
if isempty(coor)
    return
end

if ~isempty(obj.GUI)
    ax = obj.ax;
else
    ax = gca;
end

marker = '.';
msize = coorMarkerSize(marker,obj.mscale);
clor = colorAtoms(1:max(coor(:,3)));

hold(ax, 'on')
for k=1:max(coor(:,3))
    indices = find(coor(:,3)==k);
    if ~isempty(indices)
        ah(k) = plot(ax,coor(indices,1),coor(indices,2),marker,'Color',clor(k,:),'MarkerSize',msize,'Tag','Input coordinates');
    end
end
hold(ax,'off')

addlistener(SliderT, 'Value', 'PostSet', @callbackfn);

    function callbackfn(source,eventdata)
        t = round(get(eventdata.AffectedObject, 'Value'));
        coor = obj.coordinates_T(:,:,t);
        if isempty(coor)
            return
        end
        
        if ~isempty(obj.GUI)
            ax = obj.ax;
        else
            ax = gca;
        end
        
        marker = '.';
        msize = coorMarkerSize(marker,obj.mscale);
        clor = colorAtoms(1:max(coor(:,3)));
        
        
        delete(ah)
        hold(ax, 'on')
        for k=1:max(coor(:,3))
            indices = find(coor(:,3)==k);
            if ~isempty(indices)
                ah(k) = plot(ax,coor(indices,1),coor(indices,2),marker,'Color',clor(k,:),'MarkerSize',msize,'Tag','Input coordinates');
            end
        end
        hold(ax,'off')
    end
end