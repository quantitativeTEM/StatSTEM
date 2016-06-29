function atomcounting = getAtomCounts(atomcounting)
% getAtomCounts - Determine the number of atoms per column
%
%   Use the fitted Gaussian mixture model to determine the number of atoms
%   per columns (based on the scattering cross-sections).
%
%   syntax: atomcounting = getAtomCounts(atomcounting)
%       atomcounting - structure containing the atomcounting results
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

[atomcounting.estimatedLocations, index] = sort(atomcounting.estimatedDistributions{1,atomcounting.selMin}.mu);
atomcounting.estimatedWidth = sqrt(atomcounting.estimatedDistributions{1,atomcounting.selMin}.Sigma);
prop = atomcounting.estimatedDistributions{1,atomcounting.selMin}.PComponents;
atomcounting.estimatedProportions = prop(index);

% assign number of atoms to each atom column
probability = zeros(atomcounting.selMin,1);
atomcounting.Counts = zeros(atomcounting.N,1);
for i=1:atomcounting.N
    for j = 1:atomcounting.selMin
        probability(j) = atomcounting.estimatedProportions(j)*normaldistribution(atomcounting.volumes(i),atomcounting.estimatedLocations(j),atomcounting.estimatedWidth);
    end
    atomcounting.Counts(i) = find(probability == max(probability))+atomcounting.offset;
end
atomcounting.TotalNumberAtoms = sum(atomcounting.Counts);