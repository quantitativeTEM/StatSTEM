function deletePeaks(hObject,event,h)
% changePeaks - Callback for deleting peak locations manually
%
%   syntax: deletePeaks(hObject,event,h)
%       hObject - Reference to button
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

% First turn off zoom, pan and datacursor
[h_pan,h_zoom,h_cursor] = turnOffFigureSelection(h);

% Check if no other routine is running
userdata = get(h.right.tabgroup,'Userdata');
if (userdata.callbackrunning)
    % Is so store function name and variables and cancel other function
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

% Turn off all editing in the figure
plotedit(h.fig,'off')

tab = loadTab(h);
if isempty(tab)
    h_mes = errordlg('First load an image');
    waitfor(h_mes)
    return
end

% Show warning that deletion of peaks will remove the fitted model and
% possible analysis
string = 'Removing column positions in a specific region will erase the fitted model and all analysis, continue?';
[quest,usr] = removeQuestionPrep(tab,h,string);
if strcmp(quest,'No')
    return
end
input = usr.file.input;

%% Image preparation
str = get(usr.figOptions.selImg.listbox,'String');
val = get(usr.figOptions.selImg.listbox,'Value');
value = find(strcmp(str,'Observation'));

% Show observation
if val~=value
    showImage(tab,'Observation',h)
    usr = get(tab,'Userdata');
end

% Make sure only input coordinates are shown
data = get(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data');
nameTag = 'Input coordinates';
ind = strcmp(data(:,2),nameTag);
N = find(ind);
for n=1:length(ind)
    if n==N
        state = true;
    else
        state = false;
    end
    if data{n,1}~=state || state==true
        if state
            showHideFigOptions(tab,value,data{n,2},~state,h,sColBar)
        end
        showHideFigOptions(tab,value,data{n,2},state,h,sColBar)
        data{n,1} = state;
    end
end
%Update data
set(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data',data)

%% Make all text field in preparation panel unfocusable
focusFields(h,false)

%% Select axis
axis(usr.images.ax);
hold on;

userdata = get(h.right.tabgroup,'Userdata');
userdata.callbackrunning = true; % For peak location routines
set(h.right.tabgroup,'Userdata',userdata);
title(usr.images.ax,'Select region, press ESC to exit')
coor = gregion_AxInFig(usr.images.ax,h.fig,h_pan,h_zoom,h_cursor);
hold off;
title(usr.images.ax,'')
userdata = get(h.right.tabgroup,'Userdata');
userdata.callbackrunning = false; % For peak location routines
set(h.right.tabgroup,'Userdata',userdata);
% Update coordinates
if ~isempty(coor)
    in = inpolygon(input.coordinates(:,1),input.coordinates(:,2),coor(:,1),coor(:,2));
    input.coordinates = input.coordinates(~in,:);
    % Store new coordinates
    usr.file.input = input;
    set(tab,'Userdata',usr);
    % Update figure
    showHideFigOptions(tab,value,nameTag,false,h,sColBar)
    showHideFigOptions(tab,value,nameTag,true,h,sColBar)
end

%% Update all parts of the GUI
usr = get(tab,'Userdata');

% Make all text field in preparation panel focusable
focusFields(h,true)

% Check if other function is started
if ~isempty(userdata.function)
    f = userdata.function;
    userdata.function = [];
    set(h.right.tabgroup,'Userdata',userdata);
    eval([f.name,'(f.input{:})'])
    if strcmp(f.name,'deleteFigure')
        return
    end
end

% Update left panels
usr = get(tab,'Userdata');
updateLeftPanels(h,usr.file,usr.fitOpt)