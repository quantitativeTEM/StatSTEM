function changeWidthType(jObject,event,h,widthtype,but2,but3)
% changeWidthType - Select a new widthtype for fitting
%
% Update the selected widthtype for fitting the gaussian model to an image
% in the StatSTEM interface
%
%   syntax: changeWidthType(jObject,event,h,widthtype,but2,but3)
%       jObject   - Reference to button
%       event     - structure recording button events
%       h         - structure holding references to GUI interface
%       widthtype - widthtype (0 = 'different', 1 = 'same', 2 = 'user defined')
%       but2      - reference to second widthtype button
%       but3      - reference to third widthtype button
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Check if no other routine is running
userdata = get(h.right.tabgroup,'Userdata');
if (userdata.callbackrunning)
    % First turn off zoom, pan and datacursor
	turnOffFigureSelection(h);
    % If so store function name and variables and cancel other function
    userdata.function.name = mfilename;
    userdata.function.input = {jObject,event,h,widthtype,but2,but3};
    set(h.right.tabgroup,'Userdata',userdata)
    robot = java.awt.Robot;
    robot.keyPress(java.awt.event.KeyEvent.VK_ESCAPE);
    robot.keyRelease(java.awt.event.KeyEvent.VK_ESCAPE);
    return
end

% Load tab
tab = loadTab(h);
% Load fit options
usr = get(tab,'Userdata');

if jObject.isSelected
    but2.setSelected(false)
    but3.setSelected(false)
else
    but2.setSelected(true)
    but3.setSelected(false)
    if widthtype==1
        widthtype = 0;
    elseif widthtype==0
        widthtype = 2;
    else
        widthtype = 1;
    end
end
if any(strcmp(fieldnames(usr.file.input),'rho'))
    usr.file.input = rmfield(usr.file.input,'rho');
end
if widthtype == 2
    if length(usr.fitOpt.model.rho_start)~=max(usr.file.input.coordinates(:,3));
        usr.fitOpt.model.rho_start = zeros(max(usr.file.input.coordinates(:,3)),1);
    end
    usr.file.input.rho = usr.fitOpt.model.rho_start(usr.file.input.coordinates(:,3));
end
usr.fitOpt.model.widthtype = widthtype;
set(tab,'Userdata',usr)
