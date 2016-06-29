function optFitting(jObject,event,h,option)
% optFitting - Callback for fitting under special conditions
%
%   syntax: optFitting(jObject,event,h,option)
%       jObject - Reference to java object
%       event   - structure recording button events
%       h       - structure holding references to StatSTEM interface
%       option  - String indicating the options ('test')
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
    userdata.function.input = {jObject,event,h,option};
    set(h.right.tabgroup,'Userdata',userdata)
    robot = java.awt.Robot;
    robot.keyPress(java.awt.event.KeyEvent.VK_ESCAPE);
    robot.keyRelease(java.awt.event.KeyEvent.VK_ESCAPE);
    return
end

tab = loadTab(h);
% Load fit options
usr = get(tab,'Userdata');
switch option
    case 'test'
        usr.fitOpt.model.test = jObject.isSelected;
end
% Update userdata
set(tab,'Userdata',usr)