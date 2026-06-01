function statStemWindowStateChanged(fig, ~)
% statStemWindowStateChanged - Handle window maximize/restore/minimize
if ~ishandle(fig)
    return
end
% Small pause to let MATLAB finish the window state change
pause(0.1);
h = guidata(fig);
if ~isempty(h) && isfield(h, 'right') && isfield(h.right, 'tabgroup') && ishandle(h.right.tabgroup)
    userdata = get(h.right.tabgroup, 'Userdata');
    if ~isempty(userdata) && isfield(userdata, 'dim_y')
        Resize_figure(fig, [], h);
    end
end