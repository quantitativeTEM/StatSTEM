function changeScale(hObject,event,ref)
% changeScale - Callback for changing the scalebar size
%
%   syntax: changeScale(hObject,event,ref)
%       hObject - Reference to object
%       event   - structure recording button events
%       ref     - reference to selected tab
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------



% Check if value is correct
str = get(hObject,'String');
num = str2double(str);
if isempty(str) || strcmp(str,'-')
    error = 1;
elseif isnan(num)
    error = 1;
elseif num<0 || abs(num)~=num
    error = 1;
else
    error = 0;
end

% Find reference to tab and the userdata
tab = get(ref,'SelectedTab');
usr = get(tab,'Userdata');

% If the number is incorrect, cancel operation
if error
    set(hObject,'String',usr.oldScalebar);
    h_error = errordlg('Error: Please insert a positive number');
    waitfor(h_error)
    return
end

% Check if an image is shown
n = length(get(ref,'Children'));
if n==1
    return
end

% Find reference to tab and the userdata
tab = get(ref,'SelectedTab');
usr = get(tab,'Userdata');
data = get(usr.images.ax,'Userdata');
ind = strcmp(data(:,1),'Scalebar');
if any(ind)
    % Update scalebar
    deleteImageObject(usr.images.ax,'Scalebar')
    plotScalebar(usr.images.ax,num);
end

% Update userdata
usr.oldScalebar = num;
set(tab,'Userdata',usr)