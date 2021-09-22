function output = fitGauss_diffrho(input, rho, offset, maxwait)
% fitGauss_diffrho - program to fit gaussian peaks having a different width
%                    to a STEM image
%
%   In this method, each individual peak is cut out of the original image.
%   Next, the image contrubutions of the neighbouring atoms are subtracted.
%   Than, a gaussian peak is fitted (coordinates and width). The width of
%   the gaussian peak differs for each column.
%
%   syntax: output = fitGauss_diffrho(input, rho, offset, maxwait)
%       input   - inputStatSTEM structure
%       rho     - vector containing Gaussian width for each column position
%       offset  - offset value for progressbar (optional)
%       maxwait - maximum value for progressbar (optional)
%       output  - outputStatSTEM structure containing the results
%
% See also: inputStatSTEM, outputStatSTEM, fitGauss

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: A. De Backer, K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if nargin<4
    maxwait = 100;
end
if nargin<3
    % For progressbar GUI
    offset = 0;
end

%% Start parallel toolbox if necessary
if input.numWorkers ~= 1
    if isempty(gcp('nocreate'))
        parpool(input.numWorkers);
    end
end
input = devideIndices(input);
input = averageDistance(input);

%% specifications fitting
radius = input.dist*2.5;           % radius around position of a single atom column taking into account the contributions of neighbouring gaussians
TolX = 1e-4;                    % tolerance on estimated parameters
alfa = 0.5;                     % parameter to define change in parameters every iteration

%% define matrices
Estimated_BetaX = input.coordinates(:,1);
Estimated_BetaY = input.coordinates(:,2);
Estimated_rho = rho;

betaX_estimatedbackground = input.coordinates(:,1);
betaY_estimatedbackground = input.coordinates(:,2);
rho_estimatedbackground = rho;
type = input.coordinates(:,3);

X = input.X;
Y = input.Y;

%% Recalculate size of boxes used to cut out parts of the original image
% size/2 of the box selected around the position of an atom column position in pixels 
Box = round(input.dist/input.dx/2)*ones(max(type),1); %calcBoxSize(input.obs,input.coordinates,input.dx);

%% startmodel
output = getLinFitParam(input,rho_estimatedbackground,[Estimated_BetaX,Estimated_BetaY]);
obs_bs = input.obs - output.zeta;
Estimated_eta = output.eta;
eta_estimatedbackground = output.eta;

%% options for lsqnonlin
options = optimset('lsqnonlin');
options.Jacobian = 'on';
options.DerivativeCheck = 'off';
options.Display = 'off';
options.Largescale = 'on';
options.Algorithm = 'trust-region-reflective';
options.TolX = 1e-4;
options.TolFun = eps;

%% Start iterations
if isempty(input.GUI) && input.cluster==0 && input.silent==0
    h = waitbar(0,'','Name','Iterating...');
end
colConv = 0;
progress = 0;
r = maxwait-offset;
for iter = 1:input.maxIter % maximum number of iterations for convergence
    % Report current estimate in the waitbar's message field
    progress = max(progress,(iter-1)/input.maxIter);
    if ~isempty(input.GUI)
        input.waitbar.setValue(offset + progress*r)
    else
        if input.silent==0
            formatSpec = 'Step %d, progress %d%%';
            if input.cluster
                fprintf([formatSpec,' \n'],iter,round(progress*99))
            else
                waitbar((progress*99)/100,h, sprintf(formatSpec,iter,round(progress*99)))
            end
        end
    end
    
    % Save old values, use alfa to ensure convergence
    Estimated_rho_old = Estimated_rho;
    Estimated_BetaX_old = Estimated_BetaX;
    Estimated_BetaY_old = Estimated_BetaY;
    rho_estimatedbackground = rho_estimatedbackground + (Estimated_rho - rho_estimatedbackground)*alfa;
    betaX_estimatedbackground = betaX_estimatedbackground + (Estimated_BetaX - betaX_estimatedbackground)*alfa;
    betaY_estimatedbackground = betaY_estimatedbackground + (Estimated_BetaY - betaY_estimatedbackground)*alfa;
    eta_estimatedbackground = eta_estimatedbackground + (Estimated_eta - eta_estimatedbackground)*alfa;
    
    % Fit new column positions
    if input.numWorkers == 1
        if ~isempty(input.GUI)
            % For aborting function
            drawnow
            if get(input.GUI,'Userdata')==0
                error('Error: function stopped by user')
            end
        end
        EstimatedParametersnonlin = fitAtomNonLinear('diff',input.coordinates,obs_bs,X,Y,Box,betaX_estimatedbackground,betaY_estimatedbackground,rho_estimatedbackground,eta_estimatedbackground,input.dx,radius,options,input.indWorkers{1,1});
        Estimated_BetaX(input.indWorkers{1,1}) = EstimatedParametersnonlin(1,:);
        Estimated_BetaY(input.indWorkers{1,1}) = EstimatedParametersnonlin(2,:);
        Estimated_rho(input.indWorkers{1,1}) = EstimatedParametersnonlin(3,:);
    else
        job = cell(input.numWorkers,1);
        for i = 1:input.numWorkers   % number of workers that will be used
            job{i} = parfeval(@fitAtomNonLinear,1,'diff',input.coordinates,obs_bs,X,Y,Box,betaX_estimatedbackground,betaY_estimatedbackground,rho_estimatedbackground,eta_estimatedbackground,input.dx,radius,options,input.indWorkers{i,1});
        end
        for i = 1:input.numWorkers
            if ~isempty(input.GUI)
                % For aborting function
                drawnow
                if get(input.GUI,'Userdata')==0
                    error('Error: function stopped by user')
                end
            end
            EstimatedParametersnonlin = fetchOutputs(job{i});
            Estimated_BetaX(input.indWorkers{i,1}) = EstimatedParametersnonlin(1,:);
            Estimated_BetaY(input.indWorkers{i,1}) = EstimatedParametersnonlin(2,:);
            Estimated_rho(input.indWorkers{i,1}) = EstimatedParametersnonlin(3,:);
        end
        clear job
    end
    
    % Get linear parameters
    output = getLinFitParam(input,Estimated_rho,[Estimated_BetaX,Estimated_BetaY]);
    
    if input.fitZeta
        obs_bs = input.obs - output.zeta;
    end
    Estimated_eta = output.eta;
    
    % check convergence
    diff_BetaX = sqrt((Estimated_BetaX_old - Estimated_BetaX).^2)./input.dx;
    diff_BetaY = sqrt((Estimated_BetaY_old - Estimated_BetaY).^2)./input.dx;
    diff_rho   = sqrt((Estimated_rho_old - Estimated_rho).^2)./input.dx;
    test_BetaX_diff = max( diff_BetaX );
    test_BetaY_diff = max( diff_BetaY );
    test_rho_diff   = max( diff_rho );
    if max([test_BetaX_diff,test_BetaY_diff,test_rho_diff]) < TolX
        break;
    end
    
    % Check which values columns already converged
    ind = diff_BetaX < TolX & diff_BetaY < TolX & diff_rho < TolX;
    if sum(ind)<=colConv
        alfa = 0.25;
    else
        alfa = 0.5;
    end
    colConv = sum(ind);
    progress = max(progress,colConv/length(ind));
    
%     fprintf(['Number of columns fitted: ',num2str(sum(ind)),'/',num2str(length(ind)),'\n'])
%     [~,indColumn1] = max(diff_BetaX);
%     [~,indColumn2] = min(diff_BetaX);
%     fprintf(['Minimum Col: ',num2str(indColumn1),' X : ',num2str(diff_BetaX(indColumn1)),', Y: ',num2str(diff_BetaY(indColumn1)),', rho: ',num2str(diff_rho(indColumn1)),'. Minimum Col: ',num2str(indColumn2),' X: ',num2str(diff_BetaX(indColumn2)),' and Y: ',num2str(diff_BetaY(indColumn2)),', rho: ',num2str(diff_rho(indColumn2)),'\n'])
end
if isempty(input.GUI) && input.cluster==0
    close(h)
end

%% Store found results (output structure is already generated in loop)
output.iter = iter;
output = combinedGauss(output, input.K, input.L);
temp = (output.model - input.obs).^2;
output.lsq = sum(temp(:));
