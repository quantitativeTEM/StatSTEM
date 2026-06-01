function newMessage(message, h)
% newMessage - Update the message shown in the StatSTEM interface
%
% syntax: newMessage(message,h)
%   message - message (string)
%   h       - structure holding references to GUI interface
%
%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
% Get current messages and append new one
current = get(h.right.message.text, 'String');
if ischar(current)
    current = {current};
end
current{end+1} = message;
set(h.right.message.text, 'String', current);
pause(0.2)
scrollDown(h)