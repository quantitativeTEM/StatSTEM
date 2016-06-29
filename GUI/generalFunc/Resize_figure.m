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
% Copyright: 2016, EMAT, University of Antwerp
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
    robot = java.awt.Robot;
    robot.keyPress(java.awt.event.KeyEvent.VK_ESCAPE);
    robot.keyRelease(java.awt.event.KeyEvent.VK_ESCAPE);
    return
end

% Check matlab version, and switch opengl
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
    set(usr.figOptions.title.main,'Position',[1-scale_x(1) scale_y(2)+scale_y(3) scale_x(1) scale_y(1)]);
    set(usr.figOptions.selImg.main,'Position',[1-scale_x(1) scale_y(2)+scale_y(3)/2 scale_x(1) scale_y(3)/2]);
    set(usr.figOptions.selOpt.main,'Position',[1-scale_x(1) scale_y(2) scale_x(1) scale_y(3)/2]);
    set(usr.figOptions.export.main,'Position',[1-scale_x(1) 0 scale_x(1) scale_y(2)]);
    
    % Update figure
    if n==length(tabs)
        % Make sure addition panel is not updated
        break
    end
    data = get(usr.images.ax,'Userdata');
    if ~isempty(data)
        % Input coordinates
        ind = strcmp(data(:,1),'Input coordinates');
        h_peaks = data(ind,2);
        if ~isempty(h_peaks)
            msize = coorMarkerSize(usr.images.ax,'.');
            for i=1:length(h_peaks{1})
                if h_peaks{1}(i)~=0
                    set(h_peaks{1}(i),'MarkerSize',msize);
                end
            end
        end
        
        % Fitted coordinates
        ind = strcmp(data(:,1),'Fitted coordinates');
        h_peaks = data(ind,2);
        if ~isempty(h_peaks)
            msize = coorMarkerSize(usr.images.ax,'+');
            for i=1:length(h_peaks{1})
                if h_peaks{1}(i)~=0
                    set(h_peaks{1}(i),'MarkerSize',msize);
                end
            end
        end
        
        % Coor atomcounting
        ind = strcmp(data(:,1),'Coor atomcounting');
        h_peaks = data(ind,2);
        if ~isempty(h_peaks)
            msize = coorMarkerSize(usr.images.ax,'d');
            for i=1:length(h_peaks{1})
                if h_peaks{1}(i)~=0
                    set(h_peaks{1}(i),'MarkerSize',msize);
                end
            end
        end
        
        % Atom Counts
        ind = strcmp(data(:,1),'Atom Counts');
        h_peaks = data(ind,2);
        if ~isempty(h_peaks)
            msize = coorMarkerSize(usr.images.ax,'s');
            for i=1:length(h_peaks{1})
                if h_peaks{1}(i)~=0
                    set(h_peaks{1}(i),'MarkerSize',msize);
                end
            end
        end
    end
end
if v<2015
    set(hObject,'ResizeFCN',{@Resize_figure,h});
else
    set(hObject,'SizeChangedFcn',{@Resize_figure,h});
end