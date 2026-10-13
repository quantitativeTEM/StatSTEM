function updateVal(hObject, event, ref)
% updateVal - Callback for moving focus on Enter key press
%
%   syntax: updateVal(hObject, event, ref)
%       hObject - uicontrol handle that triggered the KeyReleaseFcn
%       event   - KeyReleaseFcn event data (contains .Key)
%       ref     - uicontrol to give focus to next
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if strcmp(event.Key, 'return')
    uicontrol(ref);
end
