function varargout = gregion_AxInFig(ha,hf,h_pan,h_zoom,h_cursor)
% gregion_AxInFig - Graphical input from mouse or cursor
%
% ginput_AxInFig raises crosshairs in the current axes to for you to select
% a region in the figure, positioning the cursor with the mouse. Press 
% escape to exit mode
%
%   syntax: varargout = gregion_AxInFig(ha,hf,h_pan,h_zoom,h_cursor)
%       ha        - reference to axes
%       hf        - reference to figure
%       h_pan     - reference to pan object
%       h_zoom    - reference to zoom buttons
%       h_cursor  - reference to data cursor object
%       varargout - output ([x y])
%
% See also: gregion_AxInFig

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

button = 0;
xy = [-Inf -Inf];
k = 0;
figure(hf);
% Set axis limits
set(ha, 'Units', 'Inches')
pos = get(ha,'Position');
set(ha, 'Units', 'normalized')
xlim(ha,'manual')
ylim(ha,'manual')
% Empty handle for points and lines
h={};
l={};
set(h_pan,'Enable','off')
set(h_zoom,'State','off')
set(h_cursor,'Enable','off')
hp = get(ha,'Parent');

% Callback
set(hf,'WindowButtonMotionFcn',{@changepointer,ha},'WindowButtonDownFcn',{@getpoints,ha},'WindowKeyReleaseFcn',@exit)

% Wait for mouseclick
waitfor(hf,'WindowButtonDownFcn',[])

% Reset callbacks
set(hf,'Pointer','arrow')
set(hf,'WindowButtonMotionFcn',[],'WindowKeyReleaseFcn',[])
set(h_pan,'ActionPreCallback',[],'ActionPostCallback',[])

% Now delete all impoints and imlines
for n=1:length(h)
    delete(h{n})
    delete(l{n})
end

varargout{1} = xy;

    function changepointer(hf,~,ha)
        if strcmp(h_pan.Enable,'on')
            return
        elseif strcmp(h_cursor.Enable,'on')
            set(h_cursor,'Enable','off')
        end
        pntr2 = get(hf,'CurrentPoint');
        pntr = get(ha,'CurrentPoint');
        p1 = getpixelposition(hp,true);
        xl = get(ha,'Xlim');
        yl = get(ha,'Ylim');
        if ( ( (pntr(1,1)-xy(1,1))/(xl(2)-xl(1))*pos(3) )^2 + ( (pntr(1,2)-xy(1,2))/(yl(2)-yl(1))*pos(4) )^2 ) < 0.01 
            set(hf,'Pointer','circle')
            ok = 1;
        elseif pntr2(1,1)>p1(1) && pntr2(1,1)<p1(1)+p1(3) && pntr2(1,2)>p1(2) && pntr2(1,2)<p1(2)+p1(4)
            set(hf,'Pointer','crosshair')
            ok = 1;
        else
            set(hf,'Pointer','arrow')
            ok = 0;
        end
        if k~=0 && ok==1
            set(l{k*2-1},'XData',[xy(k,1) pntr(1,1)],'YData',[xy(k,2) pntr(1,2)])
            set(l{k*2},'XData',[xy(k,1) pntr(1,1)],'YData',[xy(k,2) pntr(1,2)])
        elseif k~=0 && ok==0
            set(l{k*2-1},'XData',[xy(k,1) xy(1,1)],'YData',[xy(k,2) xy(1,2)])
            set(l{k*2},'XData',[xy(k,1) xy(1,1)],'YData',[xy(k,2) xy(1,2)])
        end
    end
    function getpoints(src,event,ha)
        pntr = get(hf,'Pointer');
        cp = get(ha,'CurrentPoint');
        button = get(hf, 'SelectionType');
        if strcmp(pntr,'arrow')
            xy = [];
            set(hf,'WindowButtonDownFcn',[])
        elseif ~strcmp(button, 'normal') 
            xy = [xy(1:k,:);xy(1,1:2)];
            set(hf,'WindowButtonDownFcn',[])
        elseif strcmp(pntr,'circle')
            xy = [xy(1:k,:);xy(1,1:2)];
            set(hf,'WindowButtonDownFcn',[])
        else
            xy = [xy(1:k,:);cp(1,1:2)];
            k=k+1;
            l{k*2-1} = line([xy(k,1) xy(k,1)],[xy(k,2) xy(k,2)],'LineStyle','-','LineWidth',2,'Color',[1 1 1],'Parent',ha);
            l{k*2} = line([xy(k,1) xy(k,1)],[xy(k,2) xy(k,2)],'LineStyle','-','LineWidth',1,'Color',[0.28 0.28 0.97],'Parent',ha);
            h{k*2-1} = line(xy(k,1),xy(k,2),'LineStyle','-','LineWidth',0.5,'Color',[0 0 0],'MarkerEdgeColor',[0.28 0.28 0.97],'Marker','o','MarkerFaceColor',[0.28 0.28 0.97],'MarkerSize',4.5,'Parent',ha);
            h{k*2} = line(xy(k,1),xy(k,2),'LineStyle','-','LineWidth',0.5,'Color',[0.28 0.28 0.97],'MarkerEdgeColor','auto','Marker','+','MarkerFaceColor','none','MarkerSize',9,'Parent',ha);
        end
    end
    function exit(~,event)
        if strcmp(event.Key,'escape')
            xy = [];
            set(hf,'WindowButtonDownFcn',[])
        end
    end
end