function focusNext(hObject, event)
% focusNext - Move keyboard focus to the next control when Enter is pressed
%
%   syntax: focusNext(hObject, event)
%       hObject - uicontrol editfield handle
%       event   - KeyReleaseFcn event data (contains .Key)
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% event.Key is 'return' when the Enter key is released
if strcmp(event.Key, 'return')
    % Move focus away from the editfield; this also triggers its Callback
    uicontrol(hObject);   % ensure we have focus first
    % Tab to next control by temporarily shifting focus to the parent figure
    fig = ancestor(hObject, 'figure');
    if ~isempty(fig)
        figure(fig);
    end
end
