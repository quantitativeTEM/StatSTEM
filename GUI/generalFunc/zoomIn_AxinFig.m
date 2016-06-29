function zoomIn_AxinFig(hObject,event,h,zOut)
% zoomIn_AxinFig - Enable zooming in StatSTEM interface
%
% This function replaces the standard zoom function of MATLAB to enable
% zooming by scrolling in the GUI
%
%   syntax: zoomIn_AxinFig(hObject,event,h,zOut)
%       hObject - Reference to zoom button
%       event   - structure recording button events
%       h       - structure holding references to GUI interface
%       zOut    - Reference to zoom out button
%
% See also: zoomOut_AxinFig, zoomAxinFig

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Select figure
figure(h.fig)

% First turn off zooming out
if any(strcmp(get(zOut,'State'),'on')) && any(strcmp(get(hObject,'State'),'on'))
    set(zOut,'State','off');
    zoomOut_AxinFig(zOut,event,h,hObject)
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

% Select color, dependend on shown figure (gray for normal plot, white for image
childs = get(ha,'Children');
clr = [0.25 0.25 0.25];
for n=1:length(childs)
    if isa(childs(n),'matlab.graphics.primitive.Image')
        clr = [1 1 1];
    end
end
xy = [];
xy2 = [];
status = '';
lines = cell(4,1);
% Zoom, cdata pointer
Cdata = [NaN,NaN,NaN,NaN,1,1,1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,1,1,NaN,2,NaN,2,1,1,NaN,NaN,NaN,NaN,NaN,NaN;NaN,1,2,NaN,2,1,1,NaN,2,NaN,1,NaN,NaN,NaN,NaN,NaN;NaN,1,NaN,2,NaN,1,1,2,NaN,2,1,NaN,NaN,NaN,NaN,NaN;1,NaN,2,NaN,2,1,1,NaN,2,NaN,2,1,NaN,NaN,NaN,NaN;1,2,1,1,1,1,1,1,1,1,NaN,1,NaN,NaN,NaN,NaN;1,NaN,1,1,1,1,1,1,1,1,2,1,NaN,NaN,NaN,NaN;1,2,NaN,2,NaN,1,1,2,NaN,2,NaN,1,NaN,NaN,NaN,NaN;NaN,1,2,NaN,2,1,1,NaN,2,NaN,1,NaN,NaN,NaN,NaN,NaN;NaN,1,NaN,2,NaN,1,1,2,NaN,2,1,2,NaN,NaN,NaN,NaN;NaN,NaN,1,1,2,NaN,2,NaN,1,1,1,1,2,NaN,NaN,NaN;NaN,NaN,NaN,NaN,1,1,1,1,NaN,2,1,1,1,2,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,1,1,1,2,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,1,1,1,2;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,1,1,1;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2,1,2];

% Zoomfactor
zfactor = 2;

% Contextmenu
c = uicontextmenu;
% Create menu items for the uicontextmenu
m1 = uimenu(c,'Label','Zoom Out       Shift-Click','Callback',@zoomOut);
m2 = uimenu(c,'Label','Reset to Original View','Callback',@resetView);
set(ha,'UIContextMenu',c)
set(get(ha,'Children'),'UIContextMenu',c)

% Store previous Callbacks
call_wbm = get(h.fig,'WindowButtonMotionFcn');
call_wbd = get(h.fig,'WindowButtonDownFcn');
call_wbu = get(h.fig,'WindowButtonUpFcn');
call_wsw = get(h.fig,'WindowScrollWheelFcn');
call_wkr = get(h.fig,'WindowKeyReleaseFcn');
if ~isempty(call_wsw)
end
set(h.fig,'WindowButtonMotionFcn',@changepointer,'WindowButtonDownFcn',@getRegion,'WindowButtonUpFcn',@updateWindow,'WindowScrollWheelFcn',@scroll_zoom,'WindowKeyReleaseFcn',@key_zoom);
% Restore callbacks in userdata
if restart==0
    set(hObject,'Userdata',{'WindowButtonMotionFcn',call_wbm,'WindowButtonDownFcn',call_wbd,'WindowButtonUpFcn',call_wbu,'WindowScrollWheelFcn',call_wsw,'WindowKeyReleaseFcn',call_wkr})
end

    function changepointer(hf,~)
        try
            pntr = get(ha,'CurrentPoint');
        catch
            data{2,1} = 'Restart';
            zoomIn_AxinFig(hObject,event,h,zOut)
            return
        end
        Ax_xlim = get(ha,'Xlim');
        Ax_ylim = get(ha,'Ylim');
        if pntr(1,1)>Ax_xlim(1) && pntr(1,1)<Ax_xlim(2) && pntr(1,2)>Ax_ylim(1) && pntr(1,2)<Ax_ylim(2)
            set(hf,'Pointer','custom','PointerShapeCData',Cdata,'PointerShapeHotSpot',[6 6])
        elseif strcmp(status,'down')
        else
            set(hf,'Pointer','arrow','PointerShapeHotSpot',[1 1])
        end
        if ~isempty(status)
            set(lines{1,1},'XData',[xy(1,1) pntr(1,1)],'YData',[xy(1,2) xy(1,2)])
            set(lines{2,1},'XData',[xy(1,1) xy(1,1)],'YData',[xy(1,2) pntr(1,2)])
            set(lines{3,1},'XData',[xy(1,1) pntr(1,1)],'YData',[pntr(1,2) pntr(1,2)])
            set(lines{4,1},'XData',[pntr(1,1) pntr(1,1)],'YData',[xy(1,2) pntr(1,2)])
        end
    end
    function getRegion(hf,~)
        pntr = get(hf,'Pointer');
        pnt2 = get(hf,'CurrentPoint');
        pnt = get(ha,'CurrentPoint');
        button = get(hf, 'SelectionType');
        if (strcmp(pntr, 'custom'))
            if strcmp(button,'normal')
                xy = [pnt(1,1) pnt(1,2)];
                xy2 = [pnt2(1,1) pnt2(1,2)];

                status = 'down';
                lines{1,1} = line([xy(1,1) xy(1,1)],[xy(1,2) xy(1,2)],'LineStyle','-','LineWidth',0.25,'Color',clr,'Parent',ha);
                lines{2,1} = line([xy(1,1) xy(1,1)],[xy(1,2) xy(1,2)],'LineStyle','-','LineWidth',0.25,'Color',clr,'Parent',ha);
                lines{3,1} = line([xy(1,1) xy(1,1)],[xy(1,2) xy(1,2)],'LineStyle','-','LineWidth',0.25,'Color',clr,'Parent',ha);
                lines{4,1} = line([xy(1,1) xy(1,1)],[xy(1,2) xy(1,2)],'LineStyle','-','LineWidth',0.25,'Color',clr,'Parent',ha);
            elseif strcmp(button, 'extend')
                % get the axes' x- and y-limits
                Ax_xlim = get(ha, 'XLim');
                Ax_ylim = get(ha, 'ylim');
                % Get center and new range
                center = [(Ax_xlim(1)+Ax_xlim(2))/2,(Ax_ylim(1)+Ax_ylim(2))/2];
                dx = (Ax_xlim(2) - Ax_xlim(1))/(2*zfactor^-1);
                dy = (Ax_ylim(2) - Ax_ylim(1))/(2*zfactor^-1);
                set(ha,'XLim',[max(center(1)-dx,limits(1)),min(center(1)+dx,limits(2))]);
                set(ha,'YLim',[max(center(2)-dy,limits(3)),min(center(2)+dy,limits(4))]);
            elseif strcmp(button, 'open')
                axis(ha,limits)
            elseif strcmp(button, 'alt')
                set(ha,'UIContextMenu',c)
                set(get(ha,'Children'),'UIContextMenu',c)
            end
        end
    end
    function updateWindow(hf,~)
        try
            pnt = get(ha,'CurrentPoint');
        catch
            data{2,1} = 'Restart';
            zoomIn_AxinFig(hObject,event,h,zOut)
            return
        end
        pnt2 = get(hf,'CurrentPoint');
        % Get limits
        Ax_xlim = get(ha,'Xlim');
        Ax_ylim = get(ha,'Ylim');
        x_d = (Ax_xlim(2)-Ax_xlim(1))/(2*zfactor); 
        y_d = (Ax_ylim(2)-Ax_ylim(1))/(2*zfactor);
        if ~isempty(xy)
            if abs(xy2(1)-pnt2(1,1))<5 && abs(xy2(2)-pnt2(1,2))<5
                if xy(1)-x_d<limits(1)
                    Ax_xlim = [limits(1) limits(1)+2*x_d];
                elseif xy(1)+x_d>limits(2)
                    Ax_xlim = [limits(2)-2*x_d limits(2)];
                else
                    Ax_xlim = [xy(1)-x_d xy(1)+x_d];
                end
                if xy(2)-y_d<limits(3)
                    Ax_ylim = [limits(3) limits(3)+2*y_d];
                elseif xy(2)+y_d>limits(4)
                    Ax_ylim = [limits(4)-2*y_d limits(4)];
                else
                    Ax_ylim = [xy(2)-y_d xy(2)+y_d];
                end
            else
                Ax_xlim = [min(xy(1),pnt(1,1)) max(xy(1),pnt(1,1))];
                Ax_ylim = [min(xy(2),pnt(1,2)) max(xy(2),pnt(1,2))];
                dx = Ax_xlim(2) - Ax_xlim(1);
                dy = Ax_ylim(2) - Ax_ylim(1);
                % Expand limits to maintain figure ratio
                if dx/dy>x_d/y_d
                    d = (dx/x_d*y_d-dy)/2;
                    Ax_ylim = [Ax_ylim(1)-d Ax_ylim(2)+d];
                elseif dx/dy<x_d/y_d
                    d = (dy/y_d*x_d-dx)/2;
                    Ax_xlim = [Ax_xlim(1)-d Ax_xlim(2)+d];
                end
            end
            % Update axes limits
            axis(ha,[Ax_xlim Ax_ylim])
            
            % Reset variables
            xy = [];
            status = '';
            delete(lines{1,1})
            delete(lines{2,1})
            delete(lines{3,1})
            delete(lines{4,1})
            lines = cell(4,1);
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
            zoomIn_AxinFig(hObject,event,h,zOut)
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

    function zoomOut(~,~)
        % get the axes' x- and y-limits
        Ax_xlim = get(ha, 'XLim');
        Ax_ylim = get(ha, 'ylim');
        % Get center and new range
        center = [(Ax_xlim(1)+Ax_xlim(2))/2,(Ax_ylim(1)+Ax_ylim(2))/2];
        dx = (Ax_xlim(2) - Ax_xlim(1))/(2*zfactor^-1);
        dy = (Ax_ylim(2) - Ax_ylim(1))/(2*zfactor^-1);
        set(ha,'XLim',[max(center(1)-dx,limits(1)),min(center(1)+dx,limits(2))]);
        set(ha,'YLim',[max(center(2)-dy,limits(3)),min(center(2)+dy,limits(4))]);
    end

    function resetView(~,~)
        axis(ha,limits)
    end
end

