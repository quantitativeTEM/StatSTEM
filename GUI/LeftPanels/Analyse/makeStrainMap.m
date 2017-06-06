function makeStrainMap(hObject,event,h)
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
    if any(strcmp(fieldnames(usr.file.strainmapping),'eps_xx'))
        quest = questdlg('Making a new strain map will remove all previous strain mapping results, continue?','Warning','Yes','No','No');
        drawnow; pause(0.05); % MATLAB hang 2013 version
        switch quest
            case 'Yes'
                % Maintain reference coordinate
                deleteStrainMapping(tab,h,'Displacement map')
                usr = get(tab,'Userdata');
            case 'No'
                return
        end
    end
end

% Hide reference coordinate and displacement map
val = get(usr.figOptions.selImg.listbox,'Value');
data = get(usr.figOptions.selOpt.(['optionsImage',num2str(val)]),'Data');
ind = strcmp(data(:,2),'Ref strainmapping');
if any(ind)
    data{ind,1} = false;
    set(usr.figOptions.selOpt.(['optionsImage',num2str(val)]),'Data',data)
    showHideFigOptions(tab,val,data{ind,2},false,h,sColBar)
end
ind = strcmp(data(:,2),'Displacement map');
if any(ind)
    data{ind,1} = false;
    set(usr.figOptions.selOpt.(['optionsImage',num2str(val)]),'Data',data)
    showHideFigOptions(tab,val,data{ind,2},false,h,sColBar)
end

%% Calculation
% Determine the strain values for all types
[eps_xx,eps_xy,eps_yy,omg_xy,err,errMes] = STEMstrain(usr.file.strainmapping.coor_sel,usr.file.strainmapping.coor_relaxed,usr.file.strainmapping.a(1),usr.file.strainmapping.b(1),usr.file.strainmapping.dir_teta_ab,usr.file.strainmapping.teta(1),usr.file.input.projUnit,usr.file.strainmapping.a(2),usr.file.strainmapping.b(2));

if ~isempty(errMes)
    newMessage(errMes,h)
else
    message = ['Strain map successfully generate for the file: ', usr.FileName];
    newMessage(message,h)
end

usr.file.strainmapping.eps_xx = eps_xx;
usr.file.strainmapping.eps_xy = eps_xy;
usr.file.strainmapping.eps_yy = eps_yy;
usr.file.strainmapping.omg_xy = omg_xy;
usr.file.strainmapping.errEps_xx = err.xx;
usr.file.strainmapping.errEps_xy = err.xy;
usr.file.strainmapping.errEps_yy = err.yy;
usr.file.strainmapping.errOmg_xy = err.xy;

%% Update StatSTEM
% Store output
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

% Add strain maps to the figure options
nameTags = cell(4,1);
nameTags{1,1} = [char(949),'_xx'];
nameTags{2,1} = [char(949),'_xy'];
nameTags{3,1} = [char(949),'_yy'];
nameTags{4,1} = [char(969),'_xy'];

data = get(usr.figOptions.selOpt.(['optionsImage',num2str(val)]),'Data');
data2 = get(usr.figOptions.selOpt.(['optionsImage',num2str(value1)]),'Data');
for n=1:4
    ind = strcmp(data(:,2),nameTags{n,1});
    if any(ind)
        showHideFigOptions(tab,val,data{ind,2},false,h,sColBar)
    else
        % Add option to image options
        data = [data;{n==1, nameTags{n,1}}];
        data2 = [data2;{false, nameTags{n,1}}];
    end
end
set(usr.figOptions.selOpt.(['optionsImage',num2str(val)]),'Data',data);
set(usr.figOptions.selOpt.(['optionsImage',num2str(value1)]),'Data',data2);
ind = strcmp(data(:,2),nameTags{1,1});
showHideFigOptions(tab,val,data{ind,2},true,h,1)

% Update panels
updateLeftPanels(h,usr.file,usr.fitOpt)
