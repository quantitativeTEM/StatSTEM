function showScalebar(hObject,event,ref)
% showScalebar - add or remove a scalebar in the current image
%
%   syntax: showScalebar(hObject,event,ref)
%       hObject - reference to object
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

% Check if no other routine is running
userdata = get(ref,'Userdata');
if (userdata.callbackrunning)
    % If so store function name and variables and cancel other function
    userdata.function.name = mfilename;
    userdata.function.input = {hObject,event,ref};
    set(ref,'Userdata',userdata)
    robot = java.awt.Robot;
    robot.keyPress(java.awt.event.KeyEvent.VK_ESCAPE);
    robot.keyRelease(java.awt.event.KeyEvent.VK_ESCAPE);
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

% Check if a compatible image is shown
value = get(usr.figOptions.selImg.listbox,'Value');
str = get(usr.figOptions.selImg.listbox,'String');
if strcmp(str{value},'Observation') || strcmp(str{value},'Model')
    val1 = get(hObject,'Value');
    val = true & val1==1;
else
    val = false;
end

% Show scalebar if necessary
dim = str2double(get(usr.figOptions.optFig.scaleVal,'String'));
if val
    plotScalebar(usr.images.ax,dim);
else
    deleteImageObject(usr.images.ax,'Scalebar')
end