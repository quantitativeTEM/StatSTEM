function [output,outputMAP] = MAP_back_samerho(input)

% MAP_back_samerho - program that calculates the probability of the
%   number of atomic columns N present in a STEM image by using the MAP
%   probability rule. The model consists of a superposition of Gaussian 
%   peaks with equal widths and a constant background. Each peak is 
%   describing the scattered image intensity of a projected column.
%
% syntax: [output,outputMAP] = MAP_back_samerho(input)
%   input     - inputStatSTEM file
%   output    - outputStatSTEM file
%   outputMAP - outputStatSTEM_MAP file

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: J. Fatermans
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Input image
w = input.obs;
psizex = size(w,2);
psizey = size(w,1);

% Starting number of peaks
s = input.n_c;
% Maximum number of peaks to be tested.
M = input.MaxColumns;

% Resolution of image in Angstrom
dx = input.dx;

% Range of parameters in counts and pixels
zetamin = input.zetamin;
zetamax = input.zetamax;
rhomin = input.rhomin/dx;
rhomax = input.rhomax/dx;
etamin = input.etamin;
etamax = input.etamax;
beta_xmin = input.beta_xmin/dx;
beta_xmax = input.beta_xmax/dx;
beta_ymin = input.beta_ymin/dx;
beta_ymax = input.beta_ymax/dx;

x = 1:1:psizex;
y = 1:1:psizey;

% Number of positions to be tested before adding peak
r = input.testpoints;

% Warning is generated when M > 100 and/or r > 1000 to avoid very lengthy
% calculations
if M > 100 && r <= 1000
    uiwait(warndlg('Chosen Max. # columns not feasible to use in Model selection (MAP). Recommended to abort fitting routine.','Warning'));
end
if M <= 100 && r > 1000
    uiwait(warndlg('Chosen # Test points not feasible to use in Model selection (MAP). Recommended to abort fitting routine.','Warning'));
end
if M > 100 && r > 1000
    uiwait(warndlg('Chosen Max. # columns and # Test points not feasible to use in Model selection (MAP). Recommended to abort fitting routine.'));
end

% Number of iterations
Niter = r*(M-s)+1;

% Apply allowed range of parameters in counts and pixels
lb = [zetamin rhomin];
ub = [zetamax rhomax];
lb0 = [etamin beta_xmin beta_ymin];
ub0 = [etamax beta_xmax beta_ymax];
lb = [lb repmat(lb0,[1 M])];
ub = [ub repmat(ub0,[1 M])];

% Fit for initial configuration
% If GUI present, set progressbar to 0%
if ~isempty(input.GUI)
    input.waitbar.setValue(0)
end

% Set fit options for lsqnonlin
options = optimset('lsqnonlin');
options.Display = 'off';
options.TolX = 1e-4;
options.TolFun = eps;

% Start fitting procedure
lbc = lb(1:3*s+2);
ubc = ub(1:3*s+2);
ests = zeros([1 3*s+2]);
ests(1) = min(w(:)); % inital value: minimum pixel intensity
ests(2) = 1; % initial value: width of 1 pixel
for i = 1:s
    ests(3*i) = w(round(input.coordinates(i,2)/dx),round(input.coordinates(i,1)/dx)); % initial value: pixel intensity
    ests(3*i+1) = input.coordinates(i,1)/dx; % inital value: coordinate
    ests(3*i+2) = input.coordinates(i,2)/dx; % initial value: coordinate
end
p0 = ests;
[est,lsq,residual,exitflag,output2,lambda,jacobian] = lsqnonlin('criterion_MAP_back_samerho',p0,lbc,ubc,options,x,y,w,s,psizex,psizey);
hets = 2*(jacobian.')*jacobian;
heds = sqrt(det(hets));
ests = est;

etas = zeros(s,1);
coords = ones(s,3);
for i = 1:s
    etas(i) = ests(3*i);
    coords(i,1) = ests(3*i+1);
    coords(i,2) = ests(3*i+2);
end

zeta = est(1);
rho = ones(s,1)*est(2)*dx;
eta = etas;
coords(:,1:2) = coords(:,1:2)*dx;

model = outputStatSTEM(coords,rho,eta,zeta,dx,'lsq',lsq);
model = combinedGauss(model, psizex, psizey);
outputMAP = outputStatSTEM_MAP(model,dx,lsq,heds,etamin,etamax,beta_xmin*dx,beta_xmax*dx,beta_ymin*dx,beta_ymax*dx,rhomin*dx,rhomax*dx,zetamin,zetamax);

% Update probability curve
showMAPprob(outputMAP)
    
% fit for higher order configurations
% -----------------------------------
for jj = s+1:M
    lbc = lb(1:3*jj+2);
    ubc = ub(1:3*jj+2);
    estt = cell(1,r);
    chics = zeros(1,r);
    jac = cell(1,r);
    for ra = 1:r
        % Update progressbar if present
        if ~isempty(input.GUI)
            progress = ((jj-s-1)*r+ra)/Niter*100;
            input.waitbar.setValue(progress)
            % For aborting function
            drawnow
            if get(input.GUI,'Userdata')==0
                break
            end
        end
        R = rand([2 1]).*[psizex; psizey] + [0.5; 0.5];
        p0 = [ests w(round(R(2)),round(R(1))) R(1) R(2)];
        [estt{ra},chics(ra),residual,exitflag,output2,lambda,jac{ra}] = lsqnonlin('criterion_MAP_back_samerho',p0,lbc,ubc,options,x,y,w,jj,psizex,psizey);   
    end
    if ~isempty(input.GUI)
        % For aborting function
        drawnow
        if get(input.GUI,'Userdata')==0
            break
        end
    end
    [lsq,n] = min(chics);
    hets = 2*(jac{n}.')*jac{n};
    heds = sqrt(det(hets));
    est = estt{n};
    ests = est;
    
    etas = zeros(jj,1);
    coords = ones(jj,3);
    for i = 1:jj
        etas(i) = ests(3*i);
        coords(i,1) = ests(3*i+1);
        coords(i,2) = ests(3*i+2);
    end
    
    zeta = est(1);
    rho = ones(jj,1)*est(2)*dx;
    eta = etas;
    coords(:,1:2) = coords(:,1:2)*dx;
    model = outputStatSTEM(coords,rho,eta,zeta,dx,'lsq',lsq);
    model = combinedGauss(model,psizex,psizey);
    outputMAP = addModel(outputMAP,model,lsq,heds);
    
    % Update probability curve
    showMAPprob(outputMAP)
end

% Update progressbar if present
if ~isempty(input.GUI)
    input.waitbar.setValue(100)
end

% Select model
[output,outputMAP] = selNewModel(outputMAP,input);

