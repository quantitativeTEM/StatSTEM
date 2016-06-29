function RunPeakFinder(hObject,event,h)
% RunPeakFinder - Callback for running a peak finder routine
%
%   syntax: RunPeakFinder(hObject,event,h)
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

% Check if button is enabled
if ~get(hObject,'Enabled')
    return
end

% First check if no other routine is running
userdata = get(h.right.tabgroup,'Userdata');
if (userdata.callbackrunning)
    % First turn off zoom, pan and datacursor
    turnOffFigureSelection(h);
    % Is so store function name and variables and cancel other function
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

% Ask to remove model and analysis if necessary
string = 'Running the peak finder routine will erase the fitted model and all analysis, continue?';
[quest,usr] = removeQuestionPrep(tab,h,string);
if strcmp(quest,'No')
    return
end
input = usr.file.input;

%% Run automatic peak finding routine
[betaX,betaY] = peakFinder(input.obs,usr.fitOpt.peakfinding);

input.coordinates = [betaX betaY]*input.dx;
input.coordinates(:,3) = ones(length(betaX),1);

%% Update GUI
% Update file in GUI 
usr.file.input = input;
set(tab,'Userdata',usr)


%% Update image
str = get(usr.figOptions.selImg.listbox,'String');
val = get(usr.figOptions.selImg.listbox,'Value');
value = find(strcmp(str,'Observation'));

% Make sure only input coordinates are shown
data = get(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data');
nameTag = 'Input coordinates';
ind = strcmp(data(:,2),nameTag);
data_int = data;
data_int(ind,1) = {true};
data_int(~ind,1) = {false};
%Update data
set(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data',data_int)

% Show observation
if val~=value
    showImage(tab,'Observation',h)
    usr = get(tab,'Userdata');
    data = data_int;
end

% Update plotted coordinates
N = find(ind);
for n=1:length(ind)
    if n==N
        state = true;
    else
        state = false;
    end
    if data{n,1}~=state || state==true
        if state
            showHideFigOptions(tab,value,data{n,2},~state)
        end
        showHideFigOptions(tab,value,data{n,2},state)
        data{n,1} = state;
    end
end

%% Update state of left panel
updateLeftPanels(h,usr.file,usr.fitOpt)
