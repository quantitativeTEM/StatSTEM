function reqFocus(hObject, ~, h)
% reqFocus - Give focus back to the figure when a busy callback is interrupted
%
%   syntax: reqFocus(hObject, event, h)
%       hObject - uicontrol that was clicked during a busy callback
%       event   - callback event data (unused)
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

turnOffFigureSelection(h);

% Interrupt the running callback by re-raising the figure
% (replaces java.awt.Robot VK_ESCAPE key press)
figure(h.fig);

% Clear any temporary callbacks that were set during the busy state
set(hObject, 'ButtonDownFcn', []);
