function cursorArrow(jObject,event,hf)
% cursorArrow - Give mouse cursor the arrow symbol
%
% Evaluate which figure is shown to insert to correct colorbar with label
%
%   syntax: insertColorbar(jObject,event,h)
%       jObject - Reference to object
%       event   - structure recording button events
%       hf      - Reference to figure of StatSTEM interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

set(hf,'Pointer','arrow','PointerShapeHotSpot',[1 1])