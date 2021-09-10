function Fun = criterionRho(rho,Xreshape,Yreshape,K,L,reshapeobs,betaX,betaY,fitzeta,type,indMat,dx,ind,max_n,GUI,hwaitbar,offwait,maxwait,maxIter)
% criterionRho - criterion to fit the width of gaussian peaks
%
%   Criterion is used to fit only the width of Gaussian peaks. The width is
%   the same for each atom type.
%
%   syntax: Fun = criterionRho(rho,Xreshape,Yreshape,K,L,reshapeobs,betaX,betaY,fitzeta,type,indMat,dx,ind,max_n,hwaitbar,abortbut,offwait,maxIter)
%       rho       - the width (of each atom type)
%       Xreshape - X-grid of image (1 x N array)
%       Yreshape    - Y-grid of image (1 x N array)
%       K           - the size of the observation in x-direction
%       L           - the size of the observation in y-direction
%       reshapeobs  - observation (1 x N array)
%       betaX       - the x-coordinates
%       betaY       - the y-coordinates
%       fitzeta     - boolean, indicating is background must be fitted
%       type        - the atom types per peak (1 x N array)
%       indMat      - matrix indicating the indice of each pixel
%       dx          - the pixel size
%       ind         - indices of columns to be fitted (boolean 1 x N)
%       max_n       - number to devide creation of model in parts
%       hwaitbar    - reference to waitbar (optional)
%       abortbut    - reference to abort button (optional)
%       offwait     - offset of waitbar (optional)
%       maxIter     - maximum number of iterations for waitbar (optional)
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

rho_vec = rho(type);
Ga = sparse(K*L,length(type)+fitzeta);
Ga(:,1:end-fitzeta) = getGa(K,L,indMat,rho_vec,dx,betaX,betaY,Xreshape,Yreshape,ind);
thetalin = getLinearPar(Ga,reshapeobs,K*L,fitzeta,0); % Zeta must be subtracted before running function
output = outputStatSTEM([betaX, betaY, type],rho_vec,thetalin(1:end-fitzeta),0,dx);
if nargin>=15
    output.GUI = GUI;
end
output = combinedGauss(output, K, L, ind);
model = reshape(output.model,K*L,1);
if fitzeta
    model = model+thetalin(end);
end
Fun = sum((model - reshapeobs).^2);