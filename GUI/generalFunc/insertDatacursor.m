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
        txt = {['X: ',num2str(pos(1)),' Å'],...
	      ['Y: ',num2str(pos(2)),' Å']};
    case 'fitted coordinates'
        txt = {['X: ',num2str(pos(1)),' Å'],...
	      ['Y: ',num2str(pos(2)),' Å']};
    case 'image'
        obs = get(obj,'CData');
        xdata = get(obj,'XData');
        ydata = get(obj,'YData');
        x = round(pos(1)/xdata(1));
        y = round(pos(2)/ydata(1));
        if size(obs,3)==1
            txt = {['X: ',num2str(pos(1)),' Å'],...
                  ['Y: ',num2str(pos(2)),' Å'],...
                  ['Index: ',num2str(obs(y,x))]};
        else
            txt = {['X: ',num2str(pos(1)),' Å'],...
                  ['Y: ',num2str(pos(2)),' Å']};
        end
    case 'atom counts'
        txt = {['X: ',num2str(pos(1)),' Å'],...
	      ['Y: ',num2str(pos(2)),' Å'],...
          ['Count: ',num2str(get(obj,'Userdata')),' atoms']};
    otherwise
        txt = {['X: ',num2str(pos(1))],...
	      ['Y: ',num2str(pos(2))]};
end
