function output = fitGauss_small(input,rho)
% fitGauss_small - program to fit gaussian peaks having to a STEM image
%
%   In this method, gaussian peak are fitted all at the same time to a STEM
%   image. One can select to fit with a different width for each atom, or
%   the same width for each atom type. 
%
%   syntax: output = fitGauss_small(input,FP)
%       input  - input structure
%       FP     - structure containing the fitting options
%       output - structure containing the output structure
%
% See also: fitGauss

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: A. De Backer, K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

%% Fit starting parameters
if nargin<2
    if input.rho_start==0
        input = averageDistance(input);
    end
    rho = input.rho_start(input.coordinates(:,3));
else
    if length(input.coordinates(:,1))~=length(rho)
        error('fitGauss_small: rho should be defined for every coordinate')
    end
end
if ~isempty(input.GUI)
    input.waitbar.setValue(0);
end

%% specifications fitting
TolX = 1e-4;                % tolerance on estimated parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% minimization using Matlab toolbox %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% using lsqnonlin; linear parameters as a function of nonlinear parameters
% paper: W.H. Lawton and E.A. Sylvestre - Elimination of Linear Parameters
% in Nonlinear Regression (Technometrics Vol.13, No.3, 1971)

options = optimset('lsqnonlin');
options.Jacobian = 'on';
options.DerivativeCheck = 'off';
if ~isempty(input.GUI) || input.silent
    options.Display = 'none';
else
    options.Display = 'iter';
end
options.Largescale = 'on';
options.Algorithm = 'trust-region-reflective';
options.TolX = TolX;
options.TolFun = eps;
options.MaxIter = input.maxIter;


% Correct image for background
if ~input.fitZeta
    resObs_bs = input.reshapeobs - input.zeta;
else
    resObs_bs = input.reshapeobs;
end

inOpt = {};
if ~isempty(input.GUI)
    if input.widthtype ==0 
        options.OutputFcn = @getIterDiff;
    else
        options.OutputFcn = @getIter;
    end
        
    inOpt = {input.waitbar,input.GUI};
end

if input.widthtype == 0
    % starting values for the non linear parameters in Å        % betaX, betaY, rho (position coordinates and width)
    StartParametersnonlin = [input.coordinates(:,1); input.coordinates(:,2);rho];
    EstimatedParametersnonlin = lsqnonlin('criterionGauss_diffrhoSmall',StartParametersnonlin',[],[],options,...
        input.Xreshape,input.Yreshape,input.n_c,input.K,input.L,resObs_bs,input.fitZeta,input.indMat,input.dx,inOpt{:});
    % Gather fit parameters
    coordinates = [EstimatedParametersnonlin(1:input.n_c)',EstimatedParametersnonlin(input.n_c+1:2*input.n_c)'];
    rho = EstimatedParametersnonlin(2*input.n_c+1:end)';
elseif input.widthtype == 1
    % starting values for the non linear parameters in Å        % betaX, betaY, rho (position coordinates and width)
    rhoT = zeros(max(input.coordinates(:,3)),1);
    if length(rho)~=max(input.coordinates(:,3))
        for i=1:max(input.coordinates(:,3))
            rhoT(i,1) = mean(rho);
        end
    else
        for i=1:max(input.coordinates(:,3))
            rhoT(i,1) = mean(rho(input.coordinates(:,3)==1));
        end
    end
    StartParametersnonlin = [input.coordinates(:,1); input.coordinates(:,2);rhoT];
    EstimatedParametersnonlin = lsqnonlin('criterionGauss_samerhoSmall',StartParametersnonlin',[],[],options,...
        input.Xreshape,input.Yreshape,input.n_c,input.K,input.L,resObs_bs,input.coordinates(:,3),input.fitZeta,input.indMat,input.dx,inOpt{:});
    % Gather fit parameters
    coordinates = [EstimatedParametersnonlin(1:input.n_c)',EstimatedParametersnonlin(input.n_c+1:2*input.n_c)'];
    rhoT = EstimatedParametersnonlin(2*input.n_c+1:end)';
    rho = rhoT(input.coordinates(:,3));
else
    % starting values for the non linear parameters in Å        % betaX, betaY, rho (position coordinates and width)
    rhoT = zeros(max(input.coordinates(:,3)),1);
    if length(rho)~=max(input.coordinates(:,3))
        for i=1:max(input.coordinates(:,3))
            rhoT(i,1) = mean(rho);
        end
    else
        for i=1:max(input.coordinates(:,3))
            rhoT(i,1) = mean(rho(input.coordinates(:,3)==1));
        end
    end
    StartParametersnonlin = [input.coordinates(:,1); input.coordinates(:,2)];
    EstimatedParametersnonlin = lsqnonlin('criterionGauss_samerhoSmall',StartParametersnonlin',[],[],options,...
        input.Xreshape,input.Yreshape,rhoT,input.n_c,input.K,input.L,resObs_bs,input.coordinates(:,3),input.fitZeta,input.indMat,input.dx,inOpt{:});
    % Gather fit parameters
    coordinates = [EstimatedParametersnonlin(1:input.n_c)',EstimatedParametersnonlin(input.n_c+1:2*input.n_c)'];
    rhoT = EstimatedParametersnonlin(2*input.n_c+1:end)';
    rho = rhoT(input.coordinates(:,3));
end

%% Create outputStatSTEM structure
output = getLinFitParam(input,rho,coordinates);
output = combinedGauss(output, input.K, input.L);
output.iter = 0;
temp = (output.model - input.obs).^2;
output.lsq = sum(temp(:));


function stop = getIter(x,optimValues,state,Xreshape,Yreshape,n_c,K,L,reshapeobs,type,fitzeta,indMat,dx,hwaitbar,GUI)
% This function updates a waitbar used in the GUI
if nargin>=14
    hwaitbar.setValue(optimValues.iteration/8);
end
if nargin==15
    % For abort button
    drawnow
    if get(GUI,'Userdata')==0
        error('Error: function stopped by user')
    end
end
stop = false;

function stop = getIterDiff(x,optimValues,state,Xreshape,Yreshape,n_c,K,L,reshapeobs,fitzeta,indMat,dx,hwaitbar,GUI)
% This function updates a waitbar used in the GUI
if nargin>=13
    hwaitbar.setValue(optimValues.iteration/8);
end
if nargin==14
    % For abort button
    drawnow
    if get(GUI,'Userdata')==0
        error('Error: function stopped by user')
    end
end
stop = false;