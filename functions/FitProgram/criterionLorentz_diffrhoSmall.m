function [Fun, Jacobian] = criterionLorentz_diffrhoSmall(thetanonlin,X,Y,n_c,K,L,obs,back,indMat,dx,hwaitbar,abortbut)
% criterionLorentz_diffrhoSmall - criterion to fit Lorentz peak with varying width
%
%   Criterion is used to fit multiple peak locations to an image
%
%   syntax: [Fun, Jacobian] = criterionLorentz_diffrhoSmall(thetanonlin,X,Y,n_c,K,L,obs,back,indMat,dx,hwaitbar,abortbut)
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
% Copyright: 2023, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

betaX = thetanonlin(1:n_c);
betaY = thetanonlin(n_c+1:2*n_c);
rho = thetanonlin(2*n_c+1:end);

Lo = sparse(K*L,n_c+back);
Lo(:,1:end-back) = getLo(K,L,indMat,rho,dx,betaX,betaY,X,Y,(1:n_c)');
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
    firstorderderivative = sparse(K*L,4*n_c+back);
    derivativeThetalinToThetanonlin = sparse(n_c+back,3*n_c);
    % For Jacobian
    derLoToThetanonlin1 = sparse(K*L,n_c+back);
    derLoToThetanonlin2 = sparse(K*L,n_c+back);
    derLoToThetanonlin3 = sparse(K*L,n_c+back);
    for i=1:n_c
        % BetaX
        firstorderderivative(:,i) = 3*thetalin(i)*Lo(:,i).^(5/3).*(X - betaX(i));
        % BetaY
        firstorderderivative(:,n_c+i) = 3*thetalin(i)*Lo(:,i).^(5/3).*(Y - betaY(i));
        % rho
        R2 = ((X - betaX(i)).^2 + (Y - betaY(i)).^2);
        firstorderderivative(:,2*n_c + i) = firstorderderivative(:,2*n_c + i) - 3*thetalin(i)*Lo(:,i).^(5/3).*rho(i);
        % eta
        firstorderderivative(:,3*n_c+i) = Lo(:,i);

        derLoToThetanonlin1(:,i) = 3*Lo(:,i).^(5/3).*(X - betaX(i));
        derLoToThetanonlin2(:,i) = 3*Lo(:,i).^(5/3).*(Y - betaY(i));
        derLoToThetanonlin3(:,i) = -3*Lo(:,i).^(5/3).*rho(i);

        matrix1T = derLoToThetanonlin1';
        derivativeThetalinToThetanonlin(:,i) = -invLoTLo*(matrix1T*Lo + LoT*derLoToThetanonlin1)*thetalin + invLoTLo*matrix1T*obs;
        matrix2T = derLoToThetanonlin2';
        derivativeThetalinToThetanonlin(:,n_c+i) = -invLoTLo*(matrix2T*Lo + LoT*derLoToThetanonlin2)*thetalin + invLoTLo*matrix2T*obs;
        matrix3T = derLoToThetanonlin3';
        derivativeThetalinToThetanonlin(:,2*n_c+i) = -invLoTLo*(matrix3T*Lo + LoT*derLoToThetanonlin3)*thetalin + invLoTLo*matrix3T*obs;
        
        derLoToThetanonlin1(:,i) = sparse(K*L,1);
        derLoToThetanonlin2(:,i) = sparse(K*L,1);
        derLoToThetanonlin3(:,i) = sparse(K*L,1);
    end
    if back
        firstorderderivative(:,end) = ones(K*L,1);
    end
    firstorderder1 = firstorderderivative(:,1:3*n_c);
    firstorderder2 = firstorderderivative(:,3*n_c+1:4*n_c+back);
    Jacobian = firstorderder2*derivativeThetalinToThetanonlin + firstorderder1;
end