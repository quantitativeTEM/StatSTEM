function combined_model = combinedGauss(betaX, betaY, rho, eta,X,Y,indMat,dx,K,L,Mnum)
% combinedGauss - create a model of superpositioned gaussian peaks
%
%   syntax: combined_model = combinedGauss(betaX, betaY, rho, eta,X,Y,indMat,dx,K,L,Mnum)
%       betaX          - the x-coordinates
%       betaY          - the y-coordinates
%       rho            - the width of each coordinate
%       eta            - the height of each coordinate
%       X              - X-grid of the observation
%       Y              - Y-grid of the observation
%       indMat         - matrix indicating the indice of each pixel
%       dx             - the pixel size
%       K              - the size of the observation in x-direction
%       L              - the size of the observation in y-direction
%       Mnum           - number off for loops used for constructing the model
%       combined_model - the model
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

N = floor(length(betaX)/Mnum)+1;
combined_model = sparse(L*K,1);
for k=1:N
    if k==N
        M = mod(length(betaX),Mnum);
    else
        M = Mnum;
    end
    com_model_int = sparse(L*K,M);
    for n = 1:M
        i = n+(k-1)*Mnum;
        ind_s = selectSectionInd(indMat, rho(i)/dx*3,betaX(i)/dx, betaY(i)/dx);
        R = sqrt( ( X(ind_s) - betaX(i) ).^2 + (Y(ind_s) - betaY(i)).^2);
        com_model_int(ind_s,n) = eta(i)*exp(-R.^2/(2*rho(i)^2));
    end
    combined_model = combined_model + sum(com_model_int,2);
end