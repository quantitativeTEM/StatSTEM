function h = messagePanel(h)
% messagePanel - Create a panel to show messages
%
% syntax: h = messagePanel(h)
%   h - structure holding references to GUI interface
%
%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
% Modified: replaced Java/javacomponent with native MATLAB uicontrol

str = sprintf('Welcome to StatSTEM v3.1, have fun analysing\nWhen using StatSTEM please cite: A. De Backer, K.H.W. van den Bos, et. al., Ultramicroscopy 171 (2016), p.104-116');

hh = uicontrol('Parent', h.right.message.panel, ...
               'Style', 'listbox', ...
               'Units', 'normalized', ...
               'Position', [0.003 0.003 0.994 0.95], ...
               'String', strsplit(str, '\n'), ...
               'FontSize', 9, ...
               'ForegroundColor', [1 0 0], ...
               'BackgroundColor', [0.95 0.95 0.95], ...
               'Enable', 'inactive', ...
               'HorizontalAlignment', 'left');

h.right.message.text       = hh;
h.right.message.textPanel  = hh;
h.right.message.jTextPanel = hh;  % keep for compatibility