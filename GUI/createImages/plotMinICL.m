function plotMinICL(ax,coor)
% plotMinICL - plot a cross indicating the selected minimum in the ICL
%
%   syntax: plotMinICL(ax,coor)
%       ax    - handle to axes
%       coor  - coordinates
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

hold(ax,'on')
h = plot(ax,coor(1),coor(2),'rx','MarkerSize',10);
hold(ax,'off')

% Store reference to coordinates
data = get(ax,'Userdata');
set(ax,'Userdata',[data;{'Minimum ICL' h}])