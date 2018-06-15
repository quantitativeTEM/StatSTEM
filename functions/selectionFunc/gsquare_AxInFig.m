function varargout = gsquare_AxInFig(ha,h_pan,h_cursor)
% gsquare_AxInFig - Graphical input from mouse or cursor
%
% gsquare_AxInFig raises crosshairs in the current axes to for you to select
% a squared region in the figure, positioning the cursor with the mouse. Press 
% escape to exit mode
%
%   syntax: varargout = gregion_AxInFig(ha,h_pan,h_cursor)
%       ha        - reference to axes
%       h_pan     - reference to pan object
%       h_cursor  - reference to data cursor object
%       varargout - output ([x y])
%
% See also: gregion_AxInFig

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if nargin<1
    ha = gca;
    axes(ha)
end

button = 0;
xy = [-Inf -Inf];
k = 0;
hf = gcf;
if nargin<2
    h_pan = pan(hf);
end
set(h_pan,'Enable','off')
zoom off
if nargin<3
    h_cursor = datacursormode(hf);
end
set(h_cursor,'Enable','off')
hp = get(ha,'Parent');

% Set axis limits
set(ha, 'Units', 'Inches')
pos = get(ha,'Position');
set(ha, 'Units', 'normalized')
xlim(ha,'manual')
ylim(ha,'manual')
% Empty handle for points and lines
l=cell(8,1);

% Callback
set(hf,'WindowButtonMotionFcn',{@changepointer,ha},'WindowButtonDownFcn',{@getpoints,ha},'WindowKeyReleaseFcn',@exit)

% Wait for mouseclick
waitfor(hf,'WindowButtonDownFcn',[])

% Reset callbacks
set(hf,'Pointer','arrow')
set(hf,'WindowButtonMotionFcn',[],'WindowKeyReleaseFcn',[])
set(h_pan,'ActionPreCallback',[],'ActionPostCallback',[])

% Now delete all impoints and imlines
for n=1:length(l)
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
        if hp==hf
            p1([1,2]) = [0,0];
        end
        getpixelposition(ha,true);
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
            set(l{1},'XData',[xy(1,1) pntr(1,1)],'YData',[xy(1,2) xy(1,2)])
            set(l{2},'XData',[xy(1,1) pntr(1,1)],'YData',[xy(1,2) xy(1,2)])
            set(l{3},'XData',[pntr(1,1) pntr(1,1)],'YData',[xy(1,2) pntr(1,2)])
            set(l{4},'XData',[pntr(1,1) pntr(1,1)],'YData',[xy(1,2) pntr(1,2)])
            set(l{5},'XData',[xy(1,1) xy(1,1)],'YData',[xy(1,2) pntr(1,2)])
            set(l{6},'XData',[xy(1,1) xy(1,1)],'YData',[xy(1,2) pntr(1,2)])
            set(l{7},'XData',[xy(1,1) pntr(1,1)],'YData',[pntr(1,2) pntr(1,2)])
            set(l{8},'XData',[xy(1,1) pntr(1,1)],'YData',[pntr(1,2) pntr(1,2)])
        elseif k~=0 && ok==0
            set(l{1},'XData',[xy(1,1) xy(1,1)],'YData',[xy(1,2) xy(1,2)])
            set(l{2},'XData',[xy(1,1) xy(1,1)],'YData',[xy(1,2) xy(1,2)])
            set(l{3},'XData',[xy(1,1) xy(1,1)],'YData',[xy(1,2) xy(1,2)])
            set(l{4},'XData',[xy(1,1) xy(1,1)],'YData',[xy(1,2) xy(1,2)])
            set(l{5},'XData',[xy(1,1) xy(1,1)],'YData',[xy(1,2) xy(1,2)])
            set(l{6},'XData',[xy(1,1) xy(1,1)],'YData',[xy(1,2) xy(1,2)])
            set(l{7},'XData',[xy(1,1) xy(1,1)],'YData',[xy(1,2) xy(1,2)])
            set(l{8},'XData',[xy(1,1) xy(1,1)],'YData',[xy(1,2) xy(1,2)])
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
            xy = [];
            set(hf,'WindowButtonDownFcn',[])
        elseif strcmp(pntr,'circle')
            xy = [];
            set(hf,'WindowButtonDownFcn',[])
        else
            xy = [xy(1:k,:);cp(1,1:2)];
            if k==0
                k=1;
                l{1} = line([xy(k,1) xy(k,1)],[xy(k,2) xy(k,2)],'LineStyle','-','LineWidth',2,'Color',[1 1 1],'Parent',ha);
                l{2} = line([xy(k,1) xy(k,1)],[xy(k,2) xy(k,2)],'LineStyle','-','LineWidth',1,'Color',[0.28 0.28 0.97],'Parent',ha);
                l{3} = line([xy(k,1) xy(k,1)],[xy(k,2) xy(k,2)],'LineStyle','-','LineWidth',2,'Color',[1 1 1],'Parent',ha);
                l{4} = line([xy(k,1) xy(k,1)],[xy(k,2) xy(k,2)],'LineStyle','-','LineWidth',1,'Color',[0.28 0.28 0.97],'Parent',ha);
                l{5} = line([xy(k,1) xy(k,1)],[xy(k,2) xy(k,2)],'LineStyle','-','LineWidth',2,'Color',[1 1 1],'Parent',ha);
                l{6} = line([xy(k,1) xy(k,1)],[xy(k,2) xy(k,2)],'LineStyle','-','LineWidth',1,'Color',[0.28 0.28 0.97],'Parent',ha);
                l{7} = line([xy(k,1) xy(k,1)],[xy(k,2) xy(k,2)],'LineStyle','-','LineWidth',2,'Color',[1 1 1],'Parent',ha);
                l{8} = line([xy(k,1) xy(k,1)],[xy(k,2) xy(k,2)],'LineStyle','-','LineWidth',1,'Color',[0.28 0.28 0.97],'Parent',ha);
            else
                set(hf,'WindowButtonDownFcn',[])
            end
        end
    end
    function exit(~,event)
        if strcmp(event.Key,'escape')
            xy = [];
            set(hf,'WindowButtonDownFcn',[])
        end
    end
end