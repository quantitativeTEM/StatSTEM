function [Fun, Jacobian] = criterionLorentz_diffrho(thetanonlin,Xreshape,Yreshape,K,L,reshapeobs)
% criterionLorentz_diffrho - criterion to fit Lorentzian peak with varying width
%
%   Criterion is used to fit single peak locations on images
%
%   syntax: [Fun, Jacobian] = criterionLorentz_diffrho(thetanonlin,Xreshape,Yreshape,K,L,reshapeobs)
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
% Copyright: 2023, EMAT, University of Antwerp
% Author: Annick De Backer
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

beta = thetanonlin(1:2);
rho = thetanonlin(end);

R2 = (Xreshape - beta(1)).^2 + (Yreshape - beta(2)).^2;
Lo = lorentz(R2,rho);
LoT = Lo';
invLoTLo = inv(LoT*Lo);
LoTobs = LoT*reshapeobs;
eta =  invLoTLo*LoTobs;
model = eta*Lo;
Fun = model - reshapeobs;

if nargout == 2
    firstorderderivative = sparse(K*L,4);
    firstorderderivative(:,1) = 3*eta*Lo.^(5/3).*(Xreshape - beta(1));
    firstorderderivative(:,2) = 3*eta*Lo.^(5/3).*(Yreshape - beta(2));
    firstorderderivative(:,3) = -3*eta*Lo.^(5/3).*rho;
    firstorderderivative(:,4) = Lo;
    
    derLoToThetanonlin1 = 3*Lo.^(5/3).*(Xreshape - beta(1));
    derLoToThetanonlin2 = 3*Lo.^(5/3).*(Yreshape - beta(2));
    derLoToThetanonlin3 = -3*Lo.^(5/3).*rho;
    matrix1T = derLoToThetanonlin1';
    derivativeThetalinToThetanonlin(:,1) = -invLoTLo*(matrix1T*Lo + LoT*derLoToThetanonlin1)*eta + invLoTLo*matrix1T*reshapeobs;
    matrix2T = derLoToThetanonlin2';
    derivativeThetalinToThetanonlin(:,2) = -invLoTLo*(matrix2T*Lo + LoT*derLoToThetanonlin2)*eta + invLoTLo*matrix2T*reshapeobs;
    matrix3T = derLoToThetanonlin3';
    derivativeThetalinToThetanonlin(:,3) = -invLoTLo*(matrix3T*Lo + LoT*derLoToThetanonlin3)*eta + invLoTLo*matrix3T*reshapeobs;

    firstorderder1 = firstorderderivative(:,1:3);
    firstorderder2 = firstorderderivative(:,end);
    Jacobian = firstorderder2*derivativeThetalinToThetanonlin + firstorderder1;
end