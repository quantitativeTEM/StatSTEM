function obj = selICLmin(obj)
% selICLmin - Select an ICL minimum for atomcounting
%
%   syntax: obj = selICLmin(obj)
%       obj - atomCountStat file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

%% Select axis
ax = gca;
axis(ax);
hold on;

% Select new minimum
title('Select the minimum of interest in the ICL')
[x,~] = ginput_AxInFig();
title(ax,'')
selMin = round(x);
if selMin<1
    selMin = 1;
elseif selMin>length(obj.ICL)
    selMin = length(obj.ICL);
end
obj.selMin = selMin;

% Calculate single atom sensitivity, and store in file as a message
out = singleatomsensivity(obj,1);
obj.message = ['New ICL minimum selected: ',num2str(selMin),'\nAtoms counted with single atom sensitivity of ',num2str(out*100),'%%'];