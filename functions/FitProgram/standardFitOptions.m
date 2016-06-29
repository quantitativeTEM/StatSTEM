function options = standardFitOptions()
% standardFitOptions - Generate the standard options for fitting
%
%   syntax: options = standardFitOptions()
%       options - structure containing the fitting options
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Fit also background
options.fitzeta = 1;

% Put background equal to 0 if background is not fitted
options.zeta = 0;

% Use same Gaussian width for different atomic columns (1 = 'same', 0 = 'different', 2 = 'user defined')
options.widthtype = 1;

% Fit Gaussian function to all selected peak positions
options.atomsToFit = 1;

% Will fit be a test
options.test = 0;

% Starting value width, can be zeros when fitting with the same of different width approach
options.rho_start = 0;

% Calculation will not be done in a computer cluster
options.cluster = 1;

% Maximum number of iterations
options.maxIter = 400;

% Indicate that GUI is used
options.GUI = 1;

% Number of workers for parallel computing
v = version('-release'); % Check version of MATLAB
v = str2double(v(1:4));
if v<2015 || license('test','distrib_computing_toolbox')==0
    options.numWorkers = 1;
else
    options.numWorkers = feature('numCores');
end