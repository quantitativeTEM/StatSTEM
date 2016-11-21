function removePeaks(hObject,event,h)
% removePeaks - Callback for removing peak locations manually
%
%   syntax: removePeaks(hObject,event,h)
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

% Load positions
usr = get(tab,'Userdata');

% Show warning that removal of peak will remove the fitted model and
% possible analysis
string = 'Removing column positions will erase the fitted model and all analysis, continue?';
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
types = get(h.left.peak.panels.addRem.addType,'ItemCount')-3;
colr = colorAtoms(userdata.pathColor,1:types);
val = get(usr.images.ax,'Userdata');
ind = strcmp(val(:,1),nameTag);
if isempty(ind)
    % Enable/Disable buttons
    updateLeftPanels(h,usr.file,usr.fitOpt)
    return
else
    h_peaks = val{ind,2};
    if types>length(h_peaks)
        h_peaks(types) = 0;
    end
end

%% Make all text field in preparation panel unfocusable
focusFields(h,false)

%% Start removing
userdata = get(h.right.tabgroup,'Userdata');
userdata.callbackrunning = true; % For peak location routines
set(h.right.tabgroup,'Userdata',userdata);
title(usr.images.ax,'Remove peak locations, press ESC to exit')
abort = 0;

% Get scale marker
scaleMarker = str2double(get(usr.figOptions.optFig.msval,'String'));
msize = coorMarkerSize(usr.images.ax,'.',scaleMarker);

while abort==0
    [x,y] = ginput_AxInFig(usr.images.ax,h.fig,h_pan,h_zoom,h_cursor);
    if isempty(x)
        abort = 1;
    else
        distance = (input.coordinates(:,1)-x).^2+(input.coordinates(:,2)-y).^2;
        input.coordinates = input.coordinates(distance~=min(distance),:);
        for k=1:length(h_peaks)
            if h_peaks(k)~=0
                delete(h_peaks(k))
            end
        end
        for k=1:max(input.coordinates(:,3))
            indices = input.coordinates(:,3)==k;
            if any(indices)
                h_peaks(k) = plot(usr.images.ax,input.coordinates(indices,1),input.coordinates(indices,2),'.','Color',colr(k,:),'MarkerSize',msize);
            else
                h_peaks(k)=0;
            end
        end
    end
    if isempty(input.coordinates)
        abort = 1;
        h_peaks = 0;
    end
end

% Update userdata
userdata = get(h.right.tabgroup,'Userdata');
userdata.callbackrunning = false; % For peak location routines
set(h.right.tabgroup,'Userdata',userdata);

title(usr.images.ax,'')
hold off;

%% Make all text field in preparation panel unfocusable
focusFields(h,true)

%% Store new coordinates
usr.file.input = input;
set(tab,'Userdata',usr);

val{ind,2} = h_peaks;
set(usr.images.ax,'Userdata',val)

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