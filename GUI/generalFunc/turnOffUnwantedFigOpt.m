function h = turnOffUnwantedFigOpt(h)
% turnOffUnwantedFigOpt - Turn off unwanted figure options and get
%                         reference to the wanted ones
%   syntax: h = turnOffUnwantedFigOpt(h)
%       h       - structure holding references to StatSTEM interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Turn off figure options which are not necessary
a = findall(h.fig);
b = findall(a,'Label','&File');
set(b,'Visible','off')
b = findall(a,'Label','&Edit');
set(b,'Visible','off')
b = findall(a,'Label','&View');
set(b,'Visible','off')
b = findall(a,'Label','&Insert');
set(b,'Visible','off')
b = findall(a,'Label','&Tools');
set(b,'Visible','off')
b = findall(a,'Label','&Desktop');
set(b,'Visible','off')
b = findall(a,'Label','&Window');
set(b,'Visible','off')
b = findall(a,'Label','&Help');
set(b,'Visible','off')
b = findall(a,'ToolTipString','New Figure');
set(b,'Visible','off')
b = findall(a,'ToolTipString','Open File');
set(b,'Visible','off')
b = findall(a,'ToolTipString','Save Figure');
set(b,'Visible','off')
b = findall(a,'ToolTipString','Print Figure');
set(b,'Visible','off')
b = findall(a,'ToolTipString','Edit Plot');
set(b,'Visible','off')
b = findall(a,'ToolTipString','Brush/Select Data');
set(b,'Visible','off')
b = findall(a,'ToolTipString','Rotate 3D');
set(b,'Visible','off')
b = findall(a,'ToolTipString','Link Plot');
set(b,'Visible','off')
b = findall(a,'ToolTipString','Hide Plot Tools');
set(b,'Visible','off')
b = findall(a,'ToolTipString','Show Plot Tools and Dock Figure');
set(b,'Visible','off')
h.colorbar = findall(a,'ToolTipString','Insert Colorbar');
h.datacursor = findall(a,'ToolTipString','Data Cursor');
h.pan = findall(a,'ToolTipString','Pan');
h.zoom.in = findall(a,'ToolTipString','Zoom In');
h.zoom.out = findall(a,'ToolTipString','Zoom Out');