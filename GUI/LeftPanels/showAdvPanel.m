function showAdvPanel(hObject, ~, panel)
% showAdvPanel - Show or hide panel with advanced options
%
%   syntax: showAdvPanel(hObject, event, panel)
%       hObject - Reference to the 'Show options' checkbox (uicontrol)
%       event   - callback event data (unused)
%       panel   - structure containing references to panels
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

val = get(hObject, 'Value');   % 1 = checked (show), 0 = unchecked (hide)

if ~isfield(panel, 'advanced')
    return
end

% Show or hide all advanced sub-panels (stored as panel.advanced.panel1, .panel2 ...)
fNames = fieldnames(panel.advanced);
advNames = fNames(strncmp(fNames, 'panel', 5));
for n = 1:length(advNames)
    h = panel.advanced.(advNames{n}).panel;
    if ishandle(h)
        if val
            set(h, 'Visible', 'on');
        else
            set(h, 'Visible', 'off');
        end
    end
end
