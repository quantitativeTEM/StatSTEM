function [ind_s, K_s, L_s] = selectSectionInd(ind, box, betaX, betaY)
% selectSectionInd - select part of an image in indices
%
%   syntax: [ind_s, K_s, L_s] = selectSectionInd(ind, box, betaX, betaY)
%       ind   - the indices of the original image
%       box   - size of selected image part
%       betaX - the x-coordinates of selected column
%       betaY - the y-coordinates of selected column
%       ind_s - the selected indices of the image
%       K_s   - numer of pixel of selected image in x-direction
%       L_s   - numer of pixel of selected image in y-direction
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
ix1 = min( max( round(betaX-box) , 1 ) , size(ind,2) );
ix2 = max( min( round(betaX+box) , size(ind,2)) , 1 );
iy1 = min( max( round(betaY-box) , 1 ) , size(ind,1) );
iy2 = max( min( round(betaY+box) , size(ind,1)) , 1 );

ind_s = ind(iy1:iy2,ix1:ix2);

K_s = size(ind_s,2);    % size of the box/section around the single atom column
L_s = size(ind_s,1);

ind_s = reshape(ind_s,K_s*L_s,1);
