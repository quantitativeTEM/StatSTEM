function plotAtomCounts(obj)
% plotAtomCounts - plot the atom counts
%
%   syntax: plotAtomCounts(obj)
%       obj - atomCountStat file
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
if isempty(obj.ax2)
    img = get(ax,'Parent');
    ax2 = axes('Parent',img,'units','normalized');
    axes(ax)
else
    ax2 = obj.ax2;
end

nameTag = 'Lib Counts';
scaleMarker = obj.mscale;
range = [0,max(obj.Counts)];
data = obj.Counts;

scatterPlot2Axes(ax,ax2,obj.coordinates(:,1:2),data,range,nameTag,scaleMarker,'Thickness: %g atoms')