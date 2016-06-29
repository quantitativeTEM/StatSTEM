function newICLmin(jObject,event,h)
% newICLmin - Select a new ICL minimum in the StatSTEM interface
%
%   syntax: newICLmin(jObject,event,h)
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

% Check if button is enabled
if ~get(jObject,'Enabled')
    return
end

tab = loadTab(h);
if isempty(tab)
    h_mes = errordlg('First load an image');
    waitfor(h_mes)
    return
end

usr = get(tab,'Userdata');

% First make sure the ICL is shown
ind = get(usr.figOptions.selImg.listbox,'Value');
str = get(usr.figOptions.selImg.listbox,'String');
value = find(strcmp(str,'ICL'));
if value~=ind
    showImage(tab,'ICL',h)
    usr = get(tab,'Userdata');
end

% Now delete plotted minimum
ax = usr.images.ax;
nameTag = 'Minimum ICL';
data = get(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data');
ind = strcmp(data(:,2),nameTag);
if data{ind,1}
    deleteImageObject(ax,nameTag)
end

% Now select new minimum
title(ax,'Select the minimum of interest in the ICL')
userdata = get(h.right.tabgroup,'Userdata');
userdata.callbackrunning = true; % For peak location routines
set(h.right.tabgroup,'Userdata',userdata);
[x,~] = ginput_AxInFig(ax,h.fig,h_pan,h_zoom,h_cursor);
usr.file.atomcounting.selMin = round(x);
if isempty(usr.file.atomcounting.selMin)
    usr.file.atomcounting.selMin = 1;
elseif usr.file.atomcounting.selMin<1
    usr.file.atomcounting.selMin = 1;
elseif usr.file.atomcounting.selMin>length(usr.file.atomcounting.ICL)
    usr.file.atomcounting.selMin = length(usr.file.atomcounting.ICL);
end
title(ax,'')

% Update userdata for callback
userdata = get(h.right.tabgroup,'Userdata');
userdata.callbackrunning = false; % For peak location routines
set(h.right.tabgroup,'Userdata',userdata);

% Update userdata
set(tab,'Userdata',usr);

% Plot and add reference to selected minimum in figure
plotMinICL(ax,[usr.file.atomcounting.selMin,usr.file.atomcounting.ICL(usr.file.atomcounting.selMin)]);

% Now Update all other parameters
% Now determine the number of atoms per column and the GMM
usr.file.atomcounting = getAtomCounts(usr.file.atomcounting);
% Calculate the single atom sensitivity
sens = sengleatomsensivity(usr.file.atomcounting,1);
message = ['New ICL minimum selected: ',num2str(usr.file.atomcounting.selMin),' - atom counting results obtained with ',num2str(sens(1)*100),'%% single atom sensitivity: ',num2str(usr.FileName)];
newMessage(message,h)
% Update userdata
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