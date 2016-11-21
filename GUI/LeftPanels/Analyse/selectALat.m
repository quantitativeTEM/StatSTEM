function selectALat(hObject,event,h)
% selectALat - Select in StatSTEM the a direction manually
%
%   syntax: selectALat(hObject,event,h)
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

% First turn off zoom, pan and datacursor
[h_pan,h_zoom,h_cursor] = turnOffFigureSelection(h);

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

% Select the correct radio button
h.left.ana.panel.strainAdv.usrALat.setSelected(true);
h.left.ana.panel.strainAdv.autALat.setSelected(false);

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
    if any(strcmp(fieldnames(usr.file.strainmapping),'teta'))
        quest = questdlg('Finding a new a lattice direction will remove all previous strain mapping results, continue?','Warning','Yes','No','No');
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

%% Use and store selected coordinates by user
if ~isempty(usr.fitOpt.strain.selCoor)
    in = inpolygon(usr.file.output.coordinates(:,1), usr.file.output.coordinates(:,2), usr.fitOpt.strain.selCoor(:,1), usr.fitOpt.strain.selCoor(:,2));
    coor_in = usr.file.output.coordinates(in,:);
else
    in = [];
    coor_in = usr.file.output.coordinates;
end
usr.file.strainmapping.coor_sel = coor_in;
set(tab,'Userdata',usr);

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

% Make sure fitted coordinates are shown and reference coordinate
data = get(usr.figOptions.selOpt.(['optionsImage',num2str(val)]),'Data');
nameTag = 'Coor strainmapping';
ind = strcmp(data(:,2),nameTag);
if ~any(ind)
    nameTag = 'Fitted coordinates';
    ind = strcmp(data(:,2),nameTag);
end
N = find(ind);
for n=1:length(ind)
    if n==N
        state = true;
    else
        state = false;
    end
    if data{n,1}~=state
        showHideFigOptions(tab,val,data{n,2},state,h,sColBar)
        data{n,1} = state;
    end
end
nameTag = 'Ref strainmapping';
ind = strcmp(data(:,2),nameTag);
N = find(ind);
showHideFigOptions(tab,val,data{N,2},true,h,sColBar)
data{N,1} = true;
set(usr.figOptions.selOpt.(['optionsImage',num2str(val)]),'Data',data);

% Make coordinates of other types unvisible
type = get(h.left.ana.panel.strainAdv.selType,'SelectedIndex')+1; % Java index
coorDat = get(usr.images.ax,'Userdata');
indDat = strcmp(coorDat(:,1),nameTag);
coorRef = coorDat{indDat,2};
for n=1:length(coorRef)
    if n==type
        state = 'On';
    else
        state = 'Off';
    end
    set(coorRef(n),'Visible',state)
end

%% Select coordinate
userdata = get(h.right.tabgroup,'Userdata');
userdata.callbackrunning = true; % For peak location routines
set(h.right.tabgroup,'Userdata',userdata);
title(usr.images.ax,'Select coordinate in a-direction with respect to reference coordinate, press ESC to exit')
[x,y] = ginput_AxInFig(usr.images.ax,h.fig,h_pan,h_zoom,h_cursor);
% Update userdata
userdata = get(h.right.tabgroup,'Userdata');
userdata.callbackrunning = false; % For peak location routines
set(h.right.tabgroup,'Userdata',userdata);
title(usr.images.ax,'')

% Make coordinates of other types visible again
for n=1:length(coorRef)
    set(coorRef(n),'Visible','On')
end

if isempty(x) % Do not update GUI figures
    return
end

%% Determine angle
if ~isempty(in)
    indT = usr.file.input.coordinates(in,3)==type;
else
    indT = usr.file.input.coordinates(:,3)==type;
end
coorT = usr.file.strainmapping.coor_sel(indT,1:2);
distance = (coorT(:,1)-x).^2+(coorT(:,2)-y).^2;
indM = find(distance==min(distance));
coor_int = coorT(indM(1),:);
coor_ref = usr.file.strainmapping.refCoor;
aDir = coor_int-coor_ref;
teta = atan2(aDir(2),aDir(1));
try
    dirTeta = guessDirAngleB(coorT,coor_ref,aDir,usr.file.input.projUnit.b,usr.file.input.projUnit.ang,0);
catch ME
    % Get position GUI, to center dialog
    pos = get(h.fig,'Position');
    cent = [pos(1)+pos(3)/2,pos(2)+pos(4)/2];
    % Show error
    % Check whether error is unknown (MATLAB error)
    if strcmp(ME.message(1:6),'Error:')
        n1 = strfind(ME.message,'File:');
        n2 = strfind(ME.message,'</a>');

        errMes = ['Error in script: ',ME.message(n1+6:n2-1),ME.message(n2+4:end)];
    else
        errMes = ME.message;
    end
    h_err = errordlg(errMes,'Error');
    set(h_err,'Units','pixels','Visible','off')
    s = get(h_err,'Position');
    set(h_err,'Position',[cent(1)-s(3)/2 cent(2)-s(4)/2 s(3) s(4)],'Visible','on')
    return
end

% Improve by fitting if wanted
[teta,e_teta,a,e_a,b,e_b] = impByFittingUC(usr,h,coorT,teta,dirTeta);
usr.file.strainmapping.teta = [teta,e_teta];
usr.file.strainmapping.a = [a,e_a];
usr.file.strainmapping.b = [b,e_b];
usr.file.strainmapping.dir_teta_ab = dirTeta;

set(tab,'Userdata',usr)

%% Add position of reference coordinate to image options
data = get(usr.figOptions.selOpt.(['optionsImage',num2str(val)]),'Data');
nameTag = 'a & b lattice';
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