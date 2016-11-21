function runAtomCounting(hObject,event,h)
% runAtomCounting - Callback to perform atomcounting of fitted model
%
%   syntax: runAtomCounting(hObject,event,h)
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

tab = loadTab(h);
if isempty(tab)
    h_mes = errordlg('First load an image');
    waitfor(h_mes)
    return
end

%% Preparation
% Delete previous analysis is necessary
usr = get(tab,'Userdata');
if any(strcmp(fieldnames(usr.file),'atomcounting'))
    quest = questdlg('Running the ICL will remove previous statistical atom counting results, continue?','Warning','Yes','No','No');
    drawnow; pause(0.05); % MATLAB hang 2013 version
    switch quest
        case 'Yes'
            deleteAtomCounting(tab,h)
            usr = get(tab,'Userdata');
        case 'No'
            return
    end
end

% Get fitted results
output = usr.file.output;

% Select coordinates (by type), selected by user
type = usr.fitOpt.atom.selType;
if ~isempty(type)
    in = usr.file.input.coordinates(:,3)==type;
    atomcounting.coordinates = output.coordinates(in,1:2);
    atomcounting.volumes = output.volumes(in);
    atomcounting.selType = type;
else
    atomcounting.coordinates = output.coordinates(:,1:2);
    atomcounting.volumes = output.volumes(:);
    atomcounting.selType = [];
end

% Select coordinates (from images), selected by user
selRegion = usr.fitOpt.atom.selCoor;
if ~isempty(selRegion)
    in = inpolygon(atomcounting.coordinates(:,1), atomcounting.coordinates(:,2), selRegion(:,1), selRegion(:,2));
    atomcounting.coordinates = atomcounting.coordinates(in,:);
    atomcounting.volumes = atomcounting.volumes(in);
    atomcounting.selRegion = selRegion;
end

% Select coordinates (from histogram), selected by user
low = usr.fitOpt.atom.minVol;
high = usr.fitOpt.atom.maxVol;
if ~isempty(low)
    in = atomcounting.volumes>low & atomcounting.volumes<high;
    atomcounting.coordinates = atomcounting.coordinates(in,:);
    atomcounting.volumes = atomcounting.volumes(in);
    atomcounting.minVol = low;
    atomcounting.maxVol = high;
end

% Save the total number of volumes that will be evaluated
atomcounting.N = length(atomcounting.volumes);

% Set the offset for the atomcounts to zero
atomcounting.offset = 0;
% Also in GUI
set(h.left.ana.panel.atomAdv.offset,'Text','0')

% Create field for ICL
atomcounting.ICL = [];
% Create new field
usr.file.atomcounting = atomcounting;
% Update userdata
set(tab,'Userdata',usr);

% Create figure for ICL
createICL(tab,h,1)
usr = get(tab,'Userdata');

% Reference to waitbar
h_bar = h.right.progress.jBar;

% Reference to axes ICL figure
% First add the figure name to the current list of figures
str = get(usr.figOptions.selImg.listbox,'String');
val = find(strcmp(str,'ICL'));
ax = usr.images.ax;

%% Disable all buttons
hfUS.fitting = 1;
set(h.fig,'Userdata',hfUS);
updateLeftPanels(h,[],usr.fitOpt)

% The disable button
hObject.setEnabled(false)
usr.file.atomcounting = atomcounting;
% Update userdata
set(tab,'Userdata',usr);

%% Make all text field in preparation panel unfocusable
focusFields(h,false)

%% Fit GMM
n_c = usr.fitOpt.atom.n_c;
% Check if n_c is not equal to or exceeding the number of columns
if n_c>=length(atomcounting.volumes)
    n_c = length(atomcounting.volumes)-1;
    if n_c==0
        message = sprintf(['ICL on ', usr.FileName,' cannot be executed, more than 1 column needs to be evaluated']);
        errordlg(message)
        deleteAtomCounting(tab,h)
        % Enable button again
        hObject.setEnabled(true)
        % Display message
        newMessage(message,h)
        return
    else
        message = sprintf(['ICL on ', usr.FileName,' : The maximum number of components is limited to the number of columns that will be evaluated']);
        % Display message
        newMessage(message,h)
    end
end
usr.fitOpt.atom.n_c = n_c;

% Display message
message = sprintf(['ICL is running on: ', usr.FileName]);
newMessage(message,h)

% Enable the abort button
AbortBut = h.left.ana.panel.atom.AbortBut;
EnableBut(AbortBut,event,h)

[atomcounting,abort] = fitGMM(ax,atomcounting,n_c,h_bar,AbortBut);

% Wait until fitting is finished
usr.file.atomcounting = atomcounting;
set(tab,'Userdata',usr);

% Disable the abort button
DisableBut(AbortBut,event,h)
AbortBut.setToolTipText('')

message = sprintf(['ICL has finished running on: ', usr.FileName]);
if abort==1
    if length(usr.file.atomcounting.ICL)>1
        quest = questdlg('The ICL is cancelled, select minimum in the current figure?','Warning','Yes','No','No');
        drawnow; pause(0.05); % MATLAB hang 2013 version
        if strcmp(quest,'Yes')
            abort = 0;
        end
    end
elseif abort==2
    quest = questdlg(['Cannot fit more than ',num2str(length(usr.file.atomcounting.ICL)),' components, select minimum in the current figure?'],'Warning','Yes','No','No');
    drawnow; pause(0.05); % MATLAB hang 2013 version
    if strcmp(quest,'Yes')
        abort = 0;
    end
end

if abort
    message = sprintf(['ICL on ', usr.FileName,' has been cancelled']);
    deleteAtomCounting(tab,h)
    usr = get(tab,'Userdata');
    % Enable button again
    hObject.setEnabled(true)
    % Display message
    newMessage(message,h)

    % Make all text field in preparation panel focusable
    focusFields(h,true)
    
    % Now update left panels;
    set(h.fig,'Userdata',[]);
    updateLeftPanels(h,usr.file,usr.fitOpt)
    return
end

% Update userdata
set(tab,'Userdata',usr);

% Display message
newMessage(message,h)

%% Select minimum
% If other figure is shown, return to this figure and cancel the routine
% running there
evt.OldValue = get(h.right.tabgroup,'SelectedTab');
if tab ~= evt.OldValue
    set(h.right.tabgroup,'SelectedTab',tab)
    evt.NewValue = tab;
    fileChanged(h.right.tabgroup,evt,h)
end

% Image preparation, show ICL
ind = get(usr.figOptions.selImg.listbox,'Value');
str = get(usr.figOptions.selImg.listbox,'String');
value = find(strcmp(str,'ICL'));
if value~=ind
    showImage(tab,'ICL',h)
    usr = get(tab,'Userdata');
end

[h_pan,h_zoom,h_cursor] = turnOffFigureSelection(h);
title(ax,'Select the minimum of interest in the ICL')
[x,~] = ginput_AxInFig(ax,h.fig,h_pan,h_zoom,h_cursor);
if isempty(x)
    x = 1;
end
usr.file.atomcounting.selMin = round(x);
if usr.file.atomcounting.selMin<1
    usr.file.atomcounting.selMin = 1;
elseif usr.file.atomcounting.selMin>length(usr.file.atomcounting.ICL)
    usr.file.atomcounting.selMin = length(usr.file.atomcounting.ICL);
end
title(ax,'')

% Update userdata
set(tab,'Userdata',usr);

% Make all text field in preparation panel focusable
focusFields(h,true)

% Plot and add reference to selected minimum in figure
addMinICL(tab,1,h)

%% Now determine the number of atoms per column and the GMM
usr.file.atomcounting = getAtomCounts(usr.file.atomcounting);
% Calculate the single atom sensitivity
sens = sengleatomsensivity(usr.file.atomcounting,1);
message = ['Selected ICL minimum: ',num2str(usr.file.atomcounting.selMin),' - atom counting results obtained with ',num2str(sens(1)*100),'%% single atom sensitivity'];
newMessage(message,h)
% Update userdata
set(tab,'Userdata',usr);

%% Create figures
% Create new figure for SI vs thickness
createThickSI(tab,h,0)
% usr = get(tab,'Userdata');

%% Update other figures
% The histogram, add GMM
createGMM(tab,1)
% usr = get(tab,'Userdata');

% The atom counts (show atom counting results in observation)
createAtomCounts(tab,h,1)
usr = get(tab,'Userdata');

% Update userdata
set(tab,'Userdata',usr);

% Now update left panels;
set(h.fig,'Userdata',[]);
updateLeftPanels(h,usr.file,usr.fitOpt)
end