function plotGMMcomp(obj)
% plotGMMcomp - Show a plot of the individual GMM components
%
%   syntax: plotGMMcomp(obj)
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

% First check whether a selected minimum is present
selMin = obj.selMin;
if isempty(selMin)
    return
end

if ~isempty(obj.GUI)
    ax = obj.ax;
else
    ax = gca;
end

GMM = obj.GMMcomp;
hold(ax,'on')
% Colors
cmap = colormap(ax,'jet');
c_x = linspace(0,max(size(GMM,1))+obj.offset,size(cmap,1));
for i = 1:size(GMM,1)
    % Get color
    color = [interp1(c_x,cmap(:,1),i,'linear') interp1(c_x,cmap(:,2),i,'linear') interp1(c_x,cmap(:,3),i,'linear')];
    
    plot(ax,obj.x, GMM(i,:), '--', 'LineWidth',2,'Color',color,'Tag','GMM components');
end
hold(ax,'off')