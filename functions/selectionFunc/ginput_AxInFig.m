function varargout = ginput_AxInFig(ha,h_pan,h_cursor,hf)
% ginput_AxInFig - Graphical input from mouse or cursor
%
% ginput_AxInFig raises crosshairs in the current axes to for you to 
% identify points in the figure, positioning the cursor with the mouse.
% Press escape to exit mode
%
%   syntax: varargout = ginput_AxInFig(ha,h_pan,h_cursor)
%       ha        - reference to axes
%       h_pan     - reference to pan object
%       h_cursor  - reference to data cursor object
%       varargout - output ([x y], [x,y] or [x,y,button])
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
end

hp = get(ha,'Parent');

button = 0;
xy = [];
if nargin<4
    hf = gcf;
end

figure(hf);
axes(gca)
if nargin<2
    h_pan = pan(hf);
end
set(h_pan,'Enable','off')
zoom OFF
if nargin<3
    h_cursor = datacursormode(hf);
end
h_cursor.removeAllDataCursors();

% Callback
set(hf,'WindowButtonMotionFcn',{@changepointer,ha},'WindowButtonDownFcn',{@getpoints,ha},'WindowKeyReleaseFcn',@exit)
% set(hp,'WindowKeyReleaseFcn',@exit)

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
        if any(strcmp(get(h_pan,'Enable'),'on'))
            return
        elseif any(strcmp(get(h_cursor,'Enable'),'on'))
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