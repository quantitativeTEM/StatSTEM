function plotLib(obj)
% plotLib - Show a plot of the library values of the scattered intensities vs thickness
%
%   syntax: plotLib(obj)
%       obj - atomCountLib file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

lib = obj.library;
if isempty(lib)
    return
end

if ~isempty(obj.GUI)
    ax = obj.ax;
else
    ax = gca;
end

hold(ax,'on')
plot(ax,obj.thick,lib,'.', 'MarkerSize', 20, 'Color', [0 0 0],'Tag','Library');
hold(ax,'off')
h = legend(ax,'Experiment','Library','Location','northwest');
