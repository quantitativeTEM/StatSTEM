function deleteFigure(hObject,event,h)
% deleteFigure - execute this when closing the StatSTEM interface
%
% This function aborts all running functions before closing the interface
%
%   syntax: deleteFigure(hObject,event,h)
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

% Check if no other routine is running
userdata = get(h.right.tabgroup,'Userdata');
if (userdata.callbackrunning)
    firstTime = 1;
    if isfield(userdata,'function')
        if isfield(userdata.function,'closing')
            if userdata.function.closing{1} == 1 && toc(userdata.function.closing{2})>2.5
                delete(hObject)
                return
            else
                firstTime = 0;
            end
        end
    end
        
    % If so store function name and variables and cancel other function
    userdata.function.name = mfilename;
    userdata.function.input = {hObject,event,h};
    if firstTime
        userdata.function.closing = {1,tic};
    end
    set(h.right.tabgroup,'Userdata',userdata)
    robot = java.awt.Robot;
    robot.keyPress(java.awt.event.KeyEvent.VK_ESCAPE);
    robot.keyRelease(java.awt.event.KeyEvent.VK_ESCAPE);
    return
end

delete(hObject)