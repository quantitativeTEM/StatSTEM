function showMeanLatticeA_dirA(obj)
% showMeanLatticeA_dirA - Make graphs showing the mean lattice parameter a in the a-direction
%
% syntax: showMeanLatticeA_dirA(obj)
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

if isempty(obj.meanLatA_dirA)
    return
end

if ~isempty(obj.GUI)
    ax = obj.ax;
else
    ax = gca;
end

types = size(obj.meanLatA_dirA,2)/3;
hold on
for i=1:types
    indOK = ~isnan(obj.meanLatA_dirA(:,i*3-1));
    errorbar(ax,obj.meanLatA_dirA(indOK,i*3-2)*obj.a,obj.meanLatA_dirA(indOK,3*i-1),obj.meanLatA_dirA(indOK,3*i))
end
hold off
xlabel(['Distance from reference coordinate in a-direction(',char(197),')'])
ylabel(['Spacing (',char(197),')'])
names = obj.projUnit.atom2D';
legend(names{:})
