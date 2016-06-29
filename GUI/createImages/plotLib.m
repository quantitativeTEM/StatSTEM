function plotLib(ax,val,nameTag)
% plotLib - Show a plot of the library values of the scattered intensities vs thickness
%
%   syntax: plotLib(ax,val)
%       ax      - handle to graph
%       val     - the values to be shown
%       nameTag - name of the plot
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if isempty(val)
    return
end
hold(ax,'on')
h = plot(ax,val(:,1),val(:,2),'.', 'MarkerSize', 20, 'Color', [0 0 0]);
hold(ax,'off')

% Store reference to histogram
data = get(ax,'Userdata');
set(ax,'Userdata',[data;{nameTag h}])

legend(ax,'Experiment','Library','Location','northwest')