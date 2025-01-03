function showStrainOmgXY(obj)
% showStrainOmgXY - make a strain map of omega xy in image
%
%   syntax - showStrainOmgXY(obj)
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

if isempty(obj.omg_xy)
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

nameTag = [char(969),'_xy'];
scaleMarker = obj.mscale;
ind = ~isnan(obj.omg_xy(:,1));
data = obj.omg_xy(ind,1);
[~,L,U,~] = isoutlier(data);
% range = max( [max(data),-min(data)] );
range = max([L,U]);
range = [-range,range];

scatterPlot2Axes(ax,ax2,obj.coordinates(ind,1:2),data,range,nameTag,scaleMarker,'Strain %g')

