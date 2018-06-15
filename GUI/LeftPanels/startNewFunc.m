function startNewFunc(jObject,event,func,h,button)
% startNewFunc - Stop other running functions and start new function
%
% syntax: startNewFunc(jObject,event,h,func,button)
%       jObject - Reference to button
%       event   - event of java button
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

%% Ensure that old results are removed
name = mfilename;
[tab,usr] = newFuncCheck(jObject,event,func,h,button,name);
if isempty(tab) || isempty(usr)
    return
end

%% Run function
if isempty(func)
    file = usr.file;
    % Update StatSTEM
    updateStatSTEM(h,file);
    
    % Make sure correct figure is shown
    showFigureWithOption(h,button.figEnd,button.figOptEnd,button.reshowFigEnd)
else
    initiateFunction(func,button,h);
end
