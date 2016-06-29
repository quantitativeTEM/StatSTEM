function DisableBut(hObject,event,h)
% DisableBut - Button callback for aborting fitting procedure
%
%   syntax: DisableBut(hObject,event,h)
%       hObject - Reference to button
%       event   - structure recording button events
%       h       - structure holding references to StatSTEM interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Disable the abort button
javaCallback(hObject,'MouseEnteredCallback',{@buttonPressed,[]},'MouseExitedCallback',{@buttonPressed,[]})
hObject.setForeground(javax.swing.plaf.ColorUIResource(0,0,0))
hObject.setEnabled(false)
hObject.setToolTipText('Please wait, fitting procedure is being aborted')
usr = get(h.fig,'Userdata');
if ~isempty(usr)
    message = sprintf('Please wait, fitting procedure is being aborted');
    newMessage(message,h)
end
set(h.fig,'Userdata',[]);