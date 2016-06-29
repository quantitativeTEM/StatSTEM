function selectBack(jObject,event,h)
% selectBack - Button callback selecting a background value in the image
%
%   syntax: selectBack(jObject,event,h)
%       jObject - Reference to button
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

% First turn off figure selection options
[h_pan,h_zoom,h_cursor] = turnOffFigureSelection(h);

% Check if no other routine is running
userdata = get(h.right.tabgroup,'Userdata');
if (userdata.callbackrunning)
    % First turn off zoom, pan and datacursor
	turnOffFigureSelection(h);
    % Is so store function name and variables and cancel other function
    userdata.function.name = mfilename;
    userdata.function.input = {jObject,event,h};
    set(h.right.tabgroup,'Userdata',userdata)
    robot = java.awt.Robot;
    robot.keyPress(java.awt.event.KeyEvent.VK_ESCAPE);
    robot.keyRelease(java.awt.event.KeyEvent.VK_ESCAPE);
    return
end

% First check if button is enabled
if ~jObject.isEnabled
    return
end

% Turn off all editing in the figure
plotedit(h.fig,'off')

tab = loadTab(h);
% Load userdata
usr = get(tab,'Userdata');
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
        showHideFigOptions(tab,value,data{n,2},true)
        data{n,1} = state;
    end
end
%Update data
set(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data',data)

%% Make all text field unfocusable
focusFields(h,false,'all')

%% Select background
% Let user select a region
userdata = get(h.right.tabgroup,'Userdata');
userdata.callbackrunning = true; % For other routines
set(h.right.tabgroup,'Userdata',userdata);
title(usr.images.ax,'Select region, press ESC to exit')
coor = gregion_AxInFig(usr.images.ax,h.fig,h_pan,h_zoom,h_cursor);
title(usr.images.ax,'')
userdata = get(h.right.tabgroup,'Userdata');
userdata.callbackrunning = false; % For other routines
set(h.right.tabgroup,'Userdata',userdata);
if ~isempty(coor)
    K = size(input.obs,2);
    L = size(input.obs,1);
    [X,Y] = meshgrid( (1:K)*input.dx,(1:L)*input.dx);
    in = inpolygon(X,Y,coor(:,1),coor(:,2));
    val = mean(mean(input.obs(in)));
else
    val = str2double(get(h.left.fit.panels.Back.Val,'Text'));
end

usr.fitOpt.model.zeta = val;

%% Update GUI
% Make all text field focusable
focusFields(h,true,'fit')

% Update userdata
set(tab,'Userdata',usr)

if val==0
    dg = 1;
else
    temp = val*10.^(1:20);
    %Number of digits voor string
    dg = find(temp==round(temp),1)+floor(log10(abs(val)))+1;
end

% Update background value
set(h.left.fit.panels.Back.Val,'Text',num2str(val,dg))

% Check if other function is started
if ~isempty(userdata.function)
    f = userdata.function;
    userdata.function = [];
    set(h.right.tabgroup,'Userdata',userdata);
    eval([f.name,'(f.input{:})'])
end