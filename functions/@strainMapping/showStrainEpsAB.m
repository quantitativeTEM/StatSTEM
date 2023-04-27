function showStrainEpsAB(obj)
% showStrainEpsAB - make a strain map of eps ab in image
%
%   syntax - showStrainEpsAB(obj)
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

if isempty(obj.eps_ab)
    return
end

ax = gca;
if isempty(obj.ax2)
    img = get(ax,'Parent');
    ax2 = axes('Parent',img,'units','normalized');
    axes(ax)
else
    ax2 = obj.ax2;
end

nameTag = [char(949),'_ab'];
scaleMarker = obj.mscale;
ind = ~isnan(obj.eps_ab(:,1));
data = obj.eps_ab(ind,1);
range = max( [max(data),-min(data)] );
range = [-range,range];

scatterPlot2Axes(ax,ax2,obj.coordinates(ind,1:2),data,range,nameTag,scaleMarker,'Strain %g')


