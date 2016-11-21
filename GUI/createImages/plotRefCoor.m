function plotRefCoor(ax,coor,name,scaleMarker)
% plotCoordinates - plot coordinates in image
%
%   syntax - plotCoordinates(ax,coor,name,marker)
%       ax          - handle to axes
%       coor        - x- and y-coordinate
%       name        - name of object
%       scaleMarker - Scale to rescale size of marker
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

if nargin<4
    scaleMarker = 1;
end

msize = coorMarkerSize(ax,'x',scaleMarker*2);
hold(ax, 'on')
h = plot(ax,coor(1,1),coor(1,2),'x','Color','r','MarkerSize',msize,'Tag',name);
hold(ax,'off')

% Store reference to coordinates
data = get(ax,'Userdata');
set(ax,'Userdata',[data;{name h}])