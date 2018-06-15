function msize = coorMarkerSize(marker,rescale)
% coorMarkerSize - define markerSize for figure object
%
%   syntax: msize = coorMarkerSize(ax,marker,rescale)
%       marker  - marker
%       rescale - rescale factor for marker size
%       

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

ax = gca;
if nargin<2
    rescale = 1;
end
if nargin<1
    marker = '.';
end

% First get pixels size if not given
dx = 1;
dy = 1;
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
        val = 3000*min(pos(3:4))/L*rescale;
    case 'arrow'
        val = 10;
    case 'line'
        msize = 2*rescale;
        return
    otherwise
        val = 30;
end

msize = min(pos(3:4))/L*val*rescale;