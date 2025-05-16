function createUIMenu2Axes(ax, cbar, refP, data, range, type, updateEdgeColorsFcn)
% createUIMenu2Axes - create a menu for colorbar in 2nd axes
%
%   syntax: createUIMenu2Axes(ax, cbar, refP, data, range, type, updateEdgeColorsFcn)
%       ax                  - reference to 2nd axis
%       cbar                - reference to colorbar
%       refP                - reference to plot
%       data                - values shown in plot
%       range               - color range of data [min,max]
%       type                - type of plot ('scatter' or 'quiver')
%       updateEdgeColorsFcn - OPTIONAL function handle to update edge colors

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018–2025, EMAT, University of Antwerp
% License: Open Source under GPLv3
%--------------------------------------------------------------------------

if nargin < 6
    type = 'scatter';
end

if nargin < 7
    updateEdgeColorsFcn = [];
end

switch type
    case 'quiver'
        type = 1;
    otherwise
        type = 2;
end

% Get handle to figure
v = version('-release');
v = str2double(v(1:4));
hf = get(refP, 'Parent');
stop = 0;
k = 0;
while ~stop && k < 100
    k = k + 1;
    hInt = get(hf, 'Parent');
    if v < 2015
        if hInt == 0
            stop = 1;
        else
            hf = hInt;
        end
    else
        if isa(hInt, 'matlab.ui.Root')
            stop = 1;
        else
            hf = hInt;
        end
    end
end

% Create uicontextmenu
c = uicontextmenu;
m1 = uimenu(c, 'Label', 'Delete', 'Callback', {@delBar, ax});
m2 = uimenu(c, 'Label', 'Open Colormap Editor', ...
    'Callback', @(src, evt) cmEdit(src, evt, ax, hf, refP, data, type, updateEdgeColorsFcn));
m3 = uimenu(c, 'Label', 'Reset Range Colors', ...
    'Callback', @(src, evt) resetCrangeAx2(src, evt, ax, refP, range, data, type, updateEdgeColorsFcn));

set(cbar, 'UIContextMenu', c);

end

%% Delete callback
function delBar(~, ~, ax)
imgP = get(ax, 'Parent');
child = get(imgP, 'Children');
warning('off', 'all') % Suppress for older MATLAB versions
for i = 1:length(child)
    if strcmp(get(child(i), 'Tag'), 'Colorbar')
        delete(child(i));
    end
end
warning('on', 'all')
end

%% Colormap editor
function cmEdit(~, ~, ax, hf, ref, data, type, updateEdgeColorsFcn)
range = caxis(ax);
cmap = colormap(ax);
pos = get(hf, 'Position');
range = setRangeUI(range, [pos(1)+pos(3)/2, pos(2)+pos(4)/2]);
caxis(ax, range);

c_x = linspace(range(1), range(2), size(cmap, 1));
RGBvec = getRGBvec(cmap, c_x, data, 'exact');

if type == 1
    set(ref, 'FaceVertexCData', RGBvec);
    if isa(updateEdgeColorsFcn, 'function_handle')
        updateEdgeColorsFcn(RGBvec);
    end
else
    set(ref, 'CData', RGBvec);
end
end

%% Reset color range
function resetCrangeAx2(~, ~, ax, ref, range, data, type, updateEdgeColorsFcn)
caxis(ax, range);
cmap = colormap(ax);
c_x = linspace(range(1), range(2), size(cmap, 1));
RGBvec = getRGBvec(cmap, c_x, data, 'exact');

if type == 1
    set(ref, 'FaceVertexCData', RGBvec);
    if isa(updateEdgeColorsFcn, 'function_handle')
        updateEdgeColorsFcn(RGBvec);
    end
else
    set(ref, 'CData', RGBvec);
end
end
