function matchLib(jObject,event,h)
% matchLib - Simulation based atomcounting in StatSTEM interface
%
%   Apply atomcounting by comparing experimentally measured scattering
%   cross-sections with a library of simulated values
%
%   syntax: matchLib(hObject,event,h)
%       hObject - java reference to button
%       event   - structure recording button events
%       h       - structure holding references to StatSTEM interface
%       

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

%% Preparation of function
% Check if no other routine is running
userdata = get(h.right.tabgroup,'Userdata');
if (userdata.callbackrunning)
    % First turn off zoom, pan and datacursor
    turnOffFigureSelection(h);
    % If so store function name and variables and cancel other function
    userdata.function.name = mfilename;
    userdata.function.input = {jObject,event,h};
    set(h.right.tabgroup,'Userdata',userdata)
    robot = java.awt.Robot;
    robot.keyPress(java.awt.event.KeyEvent.VK_ESCAPE);
    robot.keyRelease(java.awt.event.KeyEvent.VK_ESCAPE);
    return
end

% Check if button is enabled
if ~get(jObject,'Enabled')
    return
end

tab = loadTab(h);
if isempty(tab)
    h_mes = errordlg('First load an image');
    waitfor(h_mes)
    return
end

%% Preparation
% Delete previous analysis is necessary
usr = get(tab,'Userdata');
if any(strcmp(fieldnames(usr.file),'libcounting'))
    quest = questdlg('Starting a new counting procedure will remove previous simulation based counting results, continue?','Warning','Yes','No','No');
    drawnow; pause(0.05); % MATLAB hang 2013 version
    switch quest
        case 'Yes'
            deleteLibCounting(tab,h)
            usr = get(tab,'Userdata');
        case 'No'
            return
    end
end

%% Apply analysis
usr.file.libcounting.volumes = usr.file.output.volumes;
usr.file.libcounting.coordinates = usr.file.output.coordinates;
usr.file.libcounting.library = usr.file.input.library;
usr.file.libcounting.Counts = matchSCSwithSim(usr.file.libcounting.volumes,usr.file.libcounting.library);
usr.file.libcounting.TotalNumberAtoms = sum(usr.file.libcounting.Counts);
% Update userdata
set(tab,'Userdata',usr);

%% Update interface
createLibCounts(tab, h, 1)

% Now update left panels;
set(h.fig,'Userdata',[]);
updateLeftPanels(h,usr.file,usr.fitOpt)