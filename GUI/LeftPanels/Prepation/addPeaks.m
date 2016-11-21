function addPeaks(hObject,event,h)
% addPeaks - Callback for adding peak locations manually
%
%   syntax: addPeaks(hObject,event,h)
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

% Turn off all editing in the figure
plotedit(h.fig,'off')

tab = loadTab(h);
if isempty(tab)
    h_mes = errordlg('First load an image');
    waitfor(h_mes)
    return
end

% Ask to remove model and analysis if necessary
string = 'Adding column positions will erase the fitted model and all analysis, continue?';
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
    if data{n,1}~=state
        showHideFigOptions(tab,value,data{n,2},true,h,sColBar)
        data{n,1} = state;
    end
end
%Update data
set(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data',data)


%% Select axis and load references to plotted coordinates
axis(usr.images.ax);
hold on;

% Get references to plotted coordinates
type = get(h.left.peak.panels.addRem.addType,'SelectedIndex')+1;
colr = colorAtoms(userdata.pathColor,type);
val = get(usr.images.ax,'Userdata');
ind = find(strcmp(val(:,1),nameTag));
if isempty(ind)
    h_peaks = zeros(1,type);
    ind = length(val(:,1))+1;
    val = [val;{nameTag,h_peaks}];
else
    h_peaks = val{ind,2};
    if type>length(h_peaks)
        h_peaks(type) = 0;
    end
end

%% Make all text field in preparation panel unfocusable
focusFields(h,false)

%% Start adding
userdata = get(h.right.tabgroup,'Userdata');
userdata.callbackrunning = true; % For peak location routines
set(h.right.tabgroup,'Userdata',userdata);
title(usr.images.ax,'Add peak locations, press ESC to exit')
abort = 0;

% Get scale marker
scaleMarker = str2double(get(usr.figOptions.optFig.msval,'String'));
msize = coorMarkerSize(usr.images.ax,'.',scaleMarker);

if ~isempty(input.coordinates)
    coordinates = input.coordinates(input.coordinates(:,3)==type,:);
else
    % add first point and enable buttons
    [x,y] = ginput_AxInFig(usr.images.ax,h.fig,h_pan,h_zoom,h_cursor);
    if isempty(x)
        coordinates = [];
        abort = 1;
    else
        coordinates = [x y type];
        h_peaks(type) = plot(usr.images.ax,coordinates(:,1),coordinates(:,2),'.','Color',colr,'MarkerSize',msize);
    end
    
    usr.file.input.coordinates = coordinates;
    updateLeftPanels(h,usr.file,usr.fitOpt)
end

while abort==0
    [x,y] = ginput_AxInFig(usr.images.ax,h.fig,h_pan,h_zoom,h_cursor);
    if isempty(x)
        abort = 1;
    else
        if ~isempty(coordinates)
            if h_peaks(type)~=0
                delete(h_peaks(type))
            end
        end
        coordinates = [coordinates;[x y type]];
        h_peaks(type) = plot(usr.images.ax,coordinates(:,1),coordinates(:,2),'.','Color',colr,'MarkerSize',msize);
    end
end
% Update userdata
userdata = get(h.right.tabgroup,'Userdata');
userdata.callbackrunning = false; % For peak location routines
set(h.right.tabgroup,'Userdata',userdata);
val{ind,2} = h_peaks;
set(usr.images.ax,'Userdata',val);

title(usr.images.ax,'')
hold off;

%% Make all text field in preparation panel focusable
focusFields(h,true)

%% Store new coordinates
if ~isempty(input.coordinates)
    input.coordinates = [input.coordinates(input.coordinates(:,3)~=type,:);coordinates];
else
    input.coordinates = coordinates;
end
usr.file.input = input;
set(tab,'Userdata',usr);

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
