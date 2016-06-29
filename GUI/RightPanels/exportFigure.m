function exportFigure(hObject,event,h)
% exportFigure - Open figure in a new window
%
%   syntax: exportFigure(hObject,event,h)
%       hObject - Reference to button
%       event   - structure recording button events
%       h       - structure holding references to GUI interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
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

% Check if button is enabled
if ~strcmp(get(hObject,'Enable'),'on')
    return
end

[tab,mes] = loadTab(h);
if isempty(tab)
    h_mes = errordlg(mes);
    waitfor(h_mes)
    return
end

% Load image
usr = get(tab,'Userdata');

% open new figure and copy the axes into it
fig=figure;
copyobj(usr.images.ax,fig);
ax = gca;
cmp = colormap(usr.images.ax);
colormap(ax,cmp)
set(ax,'ActivePositionProperty','outerposition')
set(ax,'Units','normalized')
set(ax,'OuterPosition',[0 0 1 1])
set(ax,'position',[0.1300 0.1100 0.7750 0.8150])
% Check if colorbar is shown
childs = get(usr.images.img,'Children');
for n=1:length(childs)
    if isa(childs(n),'matlab.graphics.illustration.ColorBar')
        cbar = colorbar(ax);
        ylabel(cbar,get(get(childs(n),'Label'),'String'))
        break
    end
end


