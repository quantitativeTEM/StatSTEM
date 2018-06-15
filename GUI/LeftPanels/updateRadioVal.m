function updateRadioVal(jObject,event,func,h,button)
% updateRadioVal - Run function or update StatSTEM file
%
% syntax: updateRadioVal(jObject,event,func,h,button)
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

sel = get(jObject,'Selected');
if sel
    num = button.optN;
else
    num = ~button.optN*1;
end
    

%% Ensure that old results are removed
name = mfilename;
[tab,usr] = newFuncCheck(jObject,event,func,h,button,name);
if isempty(tab) || isempty(usr)
    return
end
file = usr.file;

%% Update variables (equalTo variables)
% If function is present, execute it otherwise update variables
if isempty(func)
    var = button.equalTo;
    for n=1:length(var)
        in1 = var{n};
        loc = strfind(in1,'.');
        if ~isempty(loc) % A variable can be updated
            in2 = in1(loc(1)+1:end);
            in1 = in1(1:loc(1)-1);
            file.(in1).(in2) = num;
        end
    end

    % Update StatSTEM
    updateStatSTEM(h,file);
    
    % Make sure correct figure is shown
    showFigureWithOption(h,button.figEnd,button.figOptEnd,button.reshowFigEnd)
else
    initiateFunction(func,button,h,num)
end