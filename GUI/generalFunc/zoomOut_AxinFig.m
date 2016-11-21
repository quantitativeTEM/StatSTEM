function zoomOut_AxinFig(hObject,event,h,zIn)
% zoomOut_AxinFig - Enable zooming in StatSTEM interface
%
% This function replaces the standard zoom function of MATLAB to enable
% zooming by scrolling in the GUI
%
%   syntax: zoomOut_AxinFig(hObject,event,h,zOut)
%       hObject - Reference to zoom button
%       event   - structure recording button events
%       h       - structure holding references to GUI interface
%       zIn     - Reference to zoom in button
%
% See also: zoomIn_AxinFig, zoomAxinFig

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Select figure
figure(h.fig)

% First turn off zooming in
if any(strcmp(get(zIn,'State'),'on')) && any(strcmp(get(hObject,'State'),'on'))
    set(zIn,'State','off');
    zoomIn_AxinFig(zIn,event,h,hObject)
end
if any(strcmp(get(hObject,'State'),'on'))
    % Turn off datacursor mode
    datacursormode(h.fig,'off')
    % Turn off pan
    pan(h.fig,'off')
end

% Check if function need to be restarted, to updates axes and so on
data = get(hObject,'Userdata');
if length(hObject)>1
    data = data{1,1};
end
restart = 0;
if size(data,1)==2
    if strcmp(data{2,1},'Restart')
        restart = 1;
    end
end
if any(strcmp(get(hObject,'State'),'off')==1) && restart==0
    if size(data,1)==1
        set(h.fig,data{1,:})
    end
    % Restore windows figure options and pointer
    set(h.fig,'Pointer','arrow','PointerShapeHotSpot',[1 1])
    % Restore userdata
    set(hObject,'Userdata',{})
end

tab = loadTab(h);
if isempty(tab)
    set(hObject,'State','off');
    return
end
usr = get(tab,'Userdata');
ha = usr.images.ax;

if any(strcmp(get(hObject,'State'),'off')==1) && restart==0
    % Reset UIContextmenu
    set(ha,'UIContextMenu',[])
    set(get(ha,'Children'),'UIContextMenu',[])
    return
else
    set(hObject,'State','on')
end

% Get the figure limits
limits = get(ha,'UserData');
ind = strcmp(limits(:,1),'Limits');
if any(ind)
    limits = limits{ind,2};
else
    xl = xlim(ha);
    yl = ylim(ha);
    limits = [xl yl];
end
% Zoom, cdata pointer
xy = [];
Cdata = [NaN,NaN,NaN,NaN,1,1,1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,1,1,NaN,2,NaN,2,1,1,NaN,NaN,NaN,NaN,NaN,NaN;NaN,1,2,NaN,2,NaN,2,NaN,2,NaN,1,NaN,NaN,NaN,NaN,NaN;NaN,1,NaN,2,NaN,2,NaN,2,NaN,2,1,NaN,NaN,NaN,NaN,NaN;1,NaN,2,NaN,2,NaN,2,NaN,2,NaN,2,1,NaN,NaN,NaN,NaN;1,2,1,1,1,1,1,1,1,1,NaN,1,NaN,NaN,NaN,NaN;1,NaN,1,1,1,1,1,1,1,1,2,1,NaN,NaN,NaN,NaN;1,2,NaN,2,NaN,2,NaN,2,NaN,2,NaN,1,NaN,NaN,NaN,NaN;NaN,1,2,NaN,2,NaN,2,NaN,2,NaN,1,NaN,NaN,NaN,NaN,NaN;NaN,1,NaN,2,NaN,2,NaN,2,NaN,2,1,2,NaN,NaN,NaN,NaN;NaN,NaN,1,1,2,NaN,2,NaN,1,1,1,1,2,NaN,NaN,NaN;NaN,NaN,NaN,NaN,1,1,1,1,NaN,2,1,1,1,2,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,1,1,1,2,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,1,1,1,2;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,1,1,1;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,1,2];

% Zoomfactor
zfactor = 2;

% Contextmenu
c = uicontextmenu;
% Create menu items for the uicontextmenu
m1 = uimenu(c,'Label','Zoom In       Shift-Click','Callback',@zoomIn);
m2 = uimenu(c,'Label','Reset to Original View','Callback',@resetView);
set(ha,'UIContextMenu',c)
set(get(ha,'Children'),'UIContextMenu',c)

% Store previous Callbacks
call_wbm = get(h.fig,'WindowButtonMotionFcn');
call_wbd = get(h.fig,'WindowButtonDownFcn');
call_wsw = get(h.fig,'WindowScrollWheelFcn');
call_wkr = get(h.fig,'WindowKeyReleaseFcn');
if ~isempty(call_wsw)
end
set(h.fig,'WindowButtonMotionFcn',@changepointer,'WindowButtonDownFcn',@updateWindow,'WindowScrollWheelFcn',@scroll_zoom,'WindowKeyReleaseFcn',@key_zoom);
% Store callbacks in userdata
if restart==0
    set(hObject,'Userdata',{'WindowButtonMotionFcn',call_wbm,'WindowButtonDownFcn',call_wbd,'WindowScrollWheelFcn',call_wsw,'WindowKeyReleaseFcn',call_wkr})
end

    function changepointer(hf,~)
        try
            pntr = get(ha,'CurrentPoint');
        catch
            data{2,1} = 'Restart';
            zoomOut_AxinFig(hObject,event,h,zIn)
            return
        end
        Ax_xlim = get(ha,'Xlim');
        Ax_ylim = get(ha,'Ylim');
        if pntr(1,1)>Ax_xlim(1) && pntr(1,1)<Ax_xlim(2) && pntr(1,2)>Ax_ylim(1) && pntr(1,2)<Ax_ylim(2)
            set(hf,'Pointer','custom','PointerShapeCData',Cdata,'PointerShapeHotSpot',[6 6])
        else
            set(hf,'Pointer','arrow','PointerShapeHotSpot',[1 1])
        end
    end

    function updateWindow(hf,~)
        pntr = get(hf,'Pointer');
        button = get(hf, 'SelectionType');
        if (strcmp(pntr, 'custom'))
            if strcmp(button,'normal')
                % get the axes' x- and y-limits
                Ax_xlim = get(ha, 'XLim');
                Ax_ylim = get(ha, 'ylim');
                % Get center and new range
                center = [(Ax_xlim(1)+Ax_xlim(2))/2,(Ax_ylim(1)+Ax_ylim(2))/2];
                dx = (Ax_xlim(2) - Ax_xlim(1))/(2*zfactor^-1);
                dy = (Ax_ylim(2) - Ax_ylim(1))/(2*zfactor^-1);
                if max(center(1)-dx,limits(1))>min(center(1)+dx,limits(2))
                    XLim = [center(1)-dx,center(1)+dx];
                else
                    XLim = [max(center(1)-dx,limits(1)),min(center(1)+dx,limits(2))];
                end
                if max(center(2)-dy,limits(3))>min(center(2)+dy,limits(4))
                    YLim = [center(2)-dy,center(2)+dy];
                else
                    YLim = [max(center(2)-dy,limits(3)),min(center(2)+dy,limits(4))];
                end
                axis(ha,[XLim YLim])
            elseif strcmp(button,'extend')
                % get the axes' x- and y-limits
                Ax_xlim = get(ha, 'XLim');
                Ax_ylim = get(ha, 'ylim');
                % Get new range
                x_d = (Ax_xlim(2)-Ax_xlim(1))/(2*zfactor); 
                y_d = (Ax_ylim(2)-Ax_ylim(1))/(2*zfactor);
                pnt = get(ha,'CurrentPoint');
                if pnt(1,1)-x_d<limits(1)
                    Ax_xlim = [limits(1) limits(1)+2*x_d];
                elseif pnt(1,1)+x_d>limits(2)
                    Ax_xlim = [limits(2)-2*x_d limits(2)];
                else
                    Ax_xlim = [pnt(1,1)-x_d pnt(1,1)+x_d];
                end
                if pnt(1,2)-y_d<limits(3)
                    Ax_ylim = [limits(3) limits(3)+2*y_d];
                elseif pnt(1,2)+y_d>limits(4)
                    Ax_ylim = [limits(4)-2*y_d limits(4)];
                else
                    Ax_ylim = [pnt(1,2)-y_d pnt(1,2)+y_d];
                end
                set(ha,'XLim',Ax_xlim);
                set(ha,'YLim',Ax_ylim);
            elseif strcmp(button, 'open')
                axis(ha,limits)
            elseif strcmp(button, 'alt')
                set(ha,'UIContextMenu',c)
                set(get(ha,'Children'),'UIContextMenu',c)
                pnt = get(ha,'CurrentPoint');
                xy = [pnt(1,1) pnt(1,2)];
            end
        end
    end

    function scroll_zoom(hf,event)
        pntr = get(hf,'Pointer');
        if ~(strcmp(pntr, 'custom'))
            return
        end
        % get the amount of scolls
        scrolls = -1*event.VerticalScrollCount;
        % get the axes' x- and y-limits
        Ax_xlim = get(ha, 'XLim');
        Ax_ylim = get(ha, 'ylim');
        % Get center and new range
        center = [(Ax_xlim(1)+Ax_xlim(2))/2,(Ax_ylim(1)+Ax_ylim(2))/2];
        dx = (Ax_xlim(2) - Ax_xlim(1))/(2*zfactor^scrolls);
        dy = (Ax_ylim(2) - Ax_ylim(1))/(2*zfactor^scrolls);
        set(ha,'XLim',[max(center(1)-dx,limits(1)),min(center(1)+dx,limits(2))]);
        set(ha,'YLim',[max(center(2)-dy,limits(3)),min(center(2)+dy,limits(4))]);
    end

    function key_zoom(~,event)
        if strcmp(event.Key,'escape')
            if size(data,1)==2
                data = data(1,:);
                set(hObject,'Userdata',data)
            end
            set(hObject,'State','off')
            zoomOut_AxinFig(hObject,event,h,zIn)
            return
        elseif strcmp(event.Key,'uparrow')
            scrolls = 1;
        elseif strcmp(event.Key,'downarrow')
            scrolls = -1;
        else
            return
        end
        % get the axes' x- and y-limits
        Ax_xlim = get(ha, 'XLim');
        Ax_ylim = get(ha, 'ylim');
        % Get center and new range
        center = [(Ax_xlim(1)+Ax_xlim(2))/2,(Ax_ylim(1)+Ax_ylim(2))/2];
        dx = (Ax_xlim(2) - Ax_xlim(1))/(2*zfactor^scrolls);
        dy = (Ax_ylim(2) - Ax_ylim(1))/(2*zfactor^scrolls);
        set(ha,'XLim',[max(center(1)-dx,limits(1)),min(center(1)+dx,limits(2))]);
        set(ha,'YLim',[max(center(2)-dy,limits(3)),min(center(2)+dy,limits(4))]);
    end

    function zoomIn(~,~)
        % get the axes' x- and y-limits
        Ax_xlim = get(ha, 'XLim');
        Ax_ylim = get(ha, 'ylim');
        % Get new range
        x_d = (Ax_xlim(2)-Ax_xlim(1))/(2*zfactor); 
        y_d = (Ax_ylim(2)-Ax_ylim(1))/(2*zfactor);
        if xy(1,1)-x_d<limits(1)
            Ax_xlim = [limits(1) limits(1)+2*x_d];
        elseif xy(1,1)+x_d>limits(2)
            Ax_xlim = [limits(2)-2*x_d limits(2)];
        else
            Ax_xlim = [xy(1,1)-x_d xy(1,1)+x_d];
        end
        if xy(1,2)-y_d<limits(3)
            Ax_ylim = [limits(3) limits(3)+2*y_d];
        elseif xy(1,2)+y_d>limits(4)
            Ax_ylim = [limits(4)-2*y_d limits(4)];
        else
            Ax_ylim = [xy(1,2)-y_d xy(1,2)+y_d];
        end
        set(ha,'XLim',Ax_xlim);
        set(ha,'YLim',Ax_ylim);
    end

    function resetView(~,~)
        axis(ha,limits)
    end
end

