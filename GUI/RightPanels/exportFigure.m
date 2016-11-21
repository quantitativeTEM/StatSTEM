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
for k=1:length(childs)
    if strcmp(get(childs(k),'Tag'),'Colorbar')
        n1 = k;
        ylab = get(get(childs(k),'Label'),'String');
    end
    if strcmp(get(childs(k),'Tag'),'Colorbar2')
        n2 = k;
        ylab2 = get(get(childs(k),'Label'),'String');
    end
end

if n1~=0
    if v<2015
        cbar = colorbar('peer',ax);
    else
        cbar = colorbar(ax);
    end
    ylabel(cbar,ylab)
end
if n2~=0
    % add extra axes in new figure for colorbar
    cAx = caxis(usr.images.ax);
    cAx2 = caxis(usr.images.ax2);
    cmp2 = colormap(usr.images.ax2);
    
    % Change observation to rgb image
    child = get(ax,'Children');
    for i=1:length(child)
        if strcmp(get(child(i),'Tag'),'Image')
            obs = get(child(i),'CData');
            if size(obs,3)==1
                obs = get(child(i),'CData');
                obs = (floor(((obs - cAx(1)) ./ (cAx(2) - cAx(1))) * (Scmap(1)-1))); 
                obs(obs<0) = 0;
                obs(obs>255) = Scmap(1)-1;
                obs = ind2rgb(obs,cmp);
                set(child(i),'CData',obs);
            end
            break
        end
    end
    
    caxis(ax,cAx2);
    colormap(ax,cmp2)
    ylabel(cbar,ylab2)
end
warning('on','all') % For old versions MATLAB