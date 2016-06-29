function plotGMM(ax,x,GMM)
% plotGMM - Show a plot of the individual GMM components
%
%   syntax - plotGMM(ax,x,GMM)
%       ax    - handle to graph
%       x     - values x-axis
%       GMM   - the values to be shown
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
hold(ax,'on')
h = plot(ax,x,GMM, 'k-', 'LineWidth',2);
hold(ax,'off')
% Store reference to histogram
data = get(ax,'Userdata');
set(ax,'Userdata',[data;{'GMM' h}])