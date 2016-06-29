function enableBack(jObject,event,h)
% enableBack - Button callback for using user-defined background value
%
%   syntax: enableBack(jObject,event,h)
%       jObject - Reference to button
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

tab = loadTab(h);
% Load fit options
usr = get(tab,'Userdata');
if jObject.isSelected
    set(h.left.fit.panels.Back.Val,'Text','Automatic')
    % Disable background value
    h.left.fit.panels.Back.Val.setEnabled(false)
    % Disable button to select background value
    h.left.fit.panels.Back.SelBut.setEnabled(false)
    usr.fitOpt.model.fitzeta = 1;
else
    if usr.fitOpt.model.zeta==0
        dg = 1;
    else
        temp = usr.fitOpt.model.zeta*10.^(1:20);
        %Number of digits voor string
        dg = find(temp==round(temp),1)+floor(log10(abs(usr.fitOpt.model.zeta)))+1;
    end
    
    % Update background value
    set(h.left.fit.panels.Back.Val,'Text',num2str(usr.fitOpt.model.zeta,dg))
    % Enable background value
    h.left.fit.panels.Back.Val.setEnabled(true)
    % Enable button to select background value
    h.left.fit.panels.Back.SelBut.setEnabled(true)
    usr.fitOpt.model.fitzeta = 0;
end
% Update userdata
set(tab,'Userdata',usr)