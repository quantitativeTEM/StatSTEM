function [Fun, Jacobian] = criterionLorentz_samerhoSmall(thetanonlin,X,Y,n_c,K,L,obs,type,back,indMat,dx,hwaitbar,abortbut)
% criterionLorentz_samerhoSmall - criterion to fit Lorentzian peak with same width
%
%   Criterion is used to fit multiple peak locations to an image. The width
%   is kept constant for atoms having the same type.
%
%   syntax: [Fun, Jacobian] = criterionLorentzian_samerhoSmall(thetanonlin,X,Y,n_c,K,L,obs,type,back,indMat,dx,hwaitbar,abortbut)
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
% Copyright: 2023, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
betaX = thetanonlin(1:n_c);
betaY = thetanonlin(n_c+1:2*n_c);
rho = thetanonlin(2*n_c+1:end);
rho_est = rho(type);
KL = K*L;
Lo = sparse(KL,n_c+back);
Lo(:,1:end-back) = getLo(K,L,indMat,rho_est,dx,betaX,betaY,X,Y,(1:n_c)');
if back
    Lo(:,end) = ones(KL,1);
end
nonzerosLo = nnz(Lo);
LoT = Lo';
invLoTLo = inv(LoT*Lo);
% LoTLo = (LoT*Lo);
LoTobs = LoT*obs;
% thetalin = LoTLo\LoTobs;
thetalin = invLoTLo*LoTobs;
model = zeros(KL,1);
for n=1:n_c+back
    model = model + Lo(:,n)*thetalin(n);
end
Fun = model - obs;
if nargout==2
    l_rho = length(rho);
    firstorderderivative = spalloc(KL,3*n_c+l_rho+back, 3*nonzerosLo);
    derivativeThetalinToThetanonlin = zeros(n_c+back,2*n_c+l_rho);
    % For Jacobian
    derLoToThetanonlin1 = spalloc(KL,n_c+back,nonzerosLo);
    derLoToThetanonlin2 = spalloc(KL,n_c+back,nonzerosLo);
    derLoToThetanonlin3 = spalloc(KL,n_c+back,nonzerosLo);
    for i=1:n_c

        % BetaX
        firstorderderivative(:,i) = 3*thetalin(i)*Lo(:,i).^(5/3).*(X - betaX(i));
        % BetaY
        firstorderderivative(:,n_c+i) = 3*thetalin(i)*Lo(:,i).^(5/3).*(Y - betaY(i));
        % rho
        R2 = (X - betaX(i)).^2 + (Y - betaY(i)).^2;
        firstorderderivative(:,2*n_c + type(i)) = firstorderderivative(:,2*n_c + type(i)) - 3*thetalin(i)*Lo(:,i).^(5/3).*rho(type(i));
        % eta
        firstorderderivative(:,2*n_c+l_rho+i) = Lo(:,i);
  
        derLoToThetanonlin1(:,i) = 3*Lo(:,i).^(5/3).*(X - betaX(i));
        derLoToThetanonlin2(:,i) = 3*Lo(:,i).^(5/3).*(Y - betaY(i));
        derLoToThetanonlin3(:,i) = -3*Lo(:,i).^(5/3).*rho(type(i));

        matrix1T = derLoToThetanonlin1';
        % derivativeThetalinToThetanonlin(:,i) = -LoTLo\(matrix1T*Lo + LoT*derLoToThetanonlin1)*thetalin + LoTLo\matrix1T*obs;
        derivativeThetalinToThetanonlin(:,i) = -invLoTLo*(matrix1T*Lo + LoT*derLoToThetanonlin1)*thetalin + invLoTLo*matrix1T*obs;

        matrix2T = derLoToThetanonlin2';
        % derivativeThetalinToThetanonlin(:,n_c+i) = -LoTLo\(matrix2T*Lo + LoT*derLoToThetanonlin2)*thetalin + LoTLo\matrix2T*obs;
        derivativeThetalinToThetanonlin(:,n_c+i) = -invLoTLo*(matrix2T*Lo + LoT*derLoToThetanonlin2)*thetalin + invLoTLo*matrix2T*obs;
        
        derLoToThetanonlin1(:,i) = sparse(KL,1);
        derLoToThetanonlin2(:,i) = sparse(KL,1);

    end
    for j=1:l_rho
        matrix3 = sparse(KL,n_c+back);
        ind = (type')==j;
        matrix3(:,ind) = derLoToThetanonlin3(:,ind);
        matrix3T = matrix3';
        % derivativeThetalinToThetanonlin(:,2*n_c + type(i)) = -LoTLo\(matrix3T*Lo + LoT*matrix3)*thetalin + LoTLo\matrix3T*obs;
        derivativeThetalinToThetanonlin(:,2*n_c + type(i)) = -invLoTLo*(matrix3T*Lo + LoT*matrix3)*thetalin + invLoTLo*matrix3T*obs;

    end
    if back
        firstorderderivative(:,end) = ones(KL,1);
    end
    firstorderder1 = firstorderderivative(:,1:2*n_c+l_rho);
    firstorderder2 = firstorderderivative(:,2*n_c+l_rho+1:3*n_c+l_rho+back);
    Jacobian = firstorderder2*derivativeThetalinToThetanonlin + firstorderder1;
end