function loadFile(hObject,event,h)
% loadFile - Load a file into the StatSTEM interface
%
%   syntax: loadFile(hObject,event,h)
%       hObject - Reference to button
%       event   - structure recording button events
%       h       - structure holding references to GUI interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Check if no other routine is running
userdata = get(h.right.tabgroup,'Userdata');
if (userdata.callbackrunning)
    % If so store function name and variables and cancel other function
    userdata.function.name = mfilename;
    userdata.function.input = {hObject,event,h};
    set(h.right.tabgroup,'Userdata',userdata)
    robot = java.awt.Robot;
    robot.keyPress(java.awt.event.KeyEvent.VK_ESCAPE);
    robot.keyRelease(java.awt.event.KeyEvent.VK_ESCAPE);
    return
end

% Load reference to adding tab
tabs = get(h.right.tabgroup,'Children');
tab = tabs(length(tabs));
usr = get(tab,'Userdata');

% Make sure not a second function will run, Update userdata
userdata.callbackrunning = true;
userdata.loadingNewFile = true;
set(h.right.tabgroup,'Userdata',userdata)

% Let the user select an input file
[file,message] = loadStatSTEMfile();

if isempty(file)
    newMessage(message,h)
    
    %% Update userdata and restore functions
    userdata = get(h.right.tabgroup,'Userdata');
    userdata.callbackrunning = false; 
    userdata = rmfield(userdata,'loadingNewFile');
    set(h.right.tabgroup,'Userdata',userdata);
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
    return
end

% Update the name of the tab
if length(file.input.name)>18
    tabName = [file.input.name(1:15),'...'];
else
    tabName = file.input.name;
end
set(tab,'Title',tabName)      

%% The empty tab will be used to load the file to
% Create listboxs for selecting which figure is shown
usr.figOptions.selImg.listbox = uicontrol('Parent',usr.figOptions.selImg.main,'Style','listbox','units','normalized','Position',[0 0 1 1],'String',{},'CallBack',{@imageChanged,tab,h});

% Update userdata of tab
set(tab,'Userdata',usr);

% Load file into StatSTEM
set(h.right.tabgroup,'SelectedTab',tab)
updateStatSTEM(h,file)
usr = get(tab,'Userdata');

% Update the tab
set(tab,'ButtonDown',[]);
v = version('-release');
v = str2double(v(1:4));
c = uicontextmenu;
m1 = uimenu(c,'Label','Close image','Callback',{@closeImage,tab,h});
set(tab,'UIContextMenu',c);
if v>2014
    set(tab,'TooltipString',file.input.name);
end

% Update the userdata of the tab

% Enable the store button
set(h.left.loadStore.save,'Enable','on')

% Add a new empty tab
createEmptyTab(h.right.tabgroup)

% Enable color button
set(usr.figOptions.optFig.colors,'Callback',{@editColors,h},'Enable','on')

% Enable export button
set(usr.figOptions.export.but,'Callback',{@exportFigure,h},'Enable','on')

% Update message
message = sprintf(['The file ', file.input.name, ' was successfully loaded']);
newMessage(message,h)

%% Update userdata and restore functions
userdata = get(h.right.tabgroup,'Userdata');
userdata.callbackrunning = false; 
userdata = rmfield(userdata,'loadingNewFile');
set(h.right.tabgroup,'Userdata',userdata);
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