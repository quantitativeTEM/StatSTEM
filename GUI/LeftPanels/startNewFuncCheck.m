function startNewFuncCheck(h)
% startNewFuncCheck - Check if other function should be started
%
% syntax: startNewFuncCheck(h)
%       h       - structure holding references to StatSTEM interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Update userdata
userdata = get(h.right.tabgroup,'Userdata');
userdata.callbackrunning = false; % For peak location routines
set(h.right.tabgroup,'Userdata',userdata);

% Check if other function is started
if isfield(userdata,'function') && ~isempty(userdata.function)
    f = userdata.function;
    userdata.function = [];
    userdata.startQue = [];
    set(h.right.tabgroup,'Userdata',userdata);
    eval([f.name,'(f.input{:})'])
    if strcmp(f.name,'deleteFigure')
        return
    end
end
