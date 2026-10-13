function startNewFunc(hObject, event, func, h, button)
% startNewFunc - Stop other running functions and start a new one
%
%   syntax: startNewFunc(hObject, event, func, h, button)
%       hObject - uicontrol handle that triggered the callback
%       event   - callback event data
%       func    - name of the function
%       h       - structure holding references to StatSTEM interface
%       button  - StatSTEM button object
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

name = mfilename;
[tab, usr] = newFuncCheck(hObject, event, func, h, button, name);
if isempty(tab) || isempty(usr)
    return
end

if isempty(func)
    file = usr.file;
    updateStatSTEM(h, file);
    showFigureWithOption(h, button.figEnd, button.figOptEnd, button.reshowFigEnd)
else
    initiateFunction(func, button, h);
end
