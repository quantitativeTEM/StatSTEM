function outputIsInput(hObject,event,h)
% DisableBut - Button callback for making the fitted variables the input
% variables
%
%   syntax: outputIsInput(hObject,event,h)
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

% Check if button is enabled
if ~get(hObject,'Enabled')
    return
end

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

tab = loadTab(h);
if isempty(tab)
    h_mes = errordlg('First load an image');
    waitfor(h_mes)
    return
end

% Load image
usr = get(tab,'Userdata');
input = usr.file.input;

% Try to get output
if ~any(strcmp(fieldnames(usr.file),'output'))
    h_mes = errordlg('First fit an image');
    waitfor(h_mes)
    return
end
output = usr.file.output;

% Make the fitted coordinates the new input coordinates, and store the
% fitted rho
input.coordinates = [output.coordinates input.coordinates(:,3)];
types = max(input.coordinates(:,3));
usr.fitOpt.model.rho_start = zeros(types,1);
for i = 1:types
    rho_temp = output.rho(input.coordinates(:,3) == i);
    usr.fitOpt.model.rho_start(i)= median(rho_temp);
end
if h.left.fit.panels.Width.UserBut.isSelected
    input.rho = usr.fitOpt.model.rho_start(input.coordinates(:,3)); % Make user selected
end

% Store new updated coordinates
usr.file.input = input;
set(tab,'Userdata',usr);

% Update figures
str = get(usr.figOptions.selImg.listbox,'String');
val = get(usr.figOptions.selImg.listbox,'Value');
data = get(usr.figOptions.selOpt.(['optionsImage',num2str(val)]),'Data');
if isempty(data)
    opt = [];
else
    opt = strcmp(data(:,2),'Input coordinates');
end
if any(opt)
    if data{opt,1}==true
        % Update image
        showImage(tab,str{val},h)
    end
end