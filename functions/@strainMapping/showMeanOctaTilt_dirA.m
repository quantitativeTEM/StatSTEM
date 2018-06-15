function showMeanOctaTilt_dirA(obj)
% showMeanOctaTilt_dirA - Make graphs showing the mean octahedral tilt in the a-direction
%
% syntax: showMeanOctaTilt_dirA(obj)
%   obj - strainMapping file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if isempty(obj.meanOctaTilt_dirA)
    return
end

if ~isempty(obj.GUI)
    ax = obj.ax;
else
    ax = gca;
end

hold on
indOK = ~isnan(obj.meanOctaTilt_dirA(:,3));
errorbar(ax,obj.meanOctaTilt_dirA(indOK,1)*obj.a,obj.meanOctaTilt_dirA(indOK,2),obj.meanOctaTilt_dirA(indOK,3))
hold off
xlabel(['Distance from reference coordinate in a-direction(',char(197),')'])
ylabel('Tilt (^o)')
