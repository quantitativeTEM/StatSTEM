function changeDX(jObject,event,h)
% changeDX - Callback for requesting focus
%
%   syntax: changeDX(jObject,event,h)
%       jObject - Reference to java object
%       event   - structure recording button events
%       h       - structure holding references to StatSTEM interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
if event.getKeyCode==10
    h.left.peak.panels.pixel.text.requestFocus
end