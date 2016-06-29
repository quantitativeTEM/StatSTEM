function editRho(hObject,event,h)
% DisableBut - Button callback for editing rho values
%
%   syntax: editRho(hObject,event,h)
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
    % First turn off zoom, pan and datacursor
	turnOffFigureSelection(h);
    % If so store function name and variables and cancel other function
    userdata.function.name = mfilename;
    userdata.function.input = {hObject,event,h};
    set(h.right.tabgroup,'Userdata',userdata)
    robot = java.awt.Robot;
    robot.keyPress(java.awt.event.KeyEvent.VK_ESCAPE);
    robot.keyRelease(java.awt.event.KeyEvent.VK_ESCAPE);
    return
end

% Check if button is enabled
if ~get(hObject,'Enabled')
    return
end

tab = loadTab(h);
if isempty(tab)
    h_mes = errordlg('First load an image');
    waitfor(h_mes)
    return
end

% Load image values
usr = get(tab,'Userdata');
input = usr.file.input;
rho = usr.fitOpt.model.rho_start;
types = input.types;

% Get position GUI, to center dialog
pos = get(h.fig,'Position');

% Edit (or view) rho
rho = defineRho(input,'Types',types,'Rho',rho,'Center',[pos(1)+pos(3)/2 pos(2)+pos(4)/2]);

% Check if rho is modified
if isempty(rho)
    return
end

usr.fitOpt.model.rho_start = rho;
% Check if manual width is selected
if h.left.fit.panels.Width.UserBut.isSelected
    usr.file.input.rho = rho(usr.file.input.coordinates(:,3));
end

% Update file in GUI
set(tab,'Userdata',usr)

