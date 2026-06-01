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

% Fixed pixel dimensions
left_w  = 200;   % left panel width in pixels
right_w = 150;   % right options panel width in pixels
bot_h   = 58;    % bottom bar height in pixels
logo_h  = 158;   % StatSTEM logo panel height in pixels


% Guard against resize during initialization
if ~ishandle(h.left.main) || ~ishandle(h.right.main)
    return
end
tabs = get(h.right.tabgroup,'Children');
if isempty(tabs)
    return
end
tab = tabs(1);
usr = get(tab,'Userdata');
if ~isfield(usr,'figOptions') || ~isfield(usr.figOptions,'selImg')
    return
end

% Get current figure size in pixels
set(h.fig,'units','pixels');
fig_size = get(h.fig,'Position');

% Enforce minimum size
if fig_size(3) < 400; fig_size(3) = 400; set(h.fig,'Position',fig_size); end
if fig_size(4) < 300; fig_size(4) = 300; set(h.fig,'Position',fig_size); end

fig_w = fig_size(3);
fig_h = fig_size(4);

% --- Left and right main panels (normalized) ---
set(h.left.main,  'units','normalized','Position',[0,              0, left_w/fig_w,              1])
set(h.right.main, 'units','normalized','Position',[left_w/fig_w,   0, 1-left_w/fig_w,            1])

% --- Bottom panels (normalized within left/right panels) ---
% Need pixel height of left panel
set(h.left.main,'units','pixels');
pos_left = get(h.left.main,'Position');
set(h.left.main,'units','normalized');
left_h = pos_left(4);

scale_y      = bot_h/left_h;
scale_y_logo = logo_h/left_h;

set(h.left.loadStore.panel,  'Position',[0,    0,                        1, scale_y])
set(h.left.StatSTEM.panel,   'Position',[-0.01, scale_y,                 1, scale_y_logo])
set(h.left.tabgroup,         'Position',[0,    scale_y+scale_y_logo,     1, 1-(scale_y+scale_y_logo)])

% Right bottom panels
set(h.right.main,'units','pixels');
pos_right = get(h.right.main,'Position');
set(h.right.main,'units','normalized');
right_h = pos_right(4);

scale_y_r = bot_h/right_h;

set(h.right.progress.panel,  'Position',[0.7, 0, 0.3, scale_y_r])
set(h.right.message.panel,   'Position',[0,   0, 0.7, scale_y_r])
set(h.right.tabgroup,        'Position',[0,   scale_y_r, 1, 1-scale_y_r])

% --- Rescale right options panels inside tabs ---
tabs = get(h.right.tabgroup,'Children');
tab  = get(h.right.tabgroup,'SelectedTab');
set(tab,'units','pixels'); drawnow;
pos_r = get(tab,'Position');
set(tab,'units','normalized');

scale_x = min(1, right_w/pos_r(3));
scale_y_tabs = [userdata.dim_y; pos_r(4)-sum(userdata.dim_y)]/pos_r(4);

for n=1:length(tabs)
    usr = get(tabs(n),'Userdata');

    % Skip tabs that don't have figOptions (e.g. the + tab)
    if ~isfield(usr,'figOptions') || ~isfield(usr.figOptions,'selImg')
        continue
    end

    % Clamp all dimensions to avoid negative sizes during resize
    sx      = max(0, scale_x);
    sy1     = max(0, scale_y_tabs(1));
    sy2     = max(0, scale_y_tabs(2));
    sy3h    = max(0, scale_y_tabs(3)/2);
    % Update image main panel to fill space left of options panels
    set(usr.images.main, 'units', 'normalized', 'Position', [0, 0, 1-sx, 1])
    set(usr.figOptions.selImg.main, 'Position',[1-sx, sy1+sy2+sy3h, sx, sy3h])
    set(usr.figOptions.selOpt.main, 'Position',[1-sx, sy1+sy2,      sx, sy3h])
    set(usr.figOptions.optFig.main, 'Position',[1-sx, sy1,          sx, sy2])
    set(usr.figOptions.export.main, 'Position',[1-sx, 0,            sx, sy1])

    if ~isfield(usr,'images') || ~isfield(usr.images,'img')
        continue
    end

    % Skip changeMS during resize to avoid invalid marker size calculations
    % Marker sizes will update correctly on next user interaction
    usr.oldMarkerSize = 1;
    set(tabs(n),'Userdata',usr)

    if ~isempty(h.colorbar) && ishandle(h.colorbar(1)) && strcmp(get(h.colorbar(1),'State'),'on')
        child = get(usr.images.img,'Children');
        indC = false(length(child),1);
        for k=1:length(child)
            if strcmp(get(child(k),'Tag'),'Colorbar'); indC(k,1) = true; end
        end
        if sum(indC)>1
            if v<2015; drawnow; end
            indC = find(indC);
            if strcmp(get(child(indC(1)),'Visible'),'off'); n1=indC(1); n2=indC(2);
            else; n1=indC(2); n2=indC(1); end
            pos = get(child(n1),'Position');
            set(child(n2),'Position',pos)
        end
    end
end
drawnow;
if v<2015
    set(hObject,'ResizeFcn',@(src,evt) Resize_figure(src,evt,h));
else
    set(hObject,'SizeChangedFcn',@(src,evt) Resize_figure(src,evt,h));
end