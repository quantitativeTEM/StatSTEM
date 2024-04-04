function output = fitWidth(input, Tol, TolFun, offwait, maxwait)
% fitWidth - program to fit the width of gaussian peaks used for modelling 
%            a STEM image
%
%   In this method, the width of all gaussian peaks are fitted at the same 
%   time to a STEM image. For each atom type, the same width is fitted.
%
%   syntax: [output,abort] = fitWidth(input, Tol, TolFun, offwait, maxwait)
%       input   - inputStatSTEM structure
%       Tol     - Tolerance parameters (optional, standard 10^-4)
%       TolFun  - Tolerance on function (optional, standard Inf)
%       offwait - offset progressbar (optional)
%       maxwait - max value progressbar (optional)
%       output  - outputStatSTEM structure containing the fitted parameters
%
% See also: inputStatSTEM, outputStatSTEM, fitGauss

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Authors: A. De Backer, K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if nargin<5
    maxwait = 100;
end
if nargin<4
    % For progress bar
    offwait = 0;
end
if nargin<3
    TolFun = Inf;
end
if nargin<2
    Tol = 10^-4;
end
% Fit options
options = optimset('fminsearch');
if ~isempty(input.GUI)
    % Gather other functions
    options.OutputFcn = @getIter;
    options.Display = 'none';
else
    if input.silent
        options.Display = 'none';
    else
        options.Display = 'iter';
    end
    input.waitbar = 0;
end
options.TolX = Tol;
options.TolFun = TolFun;
options.MaxFunEvals = Inf;
options.MaxIter = max(1/sqrt(Tol)*2,50)*length(input.rho_start);
% Fit starting parameters
if input.rho_start==0
    input = averageDistance(input);
end
max_n = 70;
if ~isempty(input.GUI)
    input.waitbar.setValue(offwait);
end

% Fit
tic
input.obs = input.obs - input.zeta;
optIn = {};
if ~isempty(input.GUI)
    optIn = {input.GUI,input.waitbar,offwait,maxwait,options.MaxIter};
end

if input.peakShape == 1
    EstimatedRho = fminsearch('criterionRho',input.rho_start,options,input.Xreshape,input.Yreshape,input.K,input.L,input.reshapeobs-input.zeta,...
    input.coordinates(:,1),input.coordinates(:,2),input.fitZeta,input.coordinates(:,3),input.indMat,input.dx,input.peakShape,(1:input.n_c)',max_n,optIn{:});
elseif input.peakShape == 2
    EstimatedRho = fminsearch('criterionRhoLo',input.rho_start,options,input.Xreshape,input.Yreshape,input.K,input.L,input.reshapeobs-input.zeta,...
    input.coordinates(:,1),input.coordinates(:,2),input.fitZeta,input.coordinates(:,3),input.indMat,input.dx,input.peakShape,(1:input.n_c)',max_n,optIn{:});
end

rho = EstimatedRho(input.coordinates(:,3));

% Create outputStatSTEM structure
if input.peakShape == 1
    output = getLinFitParam(input,rho);
    output = combinedGauss(output, input.K, input.L);
elseif input.peakShape == 2
    output = getLinFitParamLo(input,rho);
    output = combinedLorentz(output, input.K, input.L);
end
output.iter = 0;
temp = (output.model - input.obs).^2;
output.lsq = sum(temp(:));

function stop = getIter(x,optimValues,state,~,~,~,~,~,~,~,~,~,~,~,~,~,max_n,GUI,hwaitbar,offwait,maxwait,maxIter)
% This function updates a waitbar used in the GUI
if nargin<20
    offwait = 0;
    maxwait = 100;
elseif nargin<21
    maxwait = 100;
end
r = maxwait-offwait;
if nargin>=19
    hwaitbar.setValue(offwait+optimValues.iteration/maxIter*r);
end
if nargin>=18
    % For abort button
    drawnow
    if get(GUI,'Userdata')==0
        error('Error: function stopped by user')
    end
end
stop = false;