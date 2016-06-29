function showICL(ax,val)
% showICL - Show the ICL in the StatSTEM interface
%
%   syntax: showICL(ax,val)
%       ax  - handle to axes
%       val - the values to be shown
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

set(ax,'units','normalized','Position',[0.1300 0.1100 0.7750 0.8150])
plot(ax,1:length(val),val,'.', 'MarkerSize', 20, 'Color', [0 0 0])
xlabel(ax,'Number of Gaussian components')
ylabel(ax,'ICL')

% Restore userdata
Ax_xlim = xlim(ax);
Ax_ylim = ylim(ax);
usr = {'Limits',[Ax_xlim Ax_ylim]};
set(ax,'Userdata',usr)