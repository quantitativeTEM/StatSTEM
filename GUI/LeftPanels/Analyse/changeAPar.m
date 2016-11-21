function changeAPar(hObject,event,h,button2)
% changeAPar - Callback to change the parameters for finding the a-direction
%
%   syntax: changeAPar(hObject,event,h)
%       hObject - reference to button
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

%% Preparation of function
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

state = button2.isSelected;
hObject.setSelected(state);
button2.setSelected(~state);

% Load the selected tab
tab = loadTab(h);
if isempty(tab)
    h_mes = errordlg('First load an image');
    waitfor(h_mes)
    return
end
usr = get(tab,'Userdata');
if ~any(strcmp(fieldnames(usr.file),'output'))
    return
end

% Delete previous analysis is necessary
if any(strcmp(fieldnames(usr.file.strainmapping),'teta'))
    quest = questdlg('Changing the fitting parameters for finding a new a lattice direction will remove all previous strain mapping results, continue?','Warning','Yes','No','No');
    drawnow; pause(0.05); % MATLAB hang 2013 version
    switch quest
        case 'Yes'
            deleteStrainMapping(tab,h,'Ref strainmapping')
            usr = get(tab,'Userdata');
        case 'No'
            set(hObject,'Selected',~state);
            set(button2,'Selected',state);
            return
    end
end