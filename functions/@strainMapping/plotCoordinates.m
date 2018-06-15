function plotCoordinates(obj)
% plotCoordinates - plot input coordinates in image
%
%   syntax - plotCoordinates(obj)
%       obj - strainMapping file
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
coor = obj.coordinates;
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
        plot(ax,coor(indices,1),coor(indices,2),marker,'Color',clor(k,:),'MarkerSize',msize,'Tag','Strain coordinates');
    end
end
hold(ax,'off')