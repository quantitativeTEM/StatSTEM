function updateOffset(jObject,event,h)
% updateOffset - Update the atomcounting results
%
% Use a new offset for the atomcounting results. Update the figures in the
% StatSTEM interface
%
%   syntax: updateOffset(jObject,event,h)
%       jObject - Reference to object
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

if ~jObject.isEnabled
    return
end

str = get(jObject,'Text');
num = str2double(str);
if isempty(str) || strcmp(str,'-')
    error = 1;
elseif isnan(num)
    error = 1;
elseif num<0
    error = 1;
else
    error = 0;
end

% Continue, load tab and userdata
tab = loadTab(h);
if isempty(tab)
    return
end
% Load image
usr = get(tab,'Userdata');

if error
    set(jObject,'Text',num2str(usr.file.atomcounting.offset));
    h_error = errordlg('Error: Please insert a positive number');
    waitfor(h_error)
    return
end

usr.file.atomcounting.offset = num;

% Update atom counting
usr.file.atomcounting = getAtomCounts(usr.file.atomcounting);

% Update file
set(tab,'Userdata',usr)

%% Update shown figure
str = get(usr.figOptions.selImg.listbox,'String');
val = get(usr.figOptions.selImg.listbox,'Value');
showImage(tab,str{val},h)