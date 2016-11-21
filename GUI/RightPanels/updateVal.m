function updateVal(jObject,event,ref)
% updateVal - Callback for requesting focus
%
%   syntax: updateVal(jObject,event,h)
%       jObject - Reference to java object
%       event   - structure recording button events
%       ref     - ref to field to give focus
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
if event.getKeyCode==10
    ref.requestFocus
end