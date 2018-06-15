function plotGMM(obj)
% plotGMM - Show a plot of the individual GMM components
%
%   syntax - plotGMM(obj)
%       obj - atomCountStat file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author; K.H.W. van den Bos
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

hold(ax,'on')
plot(ax,obj.x,obj.GMM, 'k-', 'LineWidth',2,'Tag','GMM');
hold(ax,'off')