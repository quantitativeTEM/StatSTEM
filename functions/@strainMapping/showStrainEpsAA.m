function showStrainEpsAA(obj)
% showStrainEpsAA - make a strain map of eps aa in image
%
%   syntax - showStrainEpsAA(obj)
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

if isempty(obj.eps_aa)
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

removeOutliers = 0;

nameTag = [char(949),'_aa'];
scaleMarker = obj.mscale;
ind = ~isnan(obj.eps_aa(:,1));
data = obj.eps_aa(ind,1);
obj.coordinates = obj.coordinates(ind,:);
if removeOutliers == 1
    [index_outlier,L,U,~] = isoutlier(data);
    range = max([-L,U]);
elseif removeOutliers == 0 
    range = max( [max(data),-min(data)] );
elseif removeOutliers == 2
    [index_outlier,L,U,~] = isoutlier(data, 'gesd');
    range = 0.025;
end
if range == 0
    range = 0.001;
end
if range == Inf
    range = 1;
end
range = [-range,range];

% scatterPlot2Axes(ax,ax2,obj.coordinates,data,range,nameTag,scaleMarker,'Strain %g')
if removeOutliers == 1 |  removeOutliers == 2
    scatterPlot2Axes(ax,ax2,obj.coordinates(~index_outlier,1:2),data(~index_outlier),range,nameTag,scaleMarker,'Strain %g')
else
    scatterPlot2Axes(ax,ax2,obj.coordinates,data,range,nameTag,scaleMarker,'Strain %g')
end

