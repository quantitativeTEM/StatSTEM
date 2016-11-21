function selRefType(hObject,event,h,indOld)
% selRefType - Callback for selecting type of reference atom for strain mapping
%
%   syntax: selRefType(hObject,event)
%       hObject - reference to dropdownmenu
%       event   - structure recording button events
%       h       - structure holding references to StatSTEM interface
%       indOld  - old selected index
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% First check if new item is selected
ind = get(hObject,'SelectedIndex');
if ind==indOld
    return
end

% Load the selected tab
tab = loadTab(h);
if isempty(tab)
    h_mes = errordlg('First load an image');
    waitfor(h_mes)
    return
end

usr = get(tab,'Userdata');
% Delete previous analysis is necessary
if any(strcmp(fieldnames(usr.file),'strainmapping'))
    quest = questdlg('Selecting a new type will remove all previous strain mapping results, continue?','Warning','Yes','No','No');
    drawnow; pause(0.05); % MATLAB hang 2013 version
    switch quest
        case 'Yes'
            deleteStrainMapping(tab,h)
        case 'No'
            set(hObject,'SelectedIndex',indOld);
            return
    end
end

