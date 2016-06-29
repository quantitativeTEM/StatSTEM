function [output,abort] = fitRho(input, FP,offwait, Tol, TolFun)
% fitRho - program to fit the width of gaussian peaks used for modelling a 
%          STEM image
%
%   In this method, the width of all gaussian peaks are fitted at the same 
%   time to a STEM image. For each atom type, the same width is fitted.
%
%   syntax: [output,abort] = fitRho(input, FP,offwait, Tol, TolFun)
%       input   - input structure
%       FP      - structure containing the fitting options
%       offwait - offset progressbar (optional)
%       Tol     - Tolerance parameters (optional, standard 10^-4)
%       TolFun  - Tolerance on function (optional, standard Inf)
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

abort = 0;
if nargin<3
    % For progress bar
    offwait = 0;
end
if nargin<5
    TolFun = Inf;
end
if nargin<4
    Tol = 10^-4;
end
% Fit options
options = optimset('fminsearch');
if FP.GUI==1
    options.OutputFcn = @getIter;
    options.Display = 'none';
else
    if FP.silent
        options.Display = 'none';
    else
        options.Display = 'iter';
    end
    FP.waitbar = 0;
end
options.TolX = Tol;
options.TolFun = TolFun;
options.MaxFunEvals = Inf;
options.MaxIter = max(1/sqrt(Tol)*2,50)*length(FP.rho_start);
% Fit parameters
output.coordinates = input.coordinates(:,1:2);
max_n = 70;
if FP.GUI==1
    FP.waitbar.setValue(offwait);
end

% Fit
tic
if FP.GUI
    EstimatedRho = fminsearch('criterionRho',FP.rho_start,options,FP.Xreshape,FP.Yreshape,FP.K,FP.L,FP.reshapeobs-FP.zeta,output.coordinates(:,1),output.coordinates(:,2),FP.fitzeta,input.coordinates(:,3),FP.indMat,input.dx,(1:FP.n_c)',max_n,FP.waitbar,FP.abortButton,offwait,options.MaxIter);
else
    EstimatedRho = fminsearch('criterionRho',FP.rho_start,options,FP.Xreshape,FP.Yreshape,FP.K,FP.L,FP.reshapeobs-FP.zeta,output.coordinates(:,1),output.coordinates(:,2),FP.fitzeta,input.coordinates(:,3),FP.indMat,input.dx,(1:FP.n_c)',max_n);
end
% Store fitted rho
output.rho = EstimatedRho(input.coordinates(:,3));

function stop = getIter(x,optimValues,state,Xreshape,Yreshape,K,L,reshapeobs,BetaX,BetaY,fitzeta,type,indMat,dx,ind,max_n,hwaitbar,abortbut,offwait,maxIter)
% This function updates a waitbar used in the GUI
if nargin<19
    offwait = 50;
    n = 2;
else
    n = 1;
end
if nargin>=17
    hwaitbar.setValue(offwait+optimValues.iteration/maxIter*(25*n));
end
if nargin>=18
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