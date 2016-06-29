function [output,abort] = fitGauss_small(input,FP)
% fitGauss_small - program to fit gaussian peaks having to a STEM image
%
%   In this method, gaussian peak are fitted all at the same time to a STEM
%   image. One can select to fit with a different width for each atom, or
%   the same width for each atom type. 
%
%   syntax: [output,abort] = fitGauss_small(input,FP)
%       input  - input structure
%       FP     - structure containing the fitting options
%       output - structure containing the output structure
%       abort  - number indicating if fitting procedure is cancelled
%
% See also: fitGauss

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

%% specifications fitting
TolX = 1e-4;                % tolerance on estimated parameters
abort = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% minimization using Matlab toolbox %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% using lsqnonlin; linear parameters as a function of nonlinear parameters
% paper: W.H. Lawton and E.A. Sylvestre - Elimination of Linear Parameters
% in Nonlinear Regression (Technometrics Vol.13, No.3, 1971)

options = optimset('lsqnonlin');
options.Jacobian = 'on';
options.DerivativeCheck = 'off';
if FP.GUI==1 || FP.silent
    options.Display = 'none';
else
    options.Display = 'iter';
end
options.Largescale = 'on';
options.Algorithm = 'trust-region-reflective';
options.TolX = TolX;
options.TolFun = eps;
options.MaxIter = FP.maxIter;

% Refine size of box per atom type, start from original
if size(input.coordinates,2)==2
    input.coordinates(:,3) = ones(size(input.coordinates,1),1);
end

% Correct image for background
if ~FP.fitzeta
    FP.resObs_bs = FP.reshapeobs - FP.zeta;
else
    FP.resObs_bs = FP.reshapeobs;
end

tic
if FP.GUI
    EstimatedParametersnonlin = fitAtomNonLinear(FP.widthtype,FP.rho,input.coordinates,options,FP.Xreshape,FP.Yreshape,FP.n_c,FP.K,FP.L,FP.resObs_bs,FP.fitzeta,FP.indMat,input.dx,FP.waitbar,FP.abortButton);
else
    EstimatedParametersnonlin = fitAtomNonLinear(FP.widthtype,FP.rho,input.coordinates,options,FP.Xreshape,FP.Yreshape,FP.n_c,FP.K,FP.L,FP.resObs_bs,FP.fitzeta,FP.indMat,input.dx);
end
if FP.GUI
    if ~FP.abortButton.isEnabled
        abort = 1;
        output = 0;
        return
    end
end

%% Results
output = struct;

% Get estimated nonlinear parameters
output.coordinates = [EstimatedParametersnonlin(1:FP.n_c)',EstimatedParametersnonlin(FP.n_c+1:2*FP.n_c)'];
rho(:,1) = EstimatedParametersnonlin(2*FP.n_c+1:end);
output.rho = rho(input.coordinates(:,3));
% Get linear parameters
switch FP.fitzeta
    case 0
        Ga = sparse(FP.K*FP.L,FP.n_c);
        for i = 1:FP.n_c
            R = sqrt((FP.Xreshape - output.coordinates(i,1)).^2 + (FP.Yreshape - output.coordinates(i,2)).^2);
            Ga(:,i) = gaus( R , output.rho(i) );
        end
        GaT = Ga';
        GaTGa = GaT*Ga;
        GaTobs = GaT*FP.resObs_bs;
        EstimatedParameterslin = GaTGa\GaTobs;
        output.eta = EstimatedParameterslin;
        output.zeta = FP.zeta;
        output.model = sum(Ga*diag(EstimatedParameterslin),2)+output.zeta;
    otherwise
        Ga = sparse(FP.K*FP.L,FP.n_c+1);
        for i = 1:FP.n_c
            R = sqrt((FP.Xreshape - output.coordinates(i,1)).^2 + (FP.Yreshape - output.coordinates(i,2)).^2);
            Ga(:,i) = gaus( R , output.rho(i) );
        end
        Ga(:,end) = ones(FP.K*FP.L,1);
        GaT = Ga';
        GaTGa = GaT*Ga;
        GaTobs = GaT*FP.resObs_bs;
        EstimatedParameterslin = GaTGa\GaTobs;
        output.eta = EstimatedParameterslin(1:end-1);
        output.zeta = EstimatedParameterslin(end);
        output.model = sum(Ga*diag(EstimatedParameterslin),2);
end
output.model = reshape(output.model,FP.L,FP.K);
output.volumes = 2*pi*output.eta.*output.rho.^2;
output.iter = 1;
temp = (output.model - input.obs).^2;
output.lsq = sum(temp(:));


function EstimatedParametersnonlin = fitAtomNonLinear(widthtype,rho_start,coordinates,options,X,Y,n_c,K,L,resObs_bs,fitzeta,indMat,dx,hwaitbar,abortbut)
if widthtype == 0
    % starting values for the non linear parameters in Å        % betaX, betaY, rho (position coordinates and width)
    if length(rho_start)~=size(coordinates,1)
        rho_start = mean(rho_start)*ones(size(coordinates(:,3),1),1);
    end
    StartParametersnonlin = [coordinates(:,1); coordinates(:,2);rho_start];
    if nargin<14
        EstimatedParametersnonlin = lsqnonlin('criterionGauss_diffrhoSmall',StartParametersnonlin',[],[],options,X,Y,n_c,K,L,resObs_bs,fitzeta,indMat,dx);
    else
        options.OutputFcn = @getIterDiff;
        EstimatedParametersnonlin = lsqnonlin('criterionGauss_samerhoSmall',StartParametersnonlin',[],[],options,X,Y,n_c,K,L,resObs_bs,fitzeta,indMat,dx,hwaitbar,abortbut);
    end
else
    % starting values for the non linear parameters in Å        % betaX, betaY, rho (position coordinates and width)
    rho = zeros(max(coordinates(:,3)),1);
    if length(rho_start)~=max(coordinates(:,3))
        for i=1:max(coordinates(:,3))
            rho(i,1) = mean(rho_start);
        end
    else
        for i=1:max(coordinates(:,3))
            rho(i,1) = mean(rho_start(coordinates(:,3)==1));
        end
    end
    StartParametersnonlin = [coordinates(:,1); coordinates(:,2);rho];
    if nargin<14
        EstimatedParametersnonlin = lsqnonlin('criterionGauss_samerhoSmall',StartParametersnonlin',[],[],options,X,Y,n_c,K,L,resObs_bs,coordinates(:,3),fitzeta,indMat,dx);
    else
        options.OutputFcn = @getIter;
        EstimatedParametersnonlin = lsqnonlin('criterionGauss_samerhoSmall',StartParametersnonlin',[],[],options,X,Y,n_c,K,L,resObs_bs,coordinates(:,3),fitzeta,indMat,dx,hwaitbar,abortbut);
    end
end

function stop = getIter(x,optimValues,state,Xreshape,Yreshape,n_c,K,L,reshapeobs,type,fitzeta,indMat,dx,hwaitbar,abortbut)
% This function updates a waitbar used in the GUI
if nargin>=14
    hwaitbar.setValue(optimValues.iteration/8);
end
if nargin==15
    % For abort button
    if toc>1
        pause(0.02);
        tic;
    end
    if ~abortbut.isEnabled
        stop = true;
        return
    end
end
stop = false;

function stop = getIterDiff(x,optimValues,state,Xreshape,Yreshape,n_c,K,L,reshapeobs,fitzeta,indMat,dx,hwaitbar,abortbut)
% This function updates a waitbar used in the GUI
if nargin>=13
    hwaitbar.setValue(optimValues.iteration/8);
end
if nargin==14
    % For abort button
    if toc>1
        pause(0.02);
        tic;
    end
    if ~abortbut.isEnabled
        stop = true;
        return
    end
end
stop = false;