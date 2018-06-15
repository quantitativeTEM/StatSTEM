function popupPressed(jObject,event,func,h,button)
% popupPressed - Change callback function of java popupmenu
%
% This function gathers information and passes this to the 
%
%   syntax: popupPressed(jObject,event,func,h,button)
%       jObject - Reference to button
%       event   - structure recording button events
%       func    - name of the function
%       h       - structure holding references to StatSTEM interface
%       button  - Matlab reference to button
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Check which item is selected
option = char(get(jObject,'SelectedObjects'));

%% Ensure that old results are removed
name = mfilename;
[tab,usr] = newFuncCheck(jObject,event,func,h,button,name);
if isempty(tab) || isempty(usr)
    tab = loadTab(h);
    if ~isempty(tab)
        % Load file
        usr = get(tab,'Userdata');
        file = usr.file;
        % Update StatSTEM to restore index if necessary
        updateStatSTEM(h,file);
    end
    return
end
file = usr.file;

%% Run function
if isempty(func)
    in1 = button.selOptInput;
    loc = strfind(in1,'.');
    if ~isempty(loc) % A variable can be updated
        in2 = in1(loc(1)+1:end);
        in1 = in1(1:loc(1)-1);
        file.(in1).(in2) = option;
    end

    % Update StatSTEM
    updateStatSTEM(h,file);
    
    % Make sure correct figure is shown
    showFigureWithOption(h,button.figEnd,button.figOptEnd,button.reshowFigEnd)
else
    initiateFunction(func,button,h,option);
end