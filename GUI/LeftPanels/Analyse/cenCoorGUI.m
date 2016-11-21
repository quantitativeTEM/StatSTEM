function cenCoorGUI(hObject,event,h)
% cenCoorGUI - Find most central coordinate and store value in StatSTEM
%
%   syntax: cenCoorGUI(hObject,event,h)
%       hObject - reference to dropdownmenu
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

% Check if colorbar is shown
if strcmp(get(h.colorbar(1),'State'),'off')
    sColBar = 0;
else
    sColBar = 1;
end

% Select the correct radio button
h.left.ana.panel.strainAdv.cenCoor.setSelected(true);
h.left.ana.panel.strainAdv.usrCoor.setSelected(false);

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

%% Preparation
% Delete previous analysis is necessary
if any(strcmp(fieldnames(usr.file),'strainmapping'))
    if any(strcmp(fieldnames(usr.file.strainmapping),'coor_relaxed'))
        quest = questdlg('Finding a new reference coordinate will remove all previous strain mapping results, continue?','Warning','Yes','No','No');
    else
        quest = 'Yes';
    end
    drawnow; pause(0.05); % MATLAB hang 2013 version
    switch quest
        case 'Yes'
            deleteStrainMapping(tab,h)
            usr = get(tab,'Userdata');
        case 'No'
            return
    end
end

%% Find coordinate
% Get position GUI, to center dialog
pos = get(h.fig,'Position');
cent = [pos(1)+pos(3)/2,pos(2)+pos(4)/2];

% Determine type for which central coordinate must be found
type = get(h.left.ana.panel.strainAdv.selType,'SelectedIndex')+1; % Java index
ind = usr.file.input.coordinates(:,3)==type;
if ~any(ind)
    s = [450,100];
    h_err = errordlg(['Cannot determine most central coordinate, no atoms present of type ',usr.file.input.types{type}]);
    set(h_err,'Units','pixels','Position',[cent(1)-s(1)/2 cent(2)-s(2)/2 s(1) s(2)])
    % Display message
    message = sprintf(['Cannot determine most central coordinate, no atoms present of type ',usr.file.input.types{type}]);
    newMessage(message,h)
    return
end

% Select coordinates, selected by user
if ~isempty(usr.fitOpt.strain.selCoor)
    in = inpolygon(usr.file.output.coordinates(:,1), usr.file.output.coordinates(:,2), usr.fitOpt.strain.selCoor(:,1), usr.fitOpt.strain.selCoor(:,2));
    ind = in & ind;
end
usr.file.strainmapping.refCoor = findCentralCoor(usr.file.output.coordinates(ind,:));
set(tab,'Userdata',usr)

%% Image preparation
% Make sure observation or model is shown with reference coordinate
str = get(usr.figOptions.selImg.listbox,'String');
val = get(usr.figOptions.selImg.listbox,'Value');
value = find(strcmp(str,'Observation'));
value1 = find(strcmp(str,'Model'));

% Show observation if observation or model is not shown
if val~=value && val~=value1
    showImage(tab,'Observation',h)
    usr = get(tab,'Userdata');
    val = value;
elseif val==value1
    value1 = value;
end

% Add position of reference coordinate to image options
data = get(usr.figOptions.selOpt.(['optionsImage',num2str(val)]),'Data');
nameTag = 'Ref strainmapping';
ind = strcmp(data(:,2),nameTag);
if any(ind)
    showHideFigOptions(tab,val,data{ind,2},false,h,sColBar)
else
    % Add option to image options
    data = [data;{true, nameTag}];
    ind = strcmp(data(:,2),nameTag);
    set(usr.figOptions.selOpt.(['optionsImage',num2str(val)]),'Data',data);
    data2 = get(usr.figOptions.selOpt.(['optionsImage',num2str(value1)]),'Data');
    data2 = [data2;{false, nameTag}];
    set(usr.figOptions.selOpt.(['optionsImage',num2str(value1)]),'Data',data2);
end
showHideFigOptions(tab,val,data{ind,2},true,h,sColBar)

% Update panels
updateLeftPanels(h,usr.file,usr.fitOpt)

