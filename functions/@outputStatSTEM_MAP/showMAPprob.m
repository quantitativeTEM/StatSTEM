function showMAPprob(obj)
% showMAPprob - Show the Maximum A Posteriori probability
%
%   syntax: showMAPprob(obj)
%       obj - outputStatSTEM_MAP file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos, J. Fatermans
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if nargin<1
    return
end

if ~isempty(obj.GUI)
    ax = obj.ax;
else
    ax = gca;
end

pos = [0.1300 0.1100 0.7750 0.8150];
set(ax,'units','normalized','Position',pos)
hold off
plot(ax,obj.N,obj.MAPprob,'.', 'MarkerSize', 20, 'Color', [0 0 0])
xlabel('Number of columns')
ylabel('Relative probability (logscale)')
