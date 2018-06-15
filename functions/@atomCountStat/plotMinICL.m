function plotMinICL(obj)
% plotMinICL - plot a cross indicating the selected minimum in the ICL
%
%   syntax: plotMinICL(obj)
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

hold(ax,'on')
h = plot(ax,selMin,obj.ICL(obj.selMin),'rx','MarkerSize',10,'Tag','Minimum ICL');
hold(ax,'off')