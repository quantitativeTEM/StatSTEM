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
switch lower(get(obj,'Tag'))
    case 'input coordinates'
        txt = {['X: ',num2str(pos(1)),' ',char(197)],...
	      ['Y: ',num2str(pos(2)),' ',char(197)]};
    case 'fitted coordinates'
        txt = {['X: ',num2str(pos(1)),' ',char(197)],...
	      ['Y: ',num2str(pos(2)),' ',char(197)]};
    case 'image'
        obs = get(obj,'CData');
        xdata = get(obj,'XData');
        ydata = get(obj,'YData');
        x = round(pos(1)/xdata(1));
        y = round(pos(2)/ydata(1));
        if size(obs,3)==1
            txt = {['X: ',num2str(pos(1)),' ',char(197)],...
                  ['Y: ',num2str(pos(2)),' ',char(197)],...
                  ['Index: ',num2str(obs(y,x))]};
        else
            txt = {['X: ',num2str(pos(1)),' ',char(197)],...
                  ['Y: ',num2str(pos(2)),' ',char(197)]};
        end
    case 'atom counts'
        txt = {['X: ',num2str(pos(1)),' ',char(197)],...
	      ['Y: ',num2str(pos(2)),' ',char(197)],...
          ['Count: ',num2str(pos(3)),' atoms']};
    case 'strain'
        dist = sqrt( (pos(1)-get(obj,'XData')).^2 + (pos(2)-get(obj,'YData')).^2 );
        val = get(obj,'Userdata')';
        txt = {['X: ',num2str(pos(1)),' ',char(197)],...
	      ['Y: ',num2str(pos(2)),' ',char(197)],...
          ['value: ',num2str(val(dist==min(dist)))]};
    otherwise
        txt = {['X: ',num2str(pos(1))],...
	      ['Y: ',num2str(pos(2))]};
end
