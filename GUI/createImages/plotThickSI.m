function plotThickSI(ax,val,offset)
% plotThickSI - Show a plot of the scattered intensities vs thickness
%
%   syntax: plotThickSI(ax,val,offset)
%       ax     - handle to axes
%       val    - the values to be shown
%       offset - offset of the atom counts 
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

set(ax,'units','normalized','Position',[0.1300 0.1100 0.7750 0.8150])
plot(ax,(1:length(val))+offset,val,'r*', 'MarkerSize', 10)
xlabel(ax,'Component number')
ylabel(ax,['Mean scattering cross-section (e^-',char(197),'^2)'])
xlim(ax,[0,length(val)+offset])
ylim(ax,[0,max(val)])

% Restore userdata
usr = {'Limits',[0 length(val)+offset 0 max(val)]};
set(ax,'Userdata',usr)