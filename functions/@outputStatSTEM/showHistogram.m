function showHistogram(obj)
% showHistogram - Show a histogram of values in the StatSTEM interface
%
%   syntax: showHistogram(obj)
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

set(ax,'units','normalized','Position',[0.1300 0.1100 0.7750 0.8150])
if isempty(val)
    xlabel(ax,xtext)
    ylabel(ax,'Frequency')
    return
end
bins = ceil(min(length(val)/3,150));
hist(ax,val,bins);
xlabel(ax,xtext)
ylabel(ax,'Frequency')

% Make color gray
h = findobj(ax,'Type','patch');
set(h,'FaceColor',[0.7 0.7 0.7],'EdgeColor',[0 0 0])

if length(val)==1
    if val>0
        xlim(ax,[0 val*2])
    elseif val<0
        xlim(ax,[val*2,0])
    else
        xlim([-1,1])
    end
end

Ax_xlim = xlim(ax);
Ax_ylim = ylim(ax);

% Restore userdata
options = {'Limits',[Ax_xlim Ax_ylim];'histogram',h};
set(ax,'Userdata',options)