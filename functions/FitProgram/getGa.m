function Ga = getGa(K, L, indMat, rho, dx, BetaX, BetaY, X, Y, ind)
% getGa - create matrix with all the gaussian peaks
%
%   Matrix with all the gaussian peaks at different columns is created for 
%   the determination of the linear parameters
%
%   syntax: Ga = getGa(K,L,Mnum,indMat,rho,dx,BetaX,BetaY,X,Y,ind)
%       K      - number of pixels in x-direction
%       L      - number of pixels in y-direction
%       indMat - matrix indicating the indice of each pixel
%       rho    - the width of the columns
%       BetaX  - the x-coordinates
%       BetaY  - the y-coordinates
%       X      - X-grid of the observation
%       Y      - Y-grid of the observation
%       ind    - indices of the columns which should be used
%       Ga     - the output matrix
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

N = length(ind);
px_p_col = ceil(((max(rho)*6))/dx)^2;
Ga = spalloc(K*L,N,px_p_col*N);
for k=1:N
    i = ind(k);
    ind_s = selectSectionInd(indMat, (rho(i)*3)/dx, BetaX(i)/dx, BetaY(i)/dx);
    R2 = (X(ind_s) - BetaX(i)).^2 + (Y(ind_s) - BetaY(i)).^2;
    Ga(ind_s,k) = exp(-R2/(2*rho(i)^2));
end

