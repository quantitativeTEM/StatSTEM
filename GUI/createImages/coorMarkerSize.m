function msize = coorMarkerSize(ax,marker,rescale)
% coorMarkerSize - define markerSize for figure object
%
%   syntax: msize = coorMarkerSize(ax,marker,rescale)
%       ax      - reference to axes
%       marker  - marker
%       rescale - rescale factor for marker size
%       msize   - size of the marker
%       

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
if nargin<3
    rescale = 1;
end
if nargin<2
    marker = '.';
end

% First get pixels size if not given
obsData = get(ax,'Children');
for i=1:length(obsData)
    if strcmp(get(obsData(i),'Type'),'image')
        dx = get(obsData(i),'XData');
        dy = get(obsData(i),'YData');
        break
    end
end

set(ax, 'Units', 'Inches')
pos = get(ax,'Position');
set(ax, 'Units', 'normalized')

L = min(dx(end),dy(end));

switch marker
    case '.'
        val = 100;
    case 'x'
        val = 50;
    case '+'
        val = 50;
    case 's'
        val = 50;
    otherwise
        val = 30;
end

msize = min(pos(3:4))/L*val*rescale;