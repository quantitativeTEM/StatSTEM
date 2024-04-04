function [Fun, Jacobian] = criterionGauss_diffrhoSmall(thetanonlin,X,Y,n_c,K,L,obs,back,indMat,dx,hwaitbar,abortbut)
% criterionGauss_diffrhoSmall - criterion to fit gaussian peak with varying width
%
%   Criterion is used to fit multiple peak locations to an image
%
%   syntax: [Fun, Jacobian] = criterionGauss_diffrhoSmall(thetanonlin,X,Y,n_c,K,L,obs,back,indMat,dx,hwaitbar,abortbut)
%       thetanonlin - the nonlinear parameters (x,y-coordinate and width)
%       X           - X-grid of image (1 x N array)
%       Y           - Y-grid of image (1 x N array)
%       n_c         - number of peaks
%       K           - the size of the observation in x-direction
%       L           - the size of the observation in y-direction
%       obs         - observation (1 x N array)
%       back        - boolean, indicating is background must be fitted
%       indMat      - matrix indicating the indice of each pixel
%       dx          - the pixel size
%       hwaitbar    - reference to waitbar (optional)
%       abortbut    - reference to abort button (optional)
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

betaX = thetanonlin(1:n_c);
betaY = thetanonlin(n_c+1:2*n_c);
rho = thetanonlin(2*n_c+1:end);

Ga = sparse(K*L,n_c+back);
Ga(:,1:end-back) = getGa(K,L,indMat,rho,dx,betaX,betaY,X,Y,(1:n_c)');
if back
    Ga(:,end) = ones(K*L,1);
end
GaT = Ga';
invGaTGa = inv(GaT*Ga);
GaTobs = GaT*obs;
thetalin = invGaTGa*GaTobs;
model = zeros(K*L,1);
for n=1:n_c+back
    model = model + Ga(:,n)*thetalin(n);
end
Fun = model - obs;

if nargout==2
    firstorderderivative = sparse(K*L,4*n_c+back);
    derivativeThetalinToThetanonlin = sparse(n_c+back,3*n_c);
    % For Jacobian
    derGaToThetanonlin1 = sparse(K*L,n_c+back);
    derGaToThetanonlin2 = sparse(K*L,n_c+back);
    derGaToThetanonlin3 = sparse(K*L,n_c+back);
    for i=1:n_c
        % BetaX
        firstorderderivative(:,i) = thetalin(i)*Ga(:,i).*(X - betaX(i))/(rho(i)^2);
        % BetaY
        firstorderderivative(:,n_c+i) = thetalin(i)*Ga(:,i).*(Y - betaY(i))/(rho(i)^2);
        % rho
        R2 = ((X - betaX(i)).^2 + (Y - betaY(i)).^2);
        firstorderderivative(:,2*n_c + i) = firstorderderivative(:,2*n_c + i) + thetalin(i)*Ga(:,i).*R2/(rho(i))^3;
        % eta
        firstorderderivative(:,3*n_c+i) = Ga(:,i);

        derGaToThetanonlin1(:,i) = Ga(:,i).*(X - betaX(i))/((rho(i))^2);
        derGaToThetanonlin2(:,i) = Ga(:,i).*(Y - betaY(i))/((rho(i))^2);
        derGaToThetanonlin3(:,i) = Ga(:,i).*R2/(rho(i))^3;

        matrix1T = derGaToThetanonlin1';
        derivativeThetalinToThetanonlin(:,i) = -invGaTGa*(matrix1T*Ga + GaT*derGaToThetanonlin1)*thetalin + invGaTGa*matrix1T*obs;
        matrix2T = derGaToThetanonlin2';
        derivativeThetalinToThetanonlin(:,n_c+i) = -invGaTGa*(matrix2T*Ga + GaT*derGaToThetanonlin2)*thetalin + invGaTGa*matrix2T*obs;
        matrix3T = derGaToThetanonlin3';
        derivativeThetalinToThetanonlin(:,2*n_c+i) = -invGaTGa*(matrix3T*Ga + GaT*derGaToThetanonlin3)*thetalin + invGaTGa*matrix3T*obs;
        
        derGaToThetanonlin1(:,i) = sparse(K*L,1);
        derGaToThetanonlin2(:,i) = sparse(K*L,1);
        derGaToThetanonlin3(:,i) = sparse(K*L,1);
    end
    if back
        firstorderderivative(:,end) = ones(K*L,1);
    end
    firstorderder1 = firstorderderivative(:,1:3*n_c);
    firstorderder2 = firstorderderivative(:,3*n_c+1:4*n_c+back);
    Jacobian = firstorderder2*derivativeThetalinToThetanonlin + firstorderder1;
end