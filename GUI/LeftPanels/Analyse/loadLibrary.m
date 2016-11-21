function loadLibrary(jObject,event,h)
% loadLibrary - Load a library of into the StatSTEM interface
%
% Load a library of scattering cross-sections in function of column
% thickness into the StatSTEM interface
%
%   syntax: loadLibrary(jObject,event,h)
%       jObject - Reference to object
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
    userdata.function.input = {jObject,event,h};
    set(h.right.tabgroup,'Userdata',userdata)
    robot = java.awt.Robot;
    robot.keyPress(java.awt.event.KeyEvent.VK_ESCAPE);
    robot.keyRelease(java.awt.event.KeyEvent.VK_ESCAPE);
    return
end

% Check if button is enabled
if ~get(jObject,'Enabled')
    return
end

%% Start function

% First let user select a file
[FileName,userdata.PathName] = uigetfile({'*.mat;*.txt;*.TXT','Supported Files (*.mat,*.txt)';'*.mat','MATLAB Files (*.mat)';'*.txt;*.TXT','TXT Files (*.txt)';'*.*',  'All Files (*.*)'}, ...
   'Select a file',userdata.PathName);

if FileName==0
    return
else
    % Update userdata
    set(h.right.tabgroup,'Userdata',userdata)
end

[~, FileName, ext] = fileparts(FileName);
message = '';
switch ext
    case '.mat'
        lib = load([userdata.PathName,FileName,ext]);
        names = fieldnames(lib);
        if length(names)==1
            lib = lib.(names{1});
        else
            errordlg('Invalid input structure')
            message = sprintf(['The file ', FileName, ' cannot be loaded, invalid input structure']);
        end
    case '.txt'
        lib = dlmread([userdata.PathName,FileName,ext]);
end

% Test if library has a correct input structure
if isempty(message)
    s = size(lib);
    if length(s)~=2 || min(s)>2 || min(s)==0
        errordlg('Invalid input structure')
        message = sprintf(['The file ', FileName, ' cannot be loaded, invalid input structure']);
    else
        if s(2)>s(1)
            lib = lib';
        end
        s = size(lib);
        if s(2)==1
            lib = [(1:length(lib))' lib];
        end
    end
end

% Check if an error has occured, if not continue
if isempty(message)
    message = sprintf(['The file ', FileName, ' was successfully loaded']);
    newMessage(message,h)
else
    newMessage(message,h)
    return
end

% Continue, load tab and userdata
tab = loadTab(h);
if isempty(tab)
    return
end
% Load image
usr = get(tab,'Userdata');
usr.PathName = userdata.PathName;

% Store library in input structure
usr.file.input.library = lib;
set(tab,'Userdata',usr)

% Update figure if possible
str = get(usr.figOptions.selImg.listbox,'String');
value = find(strcmp(str,'SCS vs. Thickness'));
nameTag = 'Library';
if ~isempty(value)
    data = get(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data');
    if isempty(data)
        data = {true,nameTag};
        set(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data',data);
    else
        ind = strcmp(data(:,2),nameTag);
        if data{ind,1}
            deleteImageObject(usr.images.ax,nameTag)
        else
            data{ind,1} = true;
            set(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data',data);
        end
    end
    val = get(usr.figOptions.selImg.listbox,'Value');
    if val==value
        plotLib(usr.images.ax,usr.file.input.library,nameTag);
    end
end
set(tab,'Userdata',usr)
% Update left panel
updateLeftPanels(h,usr.file,usr.fitOpt)