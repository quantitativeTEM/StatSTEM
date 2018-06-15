function changeMS(hObject,event,tab)
% changeMS - Callback for changing the marker size
%
%   syntax: changeMS(hObject,event,ref)
%       hObject - Reference to object
%       event   - structure recording button events
%       tab     - reference to selected tab
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

str = get(hObject,'String');
scaleMarker = str2double(str);
if isempty(str) || strcmp(str,'-')
    error = 1;
elseif isnan(scaleMarker)
    error = 1;
elseif scaleMarker<0 || abs(scaleMarker)~=scaleMarker
    error = 1;
else
    error = 0;
end

% Load tab userdata
usr = get(tab,'Userdata');

% If the number is incorrect, cancel operation
if error
    set(hObject,'String',usr.oldMarkerSize);
    h_error = errordlg('Error: Please insert a positive number');
    waitfor(h_error)
    return
end

% Check if an image is shown
if strcmp(get(tab,'Title'),'+')
    return
end

% Check if marker size is changed
if usr.oldMarkerSize == scaleMarker
    return
end

% Update marker size in file
fN = fieldnames(usr.file);
for i=1:length(fN)
    usr.file.(fN{i}).mscale = scaleMarker;
end
% Update userdata
usr.oldMarkerSize = scaleMarker;
set(tab,'Userdata',usr)



% Check which image options are shown and update them
val = get(usr.figOptions.selImg.listbox,'Value');
data = get(usr.figOptions.selOpt.(['optionsImage',num2str(val)]),'Data');
if ~isempty(data)
    n = length(data(:,1));
    ha = get(usr.images.ax,'Children');
    % First show updated data
    for i=1:n
        if data{i,1}
            showHideFigOptions(tab,data{i,2},true)
        end
    end
    % Now delete old data
    for i=1:length(ha)
        if ishandle(ha(i)) && any(strcmp(data(:,2),get(ha(i),'Tag')))
            delete(ha(i))
        end
    end
    set(usr.figOptions.selOpt.(['optionsImage',num2str(val)]),'Data',data)
end
