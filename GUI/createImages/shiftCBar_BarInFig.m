function shiftCBar_BarInFig(hb,ha,hf,menu)
% shiftCBar_BarInFig - Update colormap of figure in StatSTEM interface
%
% Enable interactive colormap shifts
%
%   syntax: shiftCBar_BarInFig(hb,ha,hf,menu)
%       hb      - reference to colorbar
%       ha      - reference to axes
%       hf      - reference to figure
%       menu    - reference to menu item enabling interactive colormap
%                 shift
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% First turn off zoom, pan and datacursor
h_pan = pan(hf);
h_zoom = zoom(hf);
h_cursor = datacursormode(hf);
set(h_pan,'Enable','off')
set(h_zoom,'Enable','off')
set(h_cursor,'Enable','off')

y_int = [];
x = [];
cmap = colormap(ha);
s = size(cmap,1);
ind = 1:s;
s = s-1;

set(hb,'Units','pixels')
pos = get(hb,'Position');
set(hb,'Units','normalized')
parent = get(hb,'Parent');
while parent~=hf
    set(parent,'Units','pixels')
    pp = get(parent,'Position');
    set(parent,'Units','normalized')
    parent = get(parent,'Parent');
    pos(1) = pos(1) + pp(1);
    pos(2) = pos(2) + pp(2);
end

% Callback
set(hf,'WindowButtonMotionFcn',@changepointer,'WindowKeyReleaseFcn',@exit,'WindowButtonDownFcn',{@getpoints},'WindowButtonUpFcn',{@clearpoints});

% Wait for mouseclick
waitfor(menu,'Checked','off')

% Reset callbacks
set(hf,'Pointer','arrow')
set(hf,'WindowButtonMotionFcn',[],'WindowKeyReleaseFcn',[],'WindowButtonUpFcn',[],'WindowButtonDownFcn',[])

    function changepointer(hf,~)
        if ~isvalid(hb)
            set(menu,'Checked','off')
        end
        pnt = get(hf,'CurrentPoint');
        if strcmp(h_pan.Enable,'on') || strcmp(h_zoom.Enable,'on') || strcmp(h_cursor.Enable,'on')
            return
        end
        if pnt(1,1)>pos(1) && pnt(1,1)<pos(1)+pos(3) && pnt(1,2)>pos(2) && pnt(1,2)<pos(2)+pos(4)
            set(hf,'Pointer','top')
        else
            set(hf,'Pointer','arrow')
        end
        if ~isempty(y_int)
            y_new = (pnt(1,2)-pos(2))/pos(4)*s+1;
            if y_new>=s+0.9
                x = (1:(y_int/(s+1)):y_int)';
            elseif y_new<=1.1
                x = (y_int:((s+1-y_int)/(s+1)):(s+1))';
            else
                ym = min((y_int)/(y_new)*ceil(y_new),64);
                x = [linspace(1,(y_int)/(y_new)*floor(y_new),floor(y_new)) linspace(ym,64,65-ceil(y_new))]';
            end
            cmap_new = [interp1(ind,cmap(:,1),x) interp1(ind,cmap(:,2),x) interp1(ind,cmap(:,3),x)];
            colormap(ha,cmap_new)
        end
    end
    function getpoints(hf,~)
        pntr = get(hf,'Pointer');
        pnt = get(hf,'CurrentPoint');
        button = get(hf, 'SelectionType');
        if strcmp(button,'normal')
            if (strcmp(pntr, 'top'))
                y_int = ( (pnt(1,2)-pos(2))/pos(4) )*s+1;
                cmap = colormap(ha);
                ind = 1:size(cmap,1);
            else
                set(menu,'Checked','off')
            end
        end
    end

    function clearpoints(~,~)
        y_int = [];
    end

    function exit(~,event)
        if strcmp(event.Key,'escape')
            set(menu,'Checked','off')
        end
    end
end