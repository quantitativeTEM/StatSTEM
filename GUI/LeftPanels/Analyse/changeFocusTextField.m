function changeFocusTextField(jObject,event,newField)
% changeFocusTextField - Set the offset in the atomcounting results
%
% Change the offset in the atomcounting results in the StatSTEM interface
%
%   syntax: changeFocusTextField(jObject,event,newField)
%       jObject  - Reference to object
%       event    - structure recording button events
%       newField - reference to object that should get focus
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
    newField.requestFocus
end
