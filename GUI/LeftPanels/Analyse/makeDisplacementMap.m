function makeDisplacementMap(hObject,event,h)
% makeDisplacementMap - Make a displacement map in StatSTEM
%
%   syntax: makeDisplacementMap(hObject,event,h)
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

% Check if colorbar is shown
if strcmp(get(h.colorbar(1),'State'),'off')
    sColBar = 0;
else
    sColBar = 1;
end

tab = loadTab(h);
if isempty(tab)
    h_mes = errordlg('First load an image');
    waitfor(h_mes)
    return
end
usr = get(tab,'Userdata');

%% Preparation
% Delete previous analysis is necessary
if any(strcmp(fieldnames(usr.file),'strainmapping'))
    if any(strcmp(fieldnames(usr.file.strainmapping),'coor_relaxed'))
        quest = questdlg('Making a new displacement map will remove all previous strain mapping results, continue?','Warning','Yes','No','No');
        drawnow; pause(0.05); % MATLAB hang 2013 version
        switch quest
            case 'Yes'
                % Maintain reference coordinate
                deleteStrainMapping(tab,h,'Ref strainmapping')
                usr = get(tab,'Userdata');
            case 'No'
                return
        end
    end
end

% Check if a reference coordinate is already generated, if not find it
findRef = 1;
if any(strcmp(fieldnames(usr.file),'strainmapping'))
    if any(strcmp(fieldnames(usr.file.strainmapping),'refCoor'))
        findRef = 0;
    end
end
if findRef
    useC = h.left.ana.panel.strainAdv.cenCoor.isSelected;
    if useC
        cenCoorGUI(h.left.ana.panel.strainAdv.cenCoor,event,h)
    else
        usrCoorGUI(h.left.ana.panel.strainAdv.usrCoor,event,h)
    end
    usr = get(tab,'Userdata');
end
% Hide reference coordinate
val = get(usr.figOptions.selImg.listbox,'Value');
data = get(usr.figOptions.selOpt.(['optionsImage',num2str(val)]),'Data');
ind = strcmp(data(:,2),'Ref strainmapping');
if any(ind)
    data{ind,1} = false;
    set(usr.figOptions.selOpt.(['optionsImage',num2str(val)]),'Data',data)
    showHideFigOptions(tab,val,data{ind,2},false,h,sColBar)
end


% Check if the a lattice direction is already found, if not find it
findA = 1;
if any(strcmp(fieldnames(usr.file),'strainmapping'))
    if any(strcmp(fieldnames(usr.file.strainmapping),'teta'))
        findA = 0;
    end
end
if findA
    aut = h.left.ana.panel.strainAdv.autALat.isSelected;
    if aut
        findALatAutomatic(h.left.ana.panel.strainAdv.showALatAut,event,h)
    else
        selectALat(h.left.ana.panel.strainAdv.selectALat,event,h)
    end
    usr = get(tab,'Userdata');
end
% Hide reference coordinate
val = get(usr.figOptions.selImg.listbox,'Value');
data = get(usr.figOptions.selOpt.(['optionsImage',num2str(val)]),'Data');
ind = strcmp(data(:,2),'a & b lattice');
if any(ind)
    data{ind,1} = false;
    set(usr.figOptions.selOpt.(['optionsImage',num2str(val)]),'Data',data)
    showHideFigOptions(tab,val,data{ind,2},false,h,sColBar)
else
    % An error has occured
    return
end

%% With the found angle find the relaxed coordinates
coor_in = usr.file.strainmapping.coor_sel;
% coor_in = usr.file.input.coordinates(:,1:2);
dist = (coor_in(:,1)-usr.file.strainmapping.refCoor(1,1)).^2 + (coor_in(:,2)-usr.file.strainmapping.refCoor(1,2)).^2;
ind = dist==min(dist);
refCoor = coor_in(ind,1:2);
[coor_ref,types,indices] = STEMdisplacement(coor_in,refCoor,usr.file.input.projUnit,usr.file.strainmapping.teta(1),usr.file.strainmapping.a(1),usr.file.strainmapping.b(1),usr.file.strainmapping.dir_teta_ab);

usr.file.strainmapping.coor_relaxed = coor_ref;
usr.file.strainmapping.types = types;
usr.file.strainmapping.indices = indices;

%% Update StatSTEM
set(tab,'Userdata',usr)

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

% Add displacement map to the figure options
data = get(usr.figOptions.selOpt.(['optionsImage',num2str(val)]),'Data');
nameTag = 'Displacement map';
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