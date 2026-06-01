function scrollDown(h)
% scrollDown - Scroll message panel to latest message
%
% syntax: scrollDown(h)
%   h - structure holding references to GUI interface
%
%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
n = numel(get(h.right.message.text, 'String'));
if n > 0
    set(h.right.message.text, 'Value', n);
end