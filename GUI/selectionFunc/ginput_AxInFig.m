function varargout = ginput_AxInFig(ha,hf,h_pan,h_zoom,h_cursor)
% ginput_AxInFig - Graphical input from mouse or cursor
%
% ginput_AxInFig raises crosshairs in the current axes to for you to 
% identify points in the figure, positioning the cursor with the mouse.
% Press escape to exit mode
%
%   syntax: varargout = ginput_AxInFig(ha,hf,h_pan,h_zoom,h_cursor)
%       ha        - reference to axes
%       hf        - reference to figure
%       h_pan     - reference to pan object
%       h_zoom    - reference to zoom buttons
%       h_cursor  - reference to data cursor object
%       varargout - output ([x y], [x,y] or [x,y,button])
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
xy = [];
figure(hf);
set(h_pan,'Enable','off')
set(h_zoom,'State','off')
set(h_cursor,'Enable','off')

hp = get(ha,'Parent');

% Get edges of panel, relative to size of axes (left,bottom,right,top)
edges = get(ha,'Position');
edges = [edges(1)/(edges(3)-edges(1)), edges(2)/(edges(4)-edges(2)), (1-edges(3))/(edges(3)-edges(1)), (1-edges(4))/(edges(4)-edges(2))];

% Callback
set(hf,'WindowButtonMotionFcn',{@changepointer,ha},'WindowButtonDownFcn',{@getpoints,ha},'WindowKeyReleaseFcn',@exit)

% Wait for mouseclick
waitfor(hf,'WindowButtonDownFcn',[])

% Reset callbacks
set(hf,'Pointer','arrow')
set(hf,'WindowButtonMotionFcn',[],'WindowKeyReleaseFcn',[])
set(h_pan,'ActionPreCallback',[],'ActionPostCallback',[])

if nargout>=2
    if isempty(xy)
        varargout{1} = [];
        varargout{2} = [];
    else
        varargout{1} = xy(:,1);
        varargout{2} = xy(:,2);
    end
else
    varargout{1} = xy;
end
if nargout==3
    varargout{3} = button;
end

    function changepointer(hf,~,ha)
        if strcmp(h_pan.Enable,'on')
            return
        elseif strcmp(h_cursor.Enable,'on')
            set(h_cursor,'Enable','off')
        end
        pntr = get(ha,'CurrentPoint');
        xl = get(ha,'Xlim');
        yl = get(ha,'Ylim');
        if pntr(1,1)>xl(1) && pntr(1,1)<xl(2) && pntr(1,2)>yl(1) && pntr(1,2)<yl(2)
            set(hf,'Pointer','crosshair')
        else
            set(hf,'Pointer','arrow')
        end
    end
    function getpoints(src,event,ha)
        cp = get(ha,'CurrentPoint');
        button = get(hf, 'SelectionType');
        pntr = get(hf,'Pointer');
        if (strcmp(pntr, 'crosshair'))
            xy = cp(1,1:2);
        end
        set(hf,'WindowButtonDownFcn',[])
    end
    function exit(~,event)
        if strcmp(event.Key,'escape')
            set(hf,'WindowButtonDownFcn',[])
        end
    end
end