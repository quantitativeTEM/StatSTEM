function imageChanged(hObject,event,tab,h)
% imageChanged - Show new image
%
% Show a new image in the StatSTEM interface
%
%   syntax: imageChanged(hObject,event,tab,h)
%       hObject - Reference to button
%       event   - structure recording button events
%       tab     - the selected tab
%       h       - structure holding references to the StatSTEM interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Show new figure
showImage(tab,h)