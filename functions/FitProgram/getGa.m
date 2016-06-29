function Ga = getGa(K,L,Mnum,indMat,rho,dx,BetaX,BetaY,X,Y,ind)
% getGa - create matrix with all the gaussian peaks
%
%   Matrix with all the gaussian peaks at different columns is created for 
%   the determination of the linear parameters
%
%   syntax: Ga = getGa(K,L,Mnum,indMat,rho,dx,BetaX,BetaY,X,Y,ind)
%       K      - number of pixels in x-direction
%       L      - number of pixels in y-direction
%       Mnum   - number for speeding up matrix generation
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

num = length(ind);
Ga = sparse(K*L,num);
% Now devide num by maximum number and compute Ga in steps
N = floor(num/Mnum)+1;
for k=1:N
    if k==N
        M = mod(num,Mnum);
    else
        M = Mnum;
    end
    GaInt = sparse(K*L,M);
    for n = 1:M
        i = ind(n+(k-1)*Mnum);
        ind_s = selectSectionInd(indMat, rho(i)/dx*3,BetaX(i)/dx, BetaY(i)/dx);
        R = sqrt( ( X(ind_s) - BetaX(i) ).^2 + (Y(ind_s) - BetaY(i)).^2);
        GaInt(ind_s,n) = exp(-R.^2/(2*rho(i)^2));
    end
    Ga(:,(k-1)*Mnum+1:(k-1)*Mnum+M) = GaInt;
end