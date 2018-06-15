function Resize_figure(hObject,event,h)
% Resize_figure - execute this when resizing the StatSTEM interface
%
% This function aborts all running functions before resizing the interface
%
%   syntax: Resize_figure(hObject,event,h)
%       hObject - Reference to button
%       event   - structure recording button events
%       h       - structure holding references to StatSTEM interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% First check if no other routine is running
userdata = get(h.right.tabgroup,'Userdata');
if (userdata.callbackrunning)
    % Is so store function name and variables and cancel other function
    userdata.function.name = mfilename;
    userdata.function.input = {hObject,event,h};
    set(h.right.tabgroup,'Userdata',userdata)
    if ~isfield(userdata,'loadingNewFile')
        robot = java.awt.Robot;
        robot.keyPress(java.awt.event.KeyEvent.VK_ESCAPE);
        robot.keyRelease(java.awt.event.KeyEvent.VK_ESCAPE);
    end
    return
end

% Check matlab version
v = version('-release');
v = str2double(v(1:4));

% Size figure is changed, make sure panels are still at the correct place
if v<2015
    set(hObject,'ResizeFcn',[]);
else
    set(hObject,'SizeChangedFcn',[]);
end
fig_size = get(h.fig,'Position');

% Resize main panels
scale_x = 200/fig_size(3);
set(h.left.main,'Position',[0 0 scale_x 1])
set(h.right.main,'Position',[scale_x 0 1-scale_x 1])

% Resize bottom panels
set(h.left.main,'units','pixels')
pos = get(h.left.main,'Position');
set(h.left.main,'units','normalized')
scale_y = 58/pos(4);
scale_y2 = 158/pos(4);
set(h.left.loadStore.panel,'Position',[0 0 1 scale_y])
set(h.left.StatSTEM.panel,'Position',[-0.01 scale_y 1 scale_y2])
set(h.right.progress.panel,'Position',[0.7 0 0.3 scale_y])
set(h.right.message.panel,'Position',[0 0 0.7 scale_y])
set(h.left.tabgroup,'Position',[0 scale_y+scale_y2 1 1-(scale_y+scale_y2)])
set(h.right.tabgroup,'Position',[0 scale_y 1 1-scale_y])

% Rescale panels
tabs = get(h.right.tabgroup,'Children');
tab = get(h.right.tabgroup,'SelectedTab');
set(tab,'units','pixels')
drawnow
pos_r = get(tab,'Position');
set(tab,'units','normalized')
scale_x = userdata.dim_x/pos_r(3);
scale_y = [userdata.dim_y;pos_r(4)-sum(userdata.dim_y)]/pos_r(4);
for n=1:length(tabs)
    % Get handle of tabs
    usr = get(tabs(n),'Userdata');
    set(usr.images.main,'Position',[0 0 1-scale_x(1) 1])
%     set(usr.figOptions.title.main,'Position',[1-scale_x(1) scale_y(2)+scale_y(3) scale_x(1) scale_y(1)]);
    set(usr.figOptions.selImg.main,'Position',[1-scale_x(1) scale_y(1)+scale_y(2)+scale_y(3)/2 scale_x(1) scale_y(3)/2]);
    set(usr.figOptions.selOpt.main,'Position',[1-scale_x(1) scale_y(1)+scale_y(2) scale_x(1) scale_y(3)/2]);
    set(usr.figOptions.optFig.main,'Position',[1-scale_x(1) scale_y(1) scale_x(1) scale_y(2)]);
    set(usr.figOptions.export.main,'Position',[1-scale_x(1) 0 scale_x(1) scale_y(1)]);

    % Update figure
    if n==length(tabs)
        % Make sure addition panel is not updated
        break
    end
    
    % Resize markers
    usr.oldMarkerSize = Inf;
    set(tabs(n),'Userdata',usr)
    changeMS(usr.figOptions.optFig.msval,event,tabs(n))
    % Check if colorbar is shown
    if strcmp(get(h.colorbar(1),'State'),'on')
        % Find colorbars
        child = get(usr.images.img,'Children');
        indC = false(length(child),1);
        for k=1:length(child)
            if strcmp(get(child(k),'Tag'),'Colorbar')
                indC(k,1) = true;
            end
        end
        if sum(indC)>1
            if v<2015
                drawnow
            end
            indC = find(indC);
            if strcmp(get(child(indC(1)),'Visible'),'off')
                n1 = indC(1);
                n2 = indC(2);
            else
                n1 = indC(2);
                n2 = indC(1);
            end
            pos = get(child(n1),'Position');
            set(child(n2),'Position',pos)
        end
    end
end
if v<2015
    set(hObject,'ResizeFCN',{@Resize_figure,h});
else
    set(hObject,'SizeChangedFcn',{@Resize_figure,h});
end