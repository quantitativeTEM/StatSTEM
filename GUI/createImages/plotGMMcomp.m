function plotGMMcomp(ax,x,GMM,offset)
% plotGMMcomp - Show a plot of the individual GMM components
%
%   syntax: plotGMMcomp(ax,x,GMM,offset)
%       ax     - handle to graph
%       x      - values x-axis
%       GMM    - the values to be shown
%       offset - offset of the atom counts 
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if isempty(GMM)
    return
end
if nargin<4
    offset = 0;
end

h = zeros(size(GMM,1),1);
hold(ax,'on')
% Colors
cmap = colormap(ax,'jet');
c_x = linspace(0,max(size(GMM,1))+offset,size(cmap,1));
for i = 1:size(GMM,1)
    % Get color
    color = [interp1(c_x,cmap(:,1),i,'linear') interp1(c_x,cmap(:,2),i,'linear') interp1(c_x,cmap(:,3),i,'linear')];
    
    h(i) = plot(ax,x, GMM(i,:), '--', 'LineWidth',2,'Color',color);
end
hold(ax,'off')

% Store reference to histogram
data = get(ax,'Userdata');
set(ax,'Userdata',[data;{'GMM components' h}])