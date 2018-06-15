function showHistogramSCS(obj)
% showHistogramSCS - Show a histogram of scattering cross-sections in the StatSTEM interface
%
%   syntax: showHistogramSCS(obj)
%       obj - outputStatSTEM file
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

val = obj.selVol;
bins = getNBins(val);
hist(val,bins);
xlabel('Scattering cross-section (e^-Å^2)')
ylabel('Frequency')

% Make color gray
h = findobj(ax,'Type','patch');
set(h,'FaceColor',[0.7 0.7 0.7],'EdgeColor',[0 0 0])

if length(val)==1
    if val>0
        xlim(ax,[0 val*2])
    elseif val<0
        xlim(ax,[-val*2,0])
    else
        xlim([-1,1])
    end
end