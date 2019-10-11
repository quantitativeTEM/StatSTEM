function [h_pan,h_zoom,h_cursor] = turnOffFigureSelection(h)
% turnOffFigureSelection - Turn off zoom, pan and datacursor
%
%   syntax: [h_pan,h_zoom,h_cursor] = turnOffFigureSelection(h)
%       h        - structure holding references to GUI interface
%       h_pan    - reference to pan object
%       h_zoom   - reference to zoom buttons
%       h_cursor - reference to datacrusor object
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Determine Matlab version for compatibility
v = version('-release');
v = str2double(v(1:4));

% First turn off zoom, pan and datacursor
h_pan = pan(h.fig);
h_zoom = [h.zoom.in;h.zoom.out];
h_cursor = datacursormode(h.fig);
h_cursor.removeAllDataCursors();
set(h_pan,'Enable','off')
set(h_cursor,'Enable','off')

if v < 2019
    zoomAxinFig(h,'off')
else
    h_z = zoom(h.fig);
    h_z.Enable = 'off';
end
