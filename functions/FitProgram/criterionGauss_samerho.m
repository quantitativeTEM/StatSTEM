function [Fun, Jacobian] = criterionGauss_samerho(beta,Xreshape,Yreshape,K,L,reshapeobs,rho)
% criterionGauss_samerho - criterion to fit gaussian peak with the same width
%
%   Criterion is used to fit single peak locations on images. The width is
%   not fitted
%
%   syntax: [Fun, Jacobian] = criterionGauss_samerho(thetanonlin,Xreshape,Yreshape,K,L,reshapeobs,rho)
%       thetanonlin - the nonlinear parameters (x,y-coordinate)
%       Xreshape    - X-grid of image (1 x N array)
%       Yreshape    - Y-grid of image (1 x N array)
%       K           - the size of the observation in x-direction
%       L           - the size of the observation in y-direction
%       reshapeobs  - observation (1 x N array)
%       rho         - the width
%       Fun         - difference between model and observation
%       Jacobian    - Jacobian
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

R = (Xreshape - beta(1)).^2 + (Yreshape - beta(2)).^2;
Ga = gaus(R,rho);
GaT = Ga';
GaTGa = GaT*Ga;
GaTobs = GaT*reshapeobs;
eta = GaTGa\GaTobs;
model = eta*Ga;
Fun = model - reshapeobs;

if nargout == 2
    rho2 = rho^2;
    firstorderderivative = sparse(K*L,3);
    firstorderderivative(:,1) = model.*(Xreshape - beta(1))/(rho2);
    firstorderderivative(:,2) = model.*(Yreshape - beta(2))/(rho2);
    firstorderderivative(:,3) = Ga;
    
    derGaToThetanonlin1 = Ga.*(Xreshape - beta(1))/(rho2);
    derGaToThetanonlin2 = Ga.*(Yreshape - beta(2))/(rho2);
    matrix1T = derGaToThetanonlin1';
    derivativeThetalinToThetanonlin(:,1) = -GaTGa\(matrix1T*Ga + GaT*derGaToThetanonlin1)*eta + GaTGa\matrix1T*reshapeobs;
    matrix2T = derGaToThetanonlin2';
    derivativeThetalinToThetanonlin(:,2) = -GaTGa\(matrix2T*Ga + GaT*derGaToThetanonlin2)*eta + GaTGa\matrix2T*reshapeobs;

    firstorderder1 = firstorderderivative(:,1:2);
    firstorderder2 = firstorderderivative(:,end);
    Jacobian = firstorderder2*derivativeThetalinToThetanonlin + firstorderder1;
end