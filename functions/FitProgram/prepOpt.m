function FP = prepOpt(input,FP)
% prepOpt - load or define all standard fitting options
%
%   syntax: FP = prepOpt(input,FP)
%       FP    - structure containing all fitting options
%       input - input structure for fitting
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

options = fieldnames(FP);
% Make sure atom type is given
if size(input.coordinates,2)==2
    input.coordinates(:,3) = 1;
end

FP.n_c = size(input.coordinates,1);         % number of atom columns

% Load select atomstofit
if length(FP.atomsToFit) ~= FP.n_c
    FP.atomsToFit = ones(FP.n_c,1);
end

% Calculate indMat to select parts in image
FP.indMat = reshape((1:FP.K*FP.L)',FP.L,FP.K);

% If no maximum number of iterations is defined, set value to 400
if ~any(strcmp(options,'maxIter'))
    FP.maxIter = 400;
end

% If no selection is made whether rho should be fitted, fit rho
if ~any(strcmp(options,'fitRho'))
    FP.fitRho = 1;
end

% Standard no GUI is used
if ~any(strcmp(options,'GUI'))
    FP.GUI = 0;
end
if FP.GUI==0
    FP.waitbar = 0;
else
    FP.waitbar.setValue(0)
end

% Put initial value for zeta to 0 if zeta if fitted
if FP.fitzeta
    FP.zeta = 0;
end

% Determine switch values to switch from old program fitting everything at
% the same time to the new program were individual columns are fitted
Sval = 100;

% The test conditions
if ~any(strcmp(options,'test'))
    FP.test = 0;
end
if FP.test
    FP.fitRho = 0;
    FP.maxIter = 4;
end

% If image is partially fitted, always use new program. Otherwise select
% based on speed of algortihm
if sum(FP.atomsToFit)==FP.n_c
    FP.newP = Sval<FP.n_c;
else
    FP.newP = 1;
end

% If image is large the user may want to fit rho first 
if ~any(strcmp(options,'fitRhoFirst'))
    FP.fitRhoFirst = 0;
end

% If not specified, fit column per column instead of using patches
if ~any(strcmp(options,'patch'))
    FP.patch = 0;
end

%% Determine number of workers for parallel computing and determine indices
if ~any(strcmp(options,'numWorkers'))
    FP.numWorkers = min(FP.n_c,4);
end
if FP.newP==0
    FP.numWorkers = 1;
end

if FP.numWorkers ~= 1
    if isempty(gcp('nocreate'))
        parpool(FP.numWorkers);
    end
end
[FP.indWorkers,FP.indAllWorkers] = devideIndices(FP.atomsToFit,FP.numWorkers);


%% Calculate average distance between coordinates to get first estimate for rho
if size(input.coordinates,1) > 1  %% number of columns to analyse > 1
    FP.dist = averageDistance(input.coordinates,FP);
else    %% only 1 column to analyse
    FP.dist = min(size(input.obs))*input.dx;
end

% Get starting value for the width, rho, of the atomic columns
FP.rho = FP.dist/4*ones(FP.n_c,1);
FP.findRho = 1;
if any(strcmp(fieldnames(input),'rho'))
    if ~any(input.rho==0)
        if size(input.rho,1)==size(input.coordinates,1)
            % Use user defined width, don't find width by fitting
            FP.rho = input.rho;
            FP.findRho = 0;
            FP.fitRho = 0;
        end
    end
end

%% Hide progress from command window
if ~any(strcmp(options,'silent'))
    FP.silent = 0;
end
