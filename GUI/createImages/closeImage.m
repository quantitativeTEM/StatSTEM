function closeImage(hObject,event,tab,h)
% closeImage - Close an opened file
%
% Close and and delete all reference to an opened file in the user 
% interface.
%
%   syntax: closeImage(hObject,event,tab,h)
%       hObject - Reference to button
%       event   - structure recording button events
%       tab     - Reference to tab showing the file
%       h       - structure holding references to GUI interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Change selected tab
tabs = get(h.right.tabgroup,'Children');
ind = tabs==tab;
if length(tabs)==2
    new = 2;
    set(tabs(new),'ButtonDownFcn',{@loadFile,h})
    file = [];
else
    if find(ind)==1
        new = 2;
    else
        new = find(ind)-1;
    end
    usr = get(tabs(new),'Userdata');
    file = usr.file;
end
set(h.right.tabgroup,'SelectedTab',tabs(new))
updateLeftPanels(h,file)

% Reset zoom in function
zoomReset(h)

% Now delete old tab
usr = get(tab,'Userdata');
% Store name of old file
filename = usr.file.input.name;

% Delete everything related to the image
figNames = fieldnames(usr.figOptions);

% Figure options
for n=1:length(figNames)
    names = fieldnames(usr.figOptions.(figNames{n}));
    for m=1:length(names)
        delete(usr.figOptions.(figNames{n}).(names{m}))
    end
end
usr = rmfield(usr,'figOptions');

% Images
imgNames = fieldnames(usr.images);
for n=1:length(imgNames)
    delete(usr.images.(imgNames{n}))
end
usr = rmfield(usr,'images');

% File
usr = rmfield(usr,'file');

% Delete tab
delete(tab)

message = ['The file ',filename,' is closed'];
newMessage(message,h)