function newMessage(message,h)
% newMessage - Update the message shown in the StatSTEM interface
%
%   syntax: newMessage(message,h)
%       message - message (string)
%       h       - structure holding references to GUI interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
% Get old message
oldMessage = h.right.message.text.getText;
newMessage = java.lang.String(sprintf(['\n',message])); %Convert to java

% Display new message
str = concat(oldMessage,newMessage);
h.right.message.text.setText(str)
pause(0.2)
scrollDown(h)