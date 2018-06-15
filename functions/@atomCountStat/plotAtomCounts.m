function plotAtomCounts(atomcounting)
% plotAtomCounts - plot the atom counts
%
%   syntax: plotAtomCounts(atomcounting)
%       atomcounting - atomCountStat file
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
if isempty(atomcounting.ax2)
    img = get(ax,'Parent');
    ax2 = axes('Parent',img,'units','normalized');
    axes(ax)
else
    ax2 = atomcounting.ax2;
end

nameTag = 'Atom Counts';
scaleMarker = atomcounting.mscale;
range = [0,max(atomcounting.Counts)];
data = atomcounting.Counts;

scatterPlot2Axes(ax,ax2,atomcounting.coordinates(:,1:2),data,range,nameTag,scaleMarker,'Thickness: %g atoms')



