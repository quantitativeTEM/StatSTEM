function [Fun, Jacobian] = criterionLorentz_userdefinedrhoSmall(thetanonlin,X,Y,rho,n_c,K,L,obs,type,back,indMat,dx,hwaitbar,abortbut)
% criterionLorentz_userdefinedrhoSmall - criterion to fit Lorentz peak with user defined width
%
%   Criterion is used to fit multiple peak locations to an image. The width
%   is user defined.
%
%   syntax: [Fun, Jacobian] = criterionLorentz_userdefinedSmall(thetanonlin,X,Y,n_c,K,L,obs,type,back,indMat,dx,hwaitbar,abortbut)
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
% rho = thetanonlin(2*n_c+1:end);
% rho_est = rho(type);
rho_est = rho;

Lo = sparse(K*L,n_c+back);
Lo(:,1:end-back) = getGa(K,L,indMat,rho_est,dx,betaX,betaY,X,Y,(1:n_c)');
% for i = 1:n_c
%     R = sqrt((X - betaX(i)).^2 + (Y - betaY(i)).^2);
%     Ga(:,i) = gaus( R , rho_est(i) );
% end
if back
    Lo(:,end) = ones(K*L,1);
end
LoT = Lo';
invLoTLo = inv(LoT*Lo);
LoTobs = LoT*obs;
thetalin = invLoTLo*LoTobs;
model = zeros(K*L,1);
for n=1:n_c+back
    model = model + Lo(:,n)*thetalin(n);
end
Fun = model - obs;

if nargout==2
    l_rho = length(rho);
    firstorderderivative = sparse(K*L,3*n_c+back);
    derivativeThetalinToThetanonlin = sparse(n_c+back,2*n_c);
    % For Jacobian
    derLoToThetanonlin1 = sparse(K*L,n_c+back);
    derLoToThetanonlin2 = sparse(K*L,n_c+back);
    for i=1:n_c
        % BetaX
        firstorderderivative(:,i) = 3*thetalin(i)*Lo(:,i).^(5/3).*(X - betaX(i));
        % BetaY
        firstorderderivative(:,n_c+i) = 3*thetalin(i)*Lo(:,i).^(5/3).*(Y - betaY(i));
        % rho
%         R = sqrt((X - betaX(i)).^2 + (Y - betaY(i)).^2);
%         firstorderderivative(:,2*n_c + type(i)) = firstorderderivative(:,2*n_c + type(i)) + thetalin(i)*Ga(:,i).*R.^2/(rho(type(i)))^3;
        % eta
        firstorderderivative(:,2*n_c+i) = Lo(:,i);

        derLoToThetanonlin1(:,i) = 3*Lo(:,i).^(5/3).*(X - betaX(i));
        derLoToThetanonlin2(:,i) = 3*Lo(:,i).^(5/3).*(Y - betaY(i));
%         derGaToThetanonlin3(:,i) = Ga(:,i).*R.^2/(rho(type(i)))^3;

        matrix1T = derLoToThetanonlin1';
        derivativeThetalinToThetanonlin(:,i) = -invLoTLo*(matrix1T*Lo + LoT*derLoToThetanonlin1)*thetalin + invLoTLo*matrix1T*obs;
        matrix2T = derLoToThetanonlin2';
        derivativeThetalinToThetanonlin(:,n_c+i) = -invLoTLo*(matrix2T*Lo + LoT*derLoToThetanonlin2)*thetalin + invLoTLo*matrix2T*obs;
        
        derLoToThetanonlin1(:,i) = sparse(K*L,1);
        derLoToThetanonlin2(:,i) = sparse(K*L,1);
    end
%     for j=1:l_rho
%         matrix3 = sparse(K*L,n_c+back);
%         ind = (type')==j;
%         matrix3(:,ind) = derGaToThetanonlin3(:,ind);
%         matrix3T = matrix3';
%         derivativeThetalinToThetanonlin(:,2*n_c + type(i)) = -invGaTGa*(matrix3T*Ga + GaT*matrix3)*thetalin + invGaTGa*matrix3T*obs;
%     end
    if back
        firstorderderivative(:,end) = ones(K*L,1);
    end
    firstorderder1 = firstorderderivative(:,1:2*n_c);
    firstorderder2 = firstorderderivative(:,2*n_c+1:3*n_c+back);
    Jacobian = firstorderder2*derivativeThetalinToThetanonlin + firstorderder1;
end