function EnableBut(hObject,event,h)
% DisableBut - Callback function for restoring abort button
%
%   syntax: EnableBut(hObject,event,h)
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

% Disable the abort button
javaCallback(hObject,'MouseEnteredCallback',{@buttonPressed,@DisableBut,h},'MouseExitedCallback',{@buttonPressed,[]})
hObject.setForeground(java.awt.Color(1,0,0))
hObject.setEnabled(true)