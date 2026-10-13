function updateTextVal(hObject, event, func, h, button)
% updateTextVal - Run function or update StatSTEM file from an editfield
%
%   syntax: updateTextVal(hObject, event, func, h, button)
%       hObject - uicontrol handle that triggered the callback
%       event   - callback event data
%       func    - name of the function (empty = update variable directly)
%       h       - structure holding references to StatSTEM interface
%       button  - StatSTEM editfield object
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

str = get(hObject, 'String');
num = str2double(str);

name = mfilename;
[tab, usr] = newFuncCheck(hObject, event, func, h, button, name);
if isempty(tab) || isempty(usr)
    return
end
file = usr.file;

if isempty(func)
    var = button.equalTo;
    for n = 1:length(var)
        in1 = var{n};
        loc = strfind(in1,'.');
        if ~isempty(loc)
            in2 = in1(loc(1)+1:end);
            in1 = in1(1:loc(1)-1);
            file.(in1).(in2) = num;
        end
    end
    updateStatSTEM(h, file);
    showFigureWithOption(h, button.figEnd, button.figOptEnd, button.reshowFigEnd)
else
    initiateFunction(func, button, h, num)
end
