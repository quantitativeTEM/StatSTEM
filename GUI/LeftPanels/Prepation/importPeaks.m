function importPeaks(hObject,event,h)
% importPeaks - Callback for importing peak locations
%
%   syntax: importPeaks(hObject,event,h)
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

% Check if colorbar is shown
if strcmp(get(h.colorbar(1),'State'),'off')
    sColBar = 0;
else
    sColBar = 1;
end

% Ask to remove model and analysis if necessary
string = 'Loading peak locations will erase the fitted model and all analysis, continue?';
[quest,usr] = removeQuestionPrep(tab,h,string);
if strcmp(quest,'No')
    return
end
input = usr.file.input;

%% Load the user coordinates
% Let the user select a file
[FileName,userdata.PathName] = uigetfile({'*.mat;*.txt;*.TXT','Supported Files (*.mat, *.txt)';'*.mat','MATLAB Files (*.mat)';'*.txt;*.TXT','TEXT Files (*.txt)';'*.*',  'All Files (*.*)'}, ...
   'Select a file',userdata.PathName);

if FileName==0
    return
else
    % Update userdata
    set(h.right.tabgroup,'Userdata',userdata)
end
[~, FileName, ext] = fileparts(FileName);
switch ext
    case '.mat'
        file = load([userdata.PathName,FileName,ext]);
        names = fieldnames(file);
        opt = 1;
        if any(strcmp(names,'input'))
            names2 = fieldnames(file.input);
            if ~any(strcmp(names2,'coordinates'))
                h_mes = errordlg('Make sure input file contains input coordinates');
                waitfor(h_mes)
                return
            end
            
            if  any(strcmp(names,'output'))
                names2 = fieldnames(file.output);
                if any(strcmp(names2,'coordinates'))
                    coorq = questdlg('Which coordinates should be used, input or fitted coordinates?','Loading coordinates','input','fitted','fitted');
                    drawnow; pause(0.05); % MATLAB hang 2013 version
                    waitfor(coorq)
                    if strcmp(coorq,'fitted')
                        opt = 2;
                    end
                end
            end
            
            % Add type if not yet added
            if size(file.input.coordinates,2)==2
                file.input.coordinates(:,3) = 1;
            end
            % Load coordinates
            if opt==2
                input.coordinates = [file.output.coordinates file.input.coordinates(:,3)];
            else
                input.coordinates = file.input.coordinates;
            end
        elseif length(names)>1
            h_mes = errordlg('Make sure input file contains input coordinates in a 2-by-n array');
            waitfor(h_mes)
            return
        else
            input.coordinates = file.(names{1});
        end
    case '.txt'
        input.coordinates = dlmread([userdata.PathName,FileName,ext]);
        if isempty(input.coordinates)
            h_mes = errordlg('Make sure input file contains coordinates in a 2-by-n array');
            waitfor(h_mes)
            return
        elseif size(input.coordinates,1)>2 && size(input.coordinates,2)>2
            h_mes = errordlg('Make sure input file contains coordinates in a 2-by-n array');
            waitfor(h_mes)
            return
        end
    otherwise
        h_mes = errordlg('File Type not supported');
        waitfor(h_mes)
        return
end

% Shift column positions
input.coordinates(:,1) = input.coordinates(:,1);
input.coordinates(:,2) = input.coordinates(:,2);

% Check if atom types are specified
if ~isempty(input.coordinates)
    if size(input.coordinates,2)==2
        input.coordinates(:,3) = 1;
    end
end

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
            showHideFigOptions(tab,value,data{n,2},~state,h,sColBar)
        end
        showHideFigOptions(tab,value,data{n,2},state,h,sColBar)
        data{n,1} = state;
    end
end

% Update state of left panel
updateLeftPanels(h,usr.file,usr.fitOpt)

% Display message
message = sprintf(['The file ', FileName, ' was successfully loaded']);
newMessage(message,h)