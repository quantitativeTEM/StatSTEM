function obj = measureLatPar(obj)
% measureLatPar - measure the lattice parameters
%
% First run makeDisplacementMap to get indices
%
% syntax: obj = measureLatPar(obj)
%    obj - strainMapping file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Check if all coordinates are identified
ind = obj.typesN(:,1)~=0; % Check if all coordinates are identified

% Find neighbours and measure lattice parameters
N = length(obj.typesN(:,1));
latticeA = zeros(N,2);
latticeB = zeros(N,2);
for i=1:N
    if ind(i,1)
        indS = obj.indices(i,1:2);
        typS = obj.typesN(i,1);
        
        % Search in a-direction
        indInt = obj.indices(:,1)==(indS(1)+1) & obj.indices(:,2)==indS(2) & obj.typesN==typS;
        if sum(indInt)==1
            latticeA(i,:) = obj.coordinates(indInt,1:2)-obj.coordinates(i,1:2);
        end
        % Search in b-direction
        indInt = obj.indices(:,1)==indS(1) & obj.indices(:,2)==(indS(2)+1) & obj.typesN==typS;
        if sum(indInt)==1
            latticeB(i,:) = obj.coordinates(indInt,1:2)-obj.coordinates(i,1:2);
        end
    end
end

% Store in file (private variable)
obj.latticeAP = latticeA;
obj.latticeBP = latticeB;
