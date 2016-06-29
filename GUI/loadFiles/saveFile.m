function saveFile(hObject,event,h)
% saveFile - Save a file from the StatSTEM interface
%
%   syntax: saveFile(hObject,event,h)
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

% Check if no other routine is running
userdata = get(h.right.tabgroup,'Userdata');
if (userdata.callbackrunning)
    % If so store function name and variables and cancel other function
    userdata.function.name = mfilename;
    userdata.function.input = {hObject,event,h};
    set(h.right.tabgroup,'Userdata',userdata)
    robot = java.awt.Robot;
    robot.keyPress(java.awt.event.KeyEvent.VK_ESCAPE);
    robot.keyRelease(java.awt.event.KeyEvent.VK_ESCAPE);
    return
end

% Check if button is enabled
if ~strcmp(get(hObject,'Enable'),'on')
    return
end

[tab,mes] = loadTab(h);
if isempty(tab)
    h_mes = errordlg(mes);
    waitfor(h_mes)
    return
end

% Load image
usr = get(tab,'Userdata');

[FileName,PathName] = uiputfile({'*.mat','MATLAB Files (*.mat)'}, ...
   'Select a location',[usr.PathName filesep usr.FileName '.mat']);

if FileName~=0
    % Save file
    file = usr.file;
    save([PathName,FileName],'-struct','file');
    
    % Update filename and pathname in GUI
    [~, usr.FileName, ~] = fileparts(FileName);
    userdata = get(h.right.tabgroup,'Userdata');
    userdata.PathName = PathName;
    set(h.right.tabgroup,'Userdata',userdata)
    set(tab,'Userdata',usr)
    
    % Update the name of the tab and the tooltipstring
    if length(usr.FileName)>18
        tabName = [usr.FileName(1:15),'...'];
    else
        tabName = usr.FileName;
    end
    set(tab,'Title',tabName);
    v = version('-release');
    if strcmp(v(1:4),'2015')
        set(tab,'TooltipString',usr.FileName);
    end
    
    % Update message box
    message = sprintf(['The file ',FileName,' was successfully saved']);
    newMessage(message,h)
    
    % Store new pathname
    fileID = fopen(h.startPath,'wt');
    str = strrep(userdata.PathName,'\','\\');
    fprintf(fileID, str);
    fclose(fileID);
end

