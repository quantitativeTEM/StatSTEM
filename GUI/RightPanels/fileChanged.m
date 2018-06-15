function fileChanged(hObject,event,h)
% fileChanged - Show of load a new file
%
%   syntax: fileChanged(hObject,event,h)
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

% Check matlab version, and switch opengl
v = version('-release');
v = str2double(v(1:4));

if v<2015
    tabs = get(hObject,'Children');
    % Set button back to old value
    if event.NewValue==length(tabs)
        % Bug in MATLAB, first set index to new value
        set(hObject,'SelectedIndex',event.NewValue)
        set(hObject,'SelectedIndex',event.OldValue)
        loadFile(hObject,event,h)
    else
        tab = tabs(event.NewValue);
        usr = get(tab,'Userdata');
        updateLeftPanels(h,usr.file)
        % Make axes of new panel current axes (for colorbar and legend)
        axes(usr.images.ax)
    end
else
    if strcmp(event.NewValue.Title,'+')
        % Set button back to old value
        set(hObject,'SelectedTab',event.OldValue)
        loadFile(hObject,event,h)
    else
        tab = event.NewValue;
        usr = get(tab,'Userdata');
        updateLeftPanels(h,usr.file)
        % Make axes of new panel current axes (for colorbar and legend)
        axes(usr.images.ax)
    end
end

zoomReset(h)