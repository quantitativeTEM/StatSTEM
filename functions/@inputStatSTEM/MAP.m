function [output,outputMAP] = MAP(input)
%--------------------------------------------------------------------------
% Code to calculate probability of number of atomic columns in a single ADF
% or ABF STEM (or even TEM) image by using the MAP probability rule.
% Fitting is done by a model consisting of Gaussian peaks (describing projected
% atomic columns) with equal widths superposed on a constant background.
% More information: - Fatermans et al., Phys. Rev. Lett. 121, 056101 (2018)
%                   - Fatermans et al., Ultramicroscopy 201, 81-91 (2019)
% Code structured as follows:
%           - Import image and general information
%           - Import prior range on parameters for MAP probability: minimum and 
%             maximum values on expected parameter values
%           - Define coordinates to be tested in search for next column:
%             assume coordinates to be uniformly distributed over image
%             (distance between testing coordinates more or less 1 A)
%           - Fitting of possible configurations (starting from 0 columns
%             if no input is given), including search for atomic columns + 
%             show progress of construction of relative probability curve 
%             and model fit: analysis stops at provided number of max 
%             columns or, when this number is 0 or smaller than input, when 
%             probability drops. Fitting is performed on smaller regions
%             (around 6Ax6A) of total image.
%           - Save output: including
%             chi^2 (least squares), det_hes (determinant hessian),
%             estimated parameters (est_params) and estimated models
%             (est_models) and MAP as a function of the number of atomic columns

% syntax: [output,outputMAP] = MAP(input)
%   input     - inputStatSTEM file
%   output    - outputStatSTEM file
%   outputMAP - outputStatSTEM_MAP file
%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2020, EMAT, University of Antwerp
% Author: J. Fatermans
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Import STEM (or TEM) image (w) + mention pixel size in A + provide
% inputcoords of first configuration if necessary
w = input.obs; % image in electron counts
w_vec = w(:);
ww = w;
ww(ww<0) = 0;
sigma = sqrt(ww);
sigma(sigma==0) = 1;
sigma_vec = sigma(:);
[psizey,psizex] = size(w); % number of pixels in x-and y-direction in image
% x = vector of pixels in x-direction
% y = vector of pixels in y-direction
% X,Y: provides 2D representation of vectors x and y
x = 1:1:psizex;
y = 1:1:psizey;
[X,Y] = meshgrid(x,y);
dx = input.dx; % Pixel size of image in Angstrom
N_max = input.MaxColumns; % Maximum number of peaks to be tested: if zero, 
% then code stops automatically when probability drops
input_coords = input.coordinates/dx+0.5; % Starting coordinates in pixels (if any)
[N_input,~] = size(input_coords); % number of input coordinates
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Import prior minimum and maximum values on each parameter of model
% Important that minimum and maximum range contains actual value
% zeta = background (in pixel intensities: electron counts)
zetamin = input.zetamin;
zetamax = input.zetamax;
% rho = width of atomic columns (in pixels)
rhomin = input.rhomin/dx;
rhomax = input.rhomax/dx;
% eta = intensities of atomic columns (in pixel intensities: electron counts)
etamin = input.etamin;
etamax = input.etamax;
% beta = positions of atomic columns (in pixels)
beta_xmin = input.beta_xmin/dx+0.5;
beta_xmax = input.beta_xmax/dx+0.5;
beta_ymin = input.beta_ymin/dx+0.5;
beta_ymax = input.beta_ymax/dx+0.5;
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% For searching for atomic columns, testing coordinates need to be provided
% Coordinates are uniformly divided over the entire image
% Define distance between test coordinates in x and y more or less 1 A
% test_dist = 1st value = distance between coordinates in x-direction in pixels
%             2nd value = distance between coordinates in y-direction in pixels
test_dist = [round(1/dx) round(1/dx)];
% restx,resty: gives remainder after division in x-and y direction
restx = mod(psizex,test_dist(1));
resty = mod(psizey,test_dist(2));
% rx = number of test coordinates in x-direction
% ry = number of test coordinates in y-direction
% r = total number of test coordinates (r = rx*ry)
rx = (psizex-restx)/test_dist(1);
ry = (psizey-resty)/test_dist(2);
r = rx*ry;
% rx_vec = make vector: 0 -> rx-1
% ry_vec = make vector: 0 -> ry-1
% RX_vec, RY_vec: provides 2D representation of vectors rx_vec and ry_vec in pixels
rx_vec = 0:rx-1;
ry_vec = 0:ry-1;
[RX_vec,RY_vec] = meshgrid(rx_vec*test_dist(1)+0.5*(test_dist(1)+restx),...
    ry_vec*test_dist(2)+0.5*(test_dist(2)+resty));
% test_coords: 1st column = test x-coords in pixels
%              2nd column = test y-coords in pixels
test_coords = [RX_vec(:) RY_vec(:)];
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Set fit options for lsqnonlin
options = optimset('lsqnonlin');
options.Display = 'off';
options.TolX = 1e-4;
options.TolFun = eps;
% Update progress bar
if ~isempty(input.GUI)
    [M0,~] = size(input_coords); % number of starting coordinates
    if N_max > M0
        Niter = (N_max-M0)*r+1; % total number of expected iteration when max number of columns 
        % to be tested is known
    else
        Niter = 100*r+1; % roughly estimated number of expected iterations when max number of
        % columns to be tested is not known
    end
    input.waitbar.setValue(0.0);
end
% Perform calculation
if isempty(input_coords) % when no input coordinates are given
    % For 0 peaks
    lbc = zetamin; % lower bound on parameters
    ubc = zetamax; % upper bound on parameters
    p0 = min(w(:)); % starting values for model fit (only background)
    [est_params{1},chi2(1)] = ...
        lsqnonlin('criterion_MAP_zeta',p0,lbc,ubc,options,psizex,psizey,w,sigma);
    zeta = est_params{1}; % fitted background (image intensity)
    rho = 1/2.355/dx; % starting value for width for further analysis (FWHM = 1A)
    eta = etamin; % starting value for column intensity for further analysis (minimum intensity)
    est_models(:,:,1) = zeros(psizey,psizex) + est_params{1}(1); % fitted model
    det_hes(1) = sum(sum(2./sigma.^2)); % determinant of Hessian
    hes{1} = det_hes(1);
    model = outputStatSTEM(input_coords,[],[],zeta,dx); % create outputStatSTEM object
else % when input coordinates are given
     % For inital number of peaks = M0
    lbc = [zetamin rhomin repmat([beta_xmin beta_ymin],1,M0)]; % lower bound on parameters
    ubc = [zetamax rhomax repmat([beta_xmax beta_ymax],1,M0)]; % upper bound on parameters
    p0 = zeros(1,2*M0+2); % starting values for model fit
    p0(1:2) = [min(w(:)) 1/2.355/dx]; % starting values for background and width
    for pp = 1:M0
        p0(2*pp+1:2*pp+2) = input_coords(pp,1:2); % starting values for positions
    end
    [est,chi2(1)] = ...
    lsqnonlin('criterion_lin_full',p0,lbc,ubc,options,X,Y,psizex,psizey,w,sigma,M0,etamin);
    zeta = est(1); % fitted background (image intensity)
    rho = est(2); % fitted width (pixels)
    xy = zeros(M0,2); % fitted positions (pixels)
    m_vec = (w_vec-zeta)./sigma_vec;
    Ga = zeros(length(m_vec),M0);
    for ii = 1:M0
        xy(ii,:) = est(2*ii+1:2*ii+2);
        R2 = (X-xy(ii,1)).^2 + (Y-xy(ii,2)).^2;
        g = exp(-0.5*R2./rho^2);
        Ga(:,ii) = g(:)./sigma_vec;
    end
    GaT = Ga.';
    GaTGa = GaT*Ga;
    GaTY = GaT*m_vec;
    eta = GaTGa\GaTY;
    eta(eta<etamin) = etamin; % fitted atomic column intensities (image intensities)
    est_models(:,:,1) = zeros(psizey,psizex) + zeta; % fitted model
    est_params{1}(1) = zeta; % fitted parameters
    est_params{1}(2) = rho;
    for jj = 1:M0
        R2 = (X-xy(jj,1)).^2 + (Y-xy(jj,2)).^2;
        est_models(:,:,1) = est_models(:,:,1) + eta(jj)*exp(-0.5*R2./rho^2);
        est_params{1}(3*jj) = eta(jj);
        est_params{1}(3*jj+1:3*jj+2) = xy(jj,:);
    end
    % Calculate Hessian by approximation, dropping term with second derivatives
    jac = func_jac(X,Y,psizex,psizey,est_params{1},M0,sigma_vec);
    hes{1} = 2*(jac.')*jac;
    det_hes(1) = det(hes{1});
    model = outputStatSTEM((xy-0.5)*dx,rho*dx,eta,zeta,dx); % create outputStatSTEM object
end
model = combinedGauss(model,psizex,psizey); % add model to outputStatSTEM object
outputMAP = outputStatSTEM_MAP(model,dx,chi2(1),det_hes(1),input.etamin,input.etamax,...
    input.beta_xmin,input.beta_xmax,input.beta_ymin,input.beta_ymax,input.rhomin,...
    input.rhomax,input.zetamin,input.zetamax); % create outputStatSTEM_MAP object
% Update probability curve
showMAPprob_update(outputMAP,input)
% Preparation for testing with test points on cropped images
crop = zeros(r,4); % contains boundaries of cropped images in x and y
w_crop = cell(r,1); % cropped images
sigma_crop = cell(r,1); % sigma of cropped images
X_crop = cell(r,1);
Y_crop = cell(r,1);
beta_minmax = zeros(r,4); % boundaries of beta parameters of cropped images
for rr = 1:r
    crop(rr,1) = round(test_coords(rr,1)-3/dx); % size of cropped image more or less 6x6 A
    crop(rr,2) = round(test_coords(rr,1)+3/dx);
    crop(rr,3) = round(test_coords(rr,2)-3/dx);
    crop(rr,4) = round(test_coords(rr,2)+3/dx);
    if crop(rr,1) < 1
        crop(rr,1) = 1;
    end
    if crop(rr,2) > psizex
        crop(rr,2) = psizex;
    end
    if crop(rr,3) < 1
        crop(rr,3) = 1;
    end
    if crop(rr,4) > psizey
        crop(rr,4) = psizey;
    end
    w_crop{rr,1} = w(crop(rr,3):crop(rr,4),crop(rr,1):crop(rr,2));
    sigma_crop{rr,1} = sigma(crop(rr,3):crop(rr,4),crop(rr,1):crop(rr,2)); 
    x_crop = 1:1:(crop(rr,2)-crop(rr,1)+1);
    y_crop = 1:1:(crop(rr,4)-crop(rr,3)+1);
    [X_crop{rr,1},Y_crop{rr,1}] = meshgrid(x_crop,y_crop);
    beta_minmax(rr,:) = [0.5 crop(rr,2)-crop(rr,1)+1+0.5 0.5 crop(rr,4)-crop(rr,3)+1+0.5];
end
% Run while loop searching for next peaks
n_iter = 1; % number of iterations while loop (also equal to number of columns - M0)
stop = 0;
while stop == 0 % run while loop until probability has dropped -1 from maximum at logscale
    % or when maximum number of peaks to be tested has been reached
    xy_test = cell(r,1); % positions of tested coordinates
    xy_nottest = cell(r,1); % positions of remaining coordinats
    chi2_test = zeros(r,1); % least squares evaluation of tested coordinates
    if N_max <= M0 && n_iter ~= 1 % in case max number of expected columns is unknown
        Niter = 1+(n_iter-1)*r-max(map(map~=0))*r;
    end
    for rr = 1:r
        if ~isempty(input.GUI)
            % Updating progress bar                
            progress = (1+(n_iter-1)*r+rr)/Niter*100;
            input.waitbar.setValue(progress);
            % For aborting function
            drawnow
            if get(input.GUI,'Userdata')==0
                break
            end
        end
        if M0 == 0 && n_iter == 1 % first iteration of while loop + no input coordinates given
            n_xy = 0; % no coordinates to be tested
            n_xy_not = 0;
        else % starting coordinates have already been provided or peaks have already been detected
            ff = find(xy(:,1)>=crop(rr,1)-0.5 & xy(:,1)<=crop(rr,2)+0.5 ...
                & xy(:,2)>=crop(rr,3)-0.5 & xy(:,2)<=crop(rr,4)+0.5); % find already detected coordinates 
            % within boundaries of cropped area
            eta_sel = eta(ff); % select peak intensities of peaks within cropped area
            eta_notsel = eta;
            eta_notsel(ff) = []; % peak intensities of peaks outside cropped area
            xy_sel = xy(ff,:); % select peak positions within cropped area
            xy_sel(:,1) = xy_sel(:,1)-(crop(rr,1)-1); % put x-coordinate values to cropped image
            xy_sel(:,2) = xy_sel(:,2)-(crop(rr,3)-1); % put y-coordinate values to cropped image
            xy_notsel = xy;
            xy_notsel(ff,:) = []; % peak positions outside cropped area
            xy_nottest{rr,1} = xy_notsel;
            [n_xy,~] = size(xy_sel); % number of peaks to be tested inside cropped area
            [n_xy_not,~] = size(xy_notsel); % number of peaks outside cropped area
        end
        model_loop = zeros(psizey,psizex) + est_params{n_iter}(1); % model of columns outside cropped area
        for ii = 1:n_xy_not
            R2 = (X-xy_notsel(ii,1)).^2 + (Y-xy_notsel(ii,2)).^2;
            model_loop = model_loop + eta_notsel(ii)*exp(-0.5*R2/rho^2);
        end
        model_loop_crop = model_loop(crop(rr,3):crop(rr,4),crop(rr,1):crop(rr,2)); % crop model to cropped area
        nn = n_xy + 1; % number of columns to be investigated in cropped image
        lbc_test = repmat([etamin beta_minmax(rr,1) beta_minmax(rr,3)],1,nn);
        ubc_test = repmat([etamax beta_minmax(rr,2) beta_minmax(rr,4)],1,nn);
        p0_test = zeros(1,3*nn); % fit cropped area with fixed zeta and rho (only peak intensities and positions)
        for nn_xy = 1:n_xy
            p0_test(3*nn_xy-2:3*nn_xy) = [eta_sel(nn_xy,1) xy_sel(nn_xy,:)];
        end
        % starting parameters of newly added peak
        p0_test(end-2:end) = [min(eta) test_coords(rr,1)-(crop(rr,1)-1) test_coords(rr,2)-(crop(rr,3)-1)];
        est_params_test = ... % get fitted parameters of peak intensities and positions
            lsqnonlin('criterion_MAP',p0_test,lbc_test,ubc_test,options,X_crop{rr,1},Y_crop{rr,1},...
            w_crop{rr,1},nn,sigma_crop{rr,1},model_loop_crop,rho);
        model_test = model_loop; % create test model to evaluate chi2 value of total image
        for ii = 1:nn
            xy_test{rr,1}(ii,:) = est_params_test(3*ii-1:3*ii) + [crop(rr,1)-1 crop(rr,3)-1];
            R2 = (X-xy_test{rr,1}(ii,1)).^2 + (Y-xy_test{rr,1}(ii,2)).^2;
            model_test = model_test + est_params_test(3*ii-2)*exp(-0.5*R2/rho^2);
        end
        chi2_test(rr,1) = sum(sum((w-model_test).^2./sigma.^2)); % least squares value of test
    end
    [~,index_max] = min(chi2_test); % select test coordinates with lowest chi2 value
    xy = [xy_nottest{index_max,1}; xy_test{index_max,1}]; % add best coordinates to position vector
    lbc = [zetamin rhomin];
    ubc = [zetamax rhomax];
    p0 = [zeta rho]; % starting values of background and width
    [est,chi2(n_iter+1)] = ... % get optimized background and width in total image by linear fitting
    lsqnonlin('criterion_lin',p0,lbc,ubc,options,X,Y,psizex,psizey,w,sigma,n_iter+M0,xy,etamin);
    zeta = est(1); % fitted background (image intensities)
    rho = est(2); % fitted width (pixels)
    m_vec = (w_vec-zeta)./sigma_vec;
    Ga = zeros(length(m_vec),n_iter+M0);
    for ii = 1:n_iter+M0
        R2 = (X-xy(ii,1)).^2 + (Y-xy(ii,2)).^2;
        g = exp(-0.5*R2./rho^2);
        Ga(:,ii) = g(:)./sigma_vec;
    end
    GaT = Ga.';
    GaTGa = GaT*Ga;
    GaTY = GaT*m_vec;
    eta = GaTGa\GaTY;
    eta(eta<etamin) = etamin; % fitted intensities (image intensities)
    est_models(:,:,n_iter+1) = zeros(psizey,psizex) + zeta; % fitted models
    est_params{n_iter+1}(1) = zeta; % fitted parameters
    est_params{n_iter+1}(2) = rho;
    for jj = 1:n_iter+M0
        R2 = (X-xy(jj,1)).^2 + (Y-xy(jj,2)).^2;
        est_models(:,:,n_iter+1) = est_models(:,:,n_iter+1) + eta(jj)*exp(-0.5*R2./rho^2);
        est_params{n_iter+1}(3*jj) = eta(jj);
        est_params{n_iter+1}(3*jj+1:3*jj+2) = xy(jj,:);
    end
    % Calculate Hessian by approximation, dropping term with second derivatives
    jac = func_jac(X,Y,psizex,psizey,est_params{n_iter+1},n_iter+M0,sigma_vec);
    hes{n_iter+1} = 2*(jac.')*jac;
    det_hes(n_iter+1) = det(hes{n_iter+1});
    model = outputStatSTEM((xy-0.5)*dx,rho*dx,eta,zeta,dx); % create outputStatSTEM object
    model = combinedGauss(model,psizex,psizey); % add model to outputStatSTEM object
    outputMAP = addModel(outputMAP,model,chi2(n_iter+1),det_hes(n_iter+1)); % add new info to outputStatSTEM_MAP object
    % Update probability curve
    showMAPprob_update(outputMAP,input)
    map = outputMAP.MAPprob;
    [~,N_det] = max(map);
    outputMAP.NselMod = N_det;
    % go to next iteration of while loop
    n_iter = n_iter + 1;
    % check to stop while loop
    if N_max <= N_input % stop if probabilty drops -1 on log-scale compared to max probability
        if map(end) < map(end-1) && map(end)+1 < map(N_det)
            stop = 1;
        end
    else % stop if max number of peaks to be tested is reached
        if n_iter + M0 > N_max
            stop = 1;
        end
    end      
end
% Update progress bar
if ~isempty(input.GUI)
    input.waitbar.setValue(100)
end
% Select fitted model of choice
[output,outputMAP] = selNewModel(outputMAP,input);
