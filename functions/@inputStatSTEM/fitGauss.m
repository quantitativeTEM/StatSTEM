function output = fitGauss(input)
% fitGauss - program to fit gaussian peaks to a STEM image
%
%   Main program to select fitting procedure to fit a model of Gaussian
%   peaks to a STEM image. Each peak is describing the scattered image 
%   intensity of a projected column.
%
%   syntax: output  = fitGauss(input)
%       input  - inputStatSTEM file
%       output - structure containing the output structure
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: A. De Backer, K.H.W van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

%% Check if input coordinates are given within image boundaries
if input.rho_start==0
    input = averageDistance(input);
end
sImg = size(input.obs)*input.dx;
sRho = max(input.rho_start)*3;
if any(input.coordinates(:,1)<(-sRho+input.dx)) || any(input.coordinates(:,2)<(-sRho+input.dx)) || ...
        any(input.coordinates(:,1)>(sImg(2)+sRho)) || any(input.coordinates(:,2)>(sImg(1)+sRho))
    error('fitGauss: Input coordinates are outside the boundaries of the image')
end

%% Fitting procedure
if sum(input.atomsToFit)==input.n_c
    newP = input.Sval<input.n_c;
else
    newP = 1;
end
% Select different method
if newP
    % Start parallel toolbox if necessary
    if input.numWorkers ~= 1
        if isempty(gcp('nocreate'))
            parpool(input.numWorkers);
            input = devideIndices(input);
        end
    end
    
    % Find a good starting value for rho, if necessary
    if input.findRho==1
        % Fit to get a starting value of the width
        output = fitWidth(input,10^-2,Inf,0,25);
        offset = 25; % For progress bar
        rho = output.rho;
    else
        rho = input.rho_start(input.coordinates(:,3));
        offset = 0;
    end
    
    % Select the fitting options in terms of different or same width of the Gaussian functions
    if input.widthtype == 0
        % Fit different height and width of gaussians for each column
        output = fitGauss_diffrho(input, rho, offset);
    else
        if input.fitRho && input.test==0
            maxwait = 75;
        else
            maxwait = 100;
        end
        % Fit height of gaussians with same width for each column
        output = fitGauss_samerho(input, rho, offset, maxwait);
        
        % Find width if needed
        if input.fitRho==1 && input.test==0
            input.coordinates(:,1:2) = output.coordinates(:,1:2);
            
            % Fit width of gaussians with same width for each column
            types = max(input.coordinates(:,3));
            rhoT = zeros(types,1);
            for i = 1:types
                rho_temp = rho(input.coordinates(:,3) == i);
                rhoT(i)= median(rho_temp);
            end
            input.rhoT = rhoT;
            output = fitWidth(input, 10^-4, Inf, 75);
        end
    end
else
    output = fitGauss_small(input);
end

% Update waitbart if needed
if ~isempty(input.GUI)
    input.waitbar.setValue(100)
end

% Update message
output.message = 'Gaussian model successfully fitted';