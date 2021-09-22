function [Fun, Jacobian] = criterionGauss_samerhoSmall(thetanonlin,X,Y,n_c,K,L,obs,type,back,indMat,dx,hwaitbar,abortbut)
% criterionGauss_samerhoSmall - criterion to fit gaussian peak with same width
%
%   Criterion is used to fit multiple peak locations to an image. The width
%   is kept constant for atoms having the same type.
%
%   syntax: [Fun, Jacobian] = criterionGauss_samerhoSmall(thetanonlin,X,Y,n_c,K,L,obs,type,back,indMat,dx,hwaitbar,abortbut)
%       thetanonlin - the nonlinear parameters (x,y-coordinates and widths)
%       X           - X-grid of image (1 x N array)
%       Y           - Y-grid of image (1 x N array)
%       n_c         - number of peaks
%       K           - the size of the observation in x-direction
%       L           - the size of the observation in y-direction
%       obs         - observation (1 x N array)
%       type        - the atom types per peak (1 x N array)
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
rho_est = rho(type);
KL = K*L;
Ga = sparse(KL,n_c+back);
Ga(:,1:end-back) = getGa(K,L,indMat,rho_est,dx,betaX,betaY,X,Y,(1:n_c)');
% for i = 1:n_c
%     R2 = (X - betaX(i)).^2 + (Y - betaY(i)).^2;
%     Ga(:,i) = gaus( R2 , rho_est(i) );
% end
if back
    Ga(:,end) = ones(KL,1);
end
GaT = Ga';
invGaTGa = inv(GaT*Ga);
GaTobs = GaT*obs;
thetalin = invGaTGa*GaTobs;
model = zeros(KL,1);
for n=1:n_c+back
    model = model + Ga(:,n)*thetalin(n);
end
Fun = model - obs;

if nargout==2
    l_rho = length(rho);
    firstorderderivative = sparse(KL,3*n_c+l_rho+back);
    derivativeThetalinToThetanonlin = sparse(n_c+back,2*n_c+l_rho);
    % For Jacobian
    derGaToThetanonlin1 = sparse(KL,n_c+back);
    derGaToThetanonlin2 = sparse(KL,n_c+back);
    derGaToThetanonlin3 = sparse(KL,n_c+back);
    for i=1:n_c
        % BetaX
        firstorderderivative(:,i) = thetalin(i)*Ga(:,i).*(X - betaX(i))/(rho(type(i))^2);
        % BetaY
        firstorderderivative(:,n_c+i) = thetalin(i)*Ga(:,i).*(Y - betaY(i))/(rho(type(i))^2);
        % rho
        R2 = (X - betaX(i)).^2 + (Y - betaY(i)).^2;
        firstorderderivative(:,2*n_c + type(i)) = firstorderderivative(:,2*n_c + type(i)) + thetalin(i)*Ga(:,i).*R2/(rho(type(i)))^3;
        % eta
        firstorderderivative(:,2*n_c+l_rho+i) = Ga(:,i);

        derGaToThetanonlin1(:,i) = Ga(:,i).*(X - betaX(i))/((rho(type(i)))^2);
        derGaToThetanonlin2(:,i) = Ga(:,i).*(Y - betaY(i))/((rho(type(i)))^2);
        derGaToThetanonlin3(:,i) = Ga(:,i).*R2/(rho(type(i)))^3;

        matrix1T = derGaToThetanonlin1';
        derivativeThetalinToThetanonlin(:,i) = -invGaTGa*(matrix1T*Ga + GaT*derGaToThetanonlin1)*thetalin + invGaTGa*matrix1T*obs;
        matrix2T = derGaToThetanonlin2';
        derivativeThetalinToThetanonlin(:,n_c+i) = -invGaTGa*(matrix2T*Ga + GaT*derGaToThetanonlin2)*thetalin + invGaTGa*matrix2T*obs;
        
        derGaToThetanonlin1(:,i) = sparse(KL,1);
        derGaToThetanonlin2(:,i) = sparse(KL,1);
    end
    for j=1:l_rho
        matrix3 = sparse(KL,n_c+back);
        ind = (type')==j;
        matrix3(:,ind) = derGaToThetanonlin3(:,ind);
        matrix3T = matrix3';
        derivativeThetalinToThetanonlin(:,2*n_c + type(i)) = -invGaTGa*(matrix3T*Ga + GaT*matrix3)*thetalin + invGaTGa*matrix3T*obs;
    end
    if back
        firstorderderivative(:,end) = ones(KL,1);
    end
    firstorderder1 = firstorderderivative(:,1:2*n_c+l_rho);
    firstorderder2 = firstorderderivative(:,2*n_c+l_rho+1:3*n_c+l_rho+back);
    Jacobian = firstorderder2*derivativeThetalinToThetanonlin + firstorderder1;
end