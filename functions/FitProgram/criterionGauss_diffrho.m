function [Fun, Jacobian] = criterionGauss_diffrho(thetanonlin,Xreshape,Yreshape,K,L,reshapeobs)
% criterionGauss_diffrho - criterion to fit gaussian peak with varying width
%
%   Criterion is used to fit single peak locations on images
%
%   syntax: [Fun, Jacobian] = criterionGauss_diffrho(thetanonlin,Xreshape,Yreshape,K,L,reshapeobs)
%       thetanonlin - the nonlinear parameters (x,y-coordinate and width)
%       Xreshape    - X-grid of image (1 x N array)
%       Yreshape    - Y-grid of image (1 x N array)
%       K           - the size of the observation in x-direction
%       L           - the size of the observation in y-direction
%       reshapeobs  - observation (1 x N array)
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

beta = thetanonlin(1:2);
rho = thetanonlin(end);

R = sqrt((Xreshape - beta(1)).^2 + (Yreshape - beta(2)).^2);
Ga = gaus(R,rho);
GaT = Ga';
GaTGa = GaT*Ga;
GaTobs = GaT*reshapeobs;
eta = GaTGa\GaTobs;
model = eta*Ga;
Fun = model - reshapeobs;

if nargout == 2
    firstorderderivative = sparse(K*L,4);
    firstorderderivative(:,1) = model.*(Xreshape - beta(1))/(rho^2);
    firstorderderivative(:,2) = model.*(Yreshape - beta(2))/(rho^2);
    firstorderderivative(:,3) = model.*R.^2/rho^3;
    firstorderderivative(:,4) = Ga;
    
    derGaToThetanonlin1 = Ga.*(Xreshape - beta(1))/rho^2;
    derGaToThetanonlin2 = Ga.*(Yreshape - beta(2))/rho^2;
    derGaToThetanonlin3 = Ga.*R.^2/rho^3;
    matrix1T = derGaToThetanonlin1';
    derivativeThetalinToThetanonlin(:,1) = -GaTGa\(matrix1T*Ga + GaT*derGaToThetanonlin1)*eta + GaTGa\matrix1T*reshapeobs;
    matrix2T = derGaToThetanonlin2';
    derivativeThetalinToThetanonlin(:,2) = -GaTGa\(matrix2T*Ga + GaT*derGaToThetanonlin2)*eta + GaTGa\matrix2T*reshapeobs;
    matrix3T = derGaToThetanonlin3';
    derivativeThetalinToThetanonlin(:,3) = -GaTGa\(matrix3T*Ga + GaT*derGaToThetanonlin3)*eta + GaTGa\matrix3T*reshapeobs;

    firstorderder1 = firstorderderivative(:,1:3);
    firstorderder2 = firstorderderivative(:,end);
    Jacobian = firstorderder2*derivativeThetalinToThetanonlin + firstorderder1;
end