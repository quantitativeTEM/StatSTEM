function [indWorkers,indAllWorkers] = devideIndices(atomsToFit,numWorkers)
% devideIndices - devide the columns to be fitted
%
%   Define which column should be fitted by each core for parallel
%   computing
%
%   [indWorkers,indAllWorkers] = devideIndices(atomsToFit,numWorkers)
%       atomsToFit    - indices of columns that should be fitted
%       numWorkers    - number of cores (workers) for parallel computing
%       indWorkers    - cell containing indices for each worker
%       indAllWorkers - cell containing indices for each worker for all
%                       atoms
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Devide indices
n_c = length(atomsToFit);
ind = (1:n_c)';
ind = ind(atomsToFit==1);
n_fit = length(ind);
intVal = floor(n_fit/numWorkers)*ones(numWorkers,1);
extra = mod(n_fit,numWorkers);
intVal(1:extra,1) = intVal(1:extra,1)+1;
indWorkers = cell(numWorkers,1);
for n=1:numWorkers
    indWorkers{n,1} = ind(sum(intVal(1:n-1))+1:sum(intVal(1:n)),:);
end
if nargout==2
    if sum(atomsToFit)==n_c
        indAllWorkers = indWorkers;
    else
        intVal = floor(n_c/numWorkers)*ones(numWorkers,1);
        extra = mod(n_c,numWorkers);
        intVal(1:extra,1) = intVal(1:extra,1)+1;
        indAllWorkers = cell(numWorkers,1);
        for n=1:numWorkers
            indAllWorkers{n,1} = ind(sum(intVal(1:n-1))+1:sum(intVal(1:n)),:);
        end
    end
end