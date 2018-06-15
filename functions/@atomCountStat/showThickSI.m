function showThickSI(obj)
% showThickSI - Show a plot of the scattered intensities vs thickness
%
%   syntax: showThickSI(obj)
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


if ~isempty(obj.GUI)
    ax = obj.ax;
else
    ax = gca;
end
val = obj.estimatedLocations;
plot(ax,(1:length(val))+obj.offset,val,'r*', 'MarkerSize', 10)
xlabel(ax,'Component number')
ylabel(ax,['Mean scattering cross-section (e^-',char(197),'^2)'])
xlim(ax,[0,length(val)+obj.offset])
ylim(ax,[0,max(val)])