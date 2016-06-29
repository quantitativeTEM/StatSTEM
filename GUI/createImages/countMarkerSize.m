function msize = countMarkerSize(ax,dx)
% countMarkerSize - define markerSize for figure object
%
%   syntax: msize = countMarkerSize(ax,dx)
%       ax    - reference to axes
%       dx    - pixel size
%       msize - size of the marker
%       

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% First change image
obsData = get(ax,'Children');
for i=1:length(obsData)
    if isa(obsData(i),'matlab.graphics.primitive.Image')
        dx = get(obsData(i),'XData');
        dy = get(obsData(i),'YData');
        break
    end
end

set(ax, 'Units', 'Inches')
pos = get(ax,'Position');
set(ax, 'Units', 'normalized')

L = min(dx(end),dy(end));
dx = min(dx(2),dy(2));

msize = min(pos(3:4))/L/dx*10;