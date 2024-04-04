function [Fun, Jacobian] = criterionLorentz_samerho(beta,Xreshape,Yreshape,K,L,reshapeobs,rho)
% criterionLorent_samerho - criterion to fit Lorentzian peak with the same width
%
%   Criterion is used to fit single peak locations on images. The width is
%   not fitted
%
%   syntax: [Fun, Jacobian] = criterionLorentzian_samerho(thetanonlin,Xreshape,Yreshape,K,L,reshapeobs,rho)
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

R2 = (Xreshape - beta(1)).^2 + (Yreshape - beta(2)).^2;
Lo = lorentz(R2,rho);
LoT = Lo';
LoTLo = LoT*Lo;
LoTobs = LoT*reshapeobs;
eta = LoTLo\LoTobs;
model = eta*Lo;
Fun = model - reshapeobs;

if nargout == 2
    firstorderderivative = sparse(K*L,3);
    firstorderderivative(:,1) = 3*eta*Lo.^(5/3).*(Xreshape - beta(1));
    firstorderderivative(:,2) = 3*eta*Lo.^(5/3).*(Yreshape - beta(2));
    firstorderderivative(:,3) = Lo;
    
    derLoToThetanonlin1 = 3*Lo.^(5/3).*(Xreshape - beta(1));
    derLoToThetanonlin2 = 3*Lo.^(5/3).*(Yreshape - beta(2));
    matrix1T = derLoToThetanonlin1';
    derivativeThetalinToThetanonlin(:,1) = -LoTLo\(matrix1T*Lo + LoT*derLoToThetanonlin1)*eta + LoTLo\matrix1T*reshapeobs;
    matrix2T = derLoToThetanonlin2';
    derivativeThetalinToThetanonlin(:,2) = -LoTLo\(matrix2T*Lo + LoT*derLoToThetanonlin2)*eta + LoTLo\matrix2T*reshapeobs;

    firstorderder1 = firstorderderivative(:,1:2);
    firstorderder2 = firstorderderivative(:,end);
    Jacobian = firstorderder2*derivativeThetalinToThetanonlin + firstorderder1;
end