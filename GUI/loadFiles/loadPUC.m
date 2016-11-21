function loadPUC(hObject,event,h)
% loadPUC - Load a 2D UC file into the StatSTEM interface
%
%   syntax: loadPUC(hObject,event,h)
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
if ~hObject.isEnabled
    return
end

[tab,mes] = loadTab(h);
if isempty(tab)
    h_mes = errordlg(mes);
    waitfor(h_mes)
    return
end

% Get input structure
usr = get(tab,'Userdata');
input = usr.file.input;
if any(strcmp(fieldnames(input),'projUnit'))
    unit = input.projUnit;
else
    unit = struct;
end

% Get position GUI, to center dialog
pos = get(h.fig,'Position');
if exist(h.datPath, 'file')==0
    path = [];
else
    fileID = fopen(h.datPath);
    path = textscan(fileID, '%s', 'delimiter', '\n');
    path = path{1}{1};
    fclose(fileID);
end

% Start GUI
[unit,path2,ok] = projUCgui(unit,'Center',[pos(1)+pos(3)/2 pos(2)+pos(4)/2],'PathData',path);
if path2~=0
    path = path2;
end

if ok
    % Check if values are correct
    if unit.a<=0 || unit.b<=0
        ok = 0;
    end
    if any(isempty(unit.atom2D{1}))
        ok = 0;
    end
end
    
if ok
    if any(strcmp(fieldnames(usr.file),'strainmapping'))
        if any(strcmp(fieldnames(usr.file.strainmapping),'coor_relaxed'))
            % Check if unit cell has changed
            if unit.a~=usr.file.input.projUnit.a || unit.b~=usr.file.input.projUnit.b ||...
                    unit.ang~=usr.file.input.projUnit.ang || any(unit.coor2D(:,1)~=usr.file.input.projUnit.coor2D(:,1)) ||...
                    any(unit.coor2D(:,2)~=usr.file.input.projUnit.coor2D(:,2)) || any(~strcmp(unit.atom2D,usr.file.input.projUnit.atom2D))
                changed = 1;
            else
                changed = 0;
            end
            if changed
                quest = questdlg('The projected unit cell has changed. Results from strain mapping will be deleted, continue?','Warning','Yes','No','No');
                drawnow; pause(0.05); % MATLAB hang 2013 version
                switch quest
                    case 'Yes'
                        deleteStrainMapping(tab,h,'Ref strainmapping')
                        usr = get(tab,'Userdata');
                    case 'No'
                        return
                end
            end
        end
    end
    % Update StatSTEM
    usr.file.input.projUnit = unit;
    % Update message
    message = sprintf(['A projected unit cell was added to the file ', usr.FileName]);
    newMessage(message,h)
end
set(tab,'Userdata',usr);

% Store new pathname
fileID = fopen(h.datPath,'wt');
str = strrep(path,'\','\\');
fprintf(fileID, str);
fclose(fileID);

% Update left panels
updateLeftPanels(h,usr.file,usr.fitOpt)