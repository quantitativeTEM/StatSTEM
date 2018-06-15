function focusNext(jObject,event)
% focusNext - Give next object focus
%
% syntax: focusNext(jObject,event,h)
%       jObject - Reference to java object
%       event   - structure recording button events
%       h       - structure holding references to GUI interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if event.getKeyCode==10
	jObject.nextFocus
end
