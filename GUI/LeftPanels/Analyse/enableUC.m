function enableUC(jObject,event,h)
% enableUC - Enable the field to file in the unit cell size
%
%   syntax: enableUC(jObject,event,h)
%       jObject - Reference to object
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

% Check if no other routine is running
userdata = get(h.right.tabgroup,'Userdata');
if (userdata.callbackrunning)
    % First turn off zoom, pan and datacursor
    turnOffFigureSelection(h);
    % If so store function name and variables and cancel other function
    userdata.function.name = mfilename;
    userdata.function.input = {jObject,event,h};
    set(h.right.tabgroup,'Userdata',userdata)
    robot = java.awt.Robot;
    robot.keyPress(java.awt.event.KeyEvent.VK_ESCAPE);
    robot.keyRelease(java.awt.event.KeyEvent.VK_ESCAPE);
    return
end

state = jObject.isSelected;
h.left.ana.panel.strainAdv.impFitNUC.setEnabled(state)
h.left.ana.panel.strainAdv.impFitNUCText.setEnabled(state)
h.left.ana.panel.strainAdv.impFitParAll.setEnabled(state)
h.left.ana.panel.strainAdv.impFitParTeta.setEnabled(state)