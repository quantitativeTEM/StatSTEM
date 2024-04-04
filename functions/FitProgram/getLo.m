function Lo = getLo(K, L, indMat, rho, dx, BetaX, BetaY, X, Y, ind)
% getLo - create matrix with all the Lorentzian peaks
%
%   Matrix with all the Lorentzian peaks at different columns is created for 
%   the determination of the linear parameters
%
%   syntax: Lo = getLo(K,L,Mnum,indMat,rho,dx,BetaX,BetaY,X,Y,ind)
%       K      - number of pixels in x-direction
%       L      - number of pixels in y-direction
%       indMat - matrix indicating the indice of each pixel
%       rho    - the width of the columns
%       BetaX  - the x-coordinates
%       BetaY  - the y-coordinates
%       X      - X-grid of the observation
%       Y      - Y-grid of the observation
%       ind    - indices of the columns which should be used
%       Lo     - the output matrix
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2023, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

N = length(ind);
px_p_col = ceil(((max(rho)*6))/dx)^2;
Lo = spalloc(K*L,N,px_p_col*N);
for k=1:N
    i = ind(k);
    ind_s = selectSectionInd(indMat, (rho(i)*3)/dx, BetaX(i)/dx, BetaY(i)/dx);
    R2 = (X(ind_s) - BetaX(i)).^2 + (Y(ind_s) - BetaY(i)).^2;
    Lo(ind_s,k) = (rho(i)^2+R2).^(-3/2);
end

