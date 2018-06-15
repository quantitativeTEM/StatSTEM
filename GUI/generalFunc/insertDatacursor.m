function insertDatacursor(hObject,event,h)
% insertDatacursor - Insert datacursor
%
% Modify label datacursor
%
%   syntax: insertDatacursor(hObject,event,h)
%       hObject - Reference to button
%       event   - structure recording button events
%       h       - structure holding references to GUI interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
tab = loadTab(h);
if isempty(tab)
    set(hObject,'State','off');
    return
end

state = get(hObject,'State');
dcm_obj = datacursormode(h.fig);userdata = get(h.right.tabgroup,'Userdata');
if strcmp(state,'off') || (userdata.callbackrunning)
    dcm_obj.removeAllDataCursors();
    set(dcm_obj,'Enable','off')
    set(hObject,'State','off')
    return
end

% Turn off zoom
zoomAxinFig(h,'off')
% Turn off pan
pan(h.fig,'off')
% turn on data cursor
set(dcm_obj,'Enable','on')
set(dcm_obj,'UpdateFCN',@myupdatefcn)

function txt = myupdatefcn(empt,event_obj)
% Customizes text of data tips

obj = get(event_obj,'Target');
pos = get(event_obj,'Position');
if strcmp(get(obj,'Type'),'image')
    txt = {['X: ',num2str(pos(1)),' ',char(197)],...
        ['Y: ',num2str(pos(2)),' ',char(197)]};
    xdata = abs(get(obj,'XData')-pos(1));
    ydata = abs(get(obj,'YData')-pos(2));
    idx = find(xdata==min(xdata));
    idy = find(ydata==min(ydata));
    data = get(obj,'CData');
    txtE = {sprintf(['Pixel value: ',num2str(data(idy(1),idx(1)))])};
    txt = [txt,txtE];
else
    txt = {['X: ',num2str(pos(1))],...
        ['Y: ',num2str(pos(2))]};
end
usr = get(obj,'Userdata');
if ~isempty(usr)
    dist = (get(obj,'XData')-pos(1)).^2 + (get(obj,'YData')-pos(2)).^2;
    idx = find(dist==min(min(dist)));
    txtE = {sprintf(usr{1},usr{2}(idx(1)))};
    txt = [txt,txtE];
end
