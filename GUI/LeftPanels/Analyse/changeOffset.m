function changeOffset(jObject,event,h)
% changeOffset - Set the offset in the atomcounting results
%
% Change the offset in the atomcounting results in the StatSTEM interface
%
%   syntax: changeOffset(jObject,event,h)
%       jObject - Reference to object
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

% First check if number is ok,
if event.getKeyCode==10
    h.left.ana.panel.atomAdv.offsetText.requestFocus
end
