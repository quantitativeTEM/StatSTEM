function plotRefCoor(obj)
% plotCoordinates - plot coordinates in image
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

% First check whether a reference coordinate is present
if isempty(obj.refCoor)
    return
end

if ~isempty(obj.GUI)
    ax = obj.ax;
else
    ax = gca;
end

msize = coorMarkerSize('x',obj.mscale*2);

hold(ax,'on')
h = plot(ax,obj.refCoor(1,1),obj.refCoor(1,2),'rx','MarkerSize',msize,'Tag','Ref strainmapping');
hold(ax,'off')