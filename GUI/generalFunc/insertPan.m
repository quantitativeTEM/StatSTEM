function insertPan(hObject,event,h)
% insertPan - Insert pan in figure
%
% Close zooming functions and so on before enabling pan mode
%
%   syntax: insertPan(hObject,event,h)
%       hObject - Reference to button
%       event   - structure recording button events
%       h       - structure holding references to GUI interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

tab = loadTab(h);
if isempty(tab)
    set(hObject,'State','off');
    return
end

state = get(hObject,'State');
pan_obj = pan(h.fig);
if strcmp(state,'off')
    set(pan_obj,'Enable','off')
    return
end

% Turn off zoom
zoomAxinFig(h,'off')
% Turn off data cursor
datacursormode(h.fig,'off')
% Turn on pan
set(pan_obj,'Enable','on')