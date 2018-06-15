function showMeanLatticeA_dirB(obj)
% showMeanLatticeA_dirB - Make graphs showing the mean lattice parameter a in the a-direction
%
% syntax: showMeanLatticeA_dirB(obj)
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

if isempty(obj.meanLatA_dirB)
    return
end

if ~isempty(obj.GUI)
    ax = obj.ax;
else
    ax = gca;
end

types = size(obj.meanLatA_dirB,2)/3;
hold on
for i=1:types
    indOK = ~isnan(obj.meanLatA_dirB(:,i*3-1));
    errorbar(ax,obj.meanLatA_dirB(indOK,i*3-2)*obj.a,obj.meanLatA_dirB(indOK,3*i-1),obj.meanLatA_dirB(indOK,3*i))
end
hold off
xlabel(['Distance from reference coordinate in b-direction(',char(197),')'])
ylabel(['Spacing (',char(197),')'])
names = obj.projUnit.atom2D';
legend(names{:})
