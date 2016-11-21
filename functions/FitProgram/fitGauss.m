function [output,abort]  = fitGauss(input, FP)
% fitGauss - program to fit gaussian peaks to a STEM image
%
%   Main program to select fitting procedure to fit a model of Gaussian
%   peaks to a STEM image. Each peak is describing the scattered image 
%   intensity of a projected column.
%
%   syntax: [output,abort]  = fitGauss(input, FP)
%       input  - input structure
%       FP     - structure containing the fitting options
%       output - structure containing the output structure
%       abort  - number indicating if fitting procedure is cancelled
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

abort = 0;

%% Fitting options
FP = prepOpt(input,FP);
% Check if input coordinates are given within image boundaries
sImg = size(input.obs)*input.dx;
sRho = max(FP.rho)*3;
if any(input.coordinates(:,1)<(-sRho+input.dx)) || any(input.coordinates(:,2)<(-sRho+input.dx)) || ...
        any(input.coordinates(:,1)>(sImg(2)+sRho)) || any(input.coordinates(:,2)>(sImg(1)+sRho))
    error('Input coordinates are outside the boundaries of the image')
end

%% Fitting procedure
% Select different method
if FP.newP
%     FP.patch = 1;
    % Find a good starting value for rho, if necessary
    if FP.findRho==1
        % Fit to get a starting value of the width
        types = max(input.coordinates(:,3));
        FP.rho_start = zeros(types,1);
        for i = 1:types
            rho_temp = FP.rho(input.coordinates(:,3) == i);
            FP.rho_start(i)= median(rho_temp);
        end
%         FP.rho_start = [0.529614257812499;0.648541259765625;0.5];
        [output,abort] = fitRho(input, FP,0,10^-2,Inf);
        offset = 25; % For progress bar
        if abort
            return
        end
        FP.rho = output.rho;
    else
        offset = 0;
    end
    
	% Select the fitting options in terms of different or same width of the Gaussian functions
	if FP.widthtype == 0
		% Fit different height and width of gaussians for each column
		[output,abort] = fitGauss_diffrho(input, FP, offset);
	else
		% Fit height of gaussians with same width for each column
		[output,abort] = fitGauss_samerho(input, FP, offset);
		if ~abort
			coor = input.coordinates(:,1:2);
			input.coordinates(:,1:2) = output.coordinates(:,1:2);
			if FP.fitRho==1
				% Fit width of gaussians with same width for each column
				types = max(input.coordinates(:,3));
				FP.rho_start = zeros(types,1);
				for i = 1:types
					rho_temp = output.rho(input.coordinates(:,3) == i);
					FP.rho_start(i)= median(rho_temp);
				end
				[output,abort] = fitRho(input, FP, 75);
			end
			input.coordinates(:,1:2) = coor;
		end
	end
else
    [output,abort] = fitGauss_small(input,FP);
end

% Calculate final output structure containing all results
if ~abort
    [output,abort] = getFitParam(output,input,FP);
end
if FP.GUI
    FP.waitbar.setValue(100)
end