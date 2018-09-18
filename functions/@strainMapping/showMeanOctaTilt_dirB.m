function showMeanOctaTilt_dirB(obj)
% showMeanOctaTilt_dirB - Make graphs showing the mean octahedral tilt in the b-direction
%
% syntax: showMeanOctaTilt_dirB(obj)
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

if isempty(obj.meanOctaTilt_dirB)
    return
end

if ~isempty(obj.GUI)
    ax = obj.ax;
else
    ax = gca;
end

hold on
indOK = ~isnan(obj.meanOctaTilt_dirB(:,3));
errorbar(ax,obj.meanOctaTilt_dirB(indOK,1)*obj.b,obj.meanOctaTilt_dirB(indOK,2),obj.meanOctaTilt_dirB(indOK,3))
% indOK = ~isnan(obj.meanOctaTilt_dirB(:,5));
% errorbar(ax,obj.meanOctaTilt_dirB(indOK,1)*obj.b,obj.meanOctaTilt_dirB(indOK,4),obj.meanOctaTilt_dirB(indOK,5))
% indOK = ~isnan(obj.meanOctaTilt_dirB(:,7));
% errorbar(ax,obj.meanOctaTilt_dirB(indOK,1)*obj.b,obj.meanOctaTilt_dirB(indOK,6),obj.meanOctaTilt_dirB(indOK,7))
hold off
xlabel(['Distance from reference coordinate in b-direction(',char(197),')'])
ylabel('Tilt (^o)')
