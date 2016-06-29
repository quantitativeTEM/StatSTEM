function plotCoordinates(ax,coor,name,marker)
% plotCoordinates - plot coordinates in image
%
%   syntax - plotCoordinates(ax,coor,name,marker)
%       ax     - handle to axes
%       coor   - coordinates
%       name   - name of object
%       marker - marker
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
    marker = '.';
end

msize = coorMarkerSize(ax,marker);
hold(ax, 'on')
if ~isempty(coor)
    h = zeros(max(coor(:,3)),1);
    for k=1:max(coor(:,3))
        indices = find(coor(:,3)==k);
        if ~isempty(indices)
            h(k) = plot(ax,coor(indices,1),coor(indices,2),marker,'Color',colorAtoms(k),'MarkerSize',msize,'Tag',name);
        end
    end
end
hold(ax,'off')

% Store reference to coordinates
data = get(ax,'Userdata');
set(ax,'Userdata',[data;{name h}])