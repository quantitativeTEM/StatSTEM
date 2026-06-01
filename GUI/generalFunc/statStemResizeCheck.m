function statStemResizeCheck(t, fig)
% Timer to catch maximize/restore which don't fire SizeChangedFcn
if ~ishandle(fig)
    stop(t); delete(t); return;
end

persistent lastSize lastFig lastState;

% Reset if this is a different figure than last time
if isempty(lastFig) || lastFig ~= fig
    lastSize  = [];
    lastFig   = fig;
    lastState = '';
end

% Check both size and window state
pos   = get(fig, 'Position');
state = get(fig, 'WindowState');

sizeChanged  = ~isequal(pos, lastSize);
stateChanged = ~isequal(state, lastState);

if sizeChanged || stateChanged
    lastSize  = pos;
    lastState = state;
    % Skip minimize — nothing to resize
    if strcmp(state, 'minimized')
        return
    end
    h = guidata(fig);
    if ~isempty(h) && isfield(h,'right') && isfield(h.right,'tabgroup') && ishandle(h.right.tabgroup)
        userdata = get(h.right.tabgroup,'Userdata');
        if ~isempty(userdata) && isfield(userdata,'dim_y')
            Resize_figure(fig, [], h);
        end
    end
end