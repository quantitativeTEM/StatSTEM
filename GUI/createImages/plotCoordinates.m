function plotCoordinates(ax,coor,name,pathColor,marker,scaleMarker)
% plotCoordinates - plot coordinates in image
%
%   syntax - plotCoordinates(ax,coor,name,marker)
%       ax        - handle to axes
%       coor      - coordinates
%       pathColor - location of text file with marker colors
%       name      - name of object
%       marker    - marker
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% First check whether coordinates are present
if isempty(coor)
    return
end

if nargin<5
    marker = '.';
end

if nargin<6
    scaleMarker = 1;
end

msize = coorMarkerSize(ax,marker,scaleMarker);
hold(ax, 'on')
if ~isempty(coor)
    h = zeros(max(coor(:,3)),1);
    clor = colorAtoms(pathColor,1:max(coor(:,3)));
    for k=1:max(coor(:,3))
        indices = find(coor(:,3)==k);
        if ~isempty(indices)
            h(k) = plot(ax,coor(indices,1),coor(indices,2),marker,'Color',clor(k,:),'MarkerSize',msize,'Tag',name);
        end
    end
end
hold(ax,'off')

% Store reference to coordinates
data = get(ax,'Userdata');
set(ax,'Userdata',[data;{name h}])