function reqFocus(jObject,event,h)
% reqFocus - Give object focus
%
% syntax: reqFocus(jObject,event,h)
%       jObject - Reference to java object
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

turnOffFigureSelection(h);

% This function is only executed when another function is running. abort
% this function by hitting escape
robot = java.awt.Robot;
robot.keyPress(java.awt.event.KeyEvent.VK_ESCAPE);
robot.keyRelease(java.awt.event.KeyEvent.VK_ESCAPE);

% Delete all callbacks related to this other function
set(jObject,'MouseEnteredCallback',[],'MouseExitedCallback',[],'MouseReleasedCallback',[])
% After this make object focusable and request focus
jObject.setFocusable(true)
jObject.requestFocus;