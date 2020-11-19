function f = func_jac(X,Y,psizex,psizey,est,n,sigma_vec)
%--------------------------------------------------------------------------
% Function to calculate Jacobian matrix of model of superposition of
% Gaussian peaks
% Syntax: - X,Y: meshgrid of image pixel dimensions in x-and y directions
%         - psizex, psizey: x-and y dimensions of image (pixels)
%         - est: fitted parameters of model
%         - n: number of Gaussian peaks
%         - sigma_vec: vector of sqrt(image)
%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2020, EMAT, University of Antwerp
% Author: J. Fatermans
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

f = zeros(psizey*psizex,3*n+2);
firstderiv_zeta = ones(psizey,psizex); % derivative to zeta
f(:,1) = firstderiv_zeta(:)./sigma_vec;
firstderiv_rho = zeros(psizey,psizex,n); % derivative to rho
for nn = 1:n
    R2 = (X-est(3*nn+1)).^2 + (Y-est(3*nn+2)).^2;
    firstderiv_rho(:,:,nn) = est(3*nn)*exp(-0.5*R2/est(2)^2).*R2/est(2)^3;
    firstderiv_eta = exp(-0.5*R2/est(2)^2); % derivative to eta
    f(:,3*nn) = firstderiv_eta(:)./sigma_vec;
    firstderiv_betax = est(3*nn)*exp(-0.5*R2/est(2)^2).*(X-est(3*nn+1))/est(2)^2; % derivative to betax
    f(:,3*nn+1) = firstderiv_betax(:)./sigma_vec;
    firstderiv_betay = est(3*nn)*exp(-0.5*R2/est(2)^2).*(Y-est(3*nn+2))/est(2)^2; % derivative to betay
    f(:,3*nn+2) = firstderiv_betay(:)./sigma_vec;
end
firstderiv_rho = sum(firstderiv_rho,3);
f(:,2) = firstderiv_rho(:)./sigma_vec;