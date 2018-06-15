function obj = devideIndices(obj)
% devideIndices - devide the columns to be fitted
%
%   Define which column should be fitted by each core for parallel
%   computing. In inputStatSTEM file two properties are defined:
%       indWorkers    - cell containing indices for each worker
%       indAllWorkers - cell containing indices for each worker for all
%       
%
%   obj = devideIndices(obj)
%       obj - file of class inputStatSTEM
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Devide indices
ind = (1:obj.n_c)';
ind = ind(obj.atomsToFit==1);
n_fit = length(ind);
intVal = floor(n_fit/obj.numWorkers)*ones(obj.numWorkers,1);
extra = mod(n_fit,obj.numWorkers);
intVal(1:extra,1) = intVal(1:extra,1)+1;
indWorkers = cell(obj.numWorkers,1);
for n=1:obj.numWorkers
    indWorkers{n,1} = ind(sum(intVal(1:n-1))+1:sum(intVal(1:n)),:);
end

if sum(obj.atomsToFit)==obj.n_c
    indAllWorkers = indWorkers;
else
    intVal = floor(obj.n_c/obj.numWorkers)*ones(obj.numWorkers,1);
    extra = mod(obj.n_c,obj.numWorkers);
    intVal(1:extra,1) = intVal(1:extra,1)+1;
    indAllWorkers = cell(obj.numWorkers,1);
    for n=1:obj.numWorkers
        indAllWorkers{n,1} = ind(sum(intVal(1:n-1))+1:sum(intVal(1:n)),:);
    end
end

obj.indWorkers = indWorkers;
obj.indAllWorkers = indAllWorkers;