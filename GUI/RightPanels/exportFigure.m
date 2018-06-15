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

% Check matlab version, and switch opengl
v = version('-release');
v = str2double(v(1:4));

% Load image
usr = get(tab,'Userdata');

% open new figure and copy the axes into it
fig=figure;
copyobj(usr.images.ax,fig);
ax = gca;
cmp = colormap(usr.images.ax);
colormap(ax,cmp)
Scmap = size(colormap);
set(ax,'ActivePositionProperty','outerposition')
set(ax,'Units','normalized','OuterPosition',[0 0 1 1],'position',[0.1300 0.1100 0.7750 0.8150])
% Check if colorbar is shown
warning('off','all') % For old versions MATLAB
childs = get(usr.images.img,'Children');
n1 = 0;
n2 = 0;
indColor = false(length(childs),1);
for k=1:length(childs)
    if strcmp(get(childs(k),'Tag'),'Colorbar')
        indColor(k) = true;
    end
end

% Check if second colorbar is present
indColor = find(indColor);
if length(indColor)>1
    if v<2015
        s = get(get(childs(indColor(1)),'YLabel'),'String');
        s2 = get(get(childs(indColor(2)),'YLabel'),'String');
    else
        s = get(get(childs(indColor(1)),'Label'),'String');
        s2 = get(get(childs(indColor(2)),'Label'),'String');
    end
    
    % Find colorbar 1 and 2 (of axis 1 and 2, respectively)
    if strcmp(get(childs(indColor(1)),'Visible'),'off')
        % This is colorbar 1
        ylab = s;
        ylab2 = s2;
        n1 = indColor(1);
        n2 = indColor(2);
    else
        ylab = s2;
        ylab2 = s;
        n1 = indColor(2);
        n2 = indColor(1);
    end
elseif length(indColor)==1
    if v<2015
        s = get(get(childs(indColor(1)),'YLabel'),'String');
    else
        s = get(get(childs(indColor(1)),'Label'),'String');
    end
    n1 = indColor(1);
    ylab = s;
else
    return
end
    

if n1~=0
    if v<2015
        warning('off','all')
        cbar = colorbar('peer',ax);
        warning('on','all')
    else
        cbar = colorbar(ax);
    end
    ylabel(cbar,ylab)
end
if n2~=0
    % add extra axes in new figure for colorbar
    ax2 = copyobj(usr.images.ax2,fig);
    
    % Insert colorbar
    set(cbar,'Visible','off','HitTest','off')
    drawnow
    pos = get(cbar,'Position');
    if v<2015
        warning('off','all')
        h2 = colorbar('peer',ax2,'Position',pos);
        ylabel(h2,ylab2)
        warning('on','all')
    else
        h2 = colorbar(ax2,'Position',pos);
        ylabel(h2,ylab2)
    end
    drawnow
end
warning('on','all') % For old versions MATLAB