function output = combinedGauss(output, K, L, ind)
% combinedGauss - create a model of superpositioned gaussian peaks
%
%   syntax: model = combinedGauss(output, K, L, ind)
%       output - outputStatSTEM structure
%       K      - the size of the image in x-direction
%       L      - the size of the image in y-direction
%       ind    - logical vector indicating which column should be included
%       model  - Image of the Gaussian model
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2020, EMAT, University of Antwerp
% Author: A. De Backer, K.H.W. van den Bos, J. Fatermans
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
if isempty(output.coordinates)
    betaX = [];
    betaY = [];
else
    if nargin>=4
        betaX = output.coordinates(ind,1);
        betaY = output.coordinates(ind,2);
        rho = output.rho(ind);
        eta = output.eta(ind);
    else
        betaX = output.coordinates(:,1);
        betaY = output.coordinates(:,2);
        rho = output.rho;
        if length(rho)==1
            rho = ones(length(betaX),1)*rho;
        end
        eta = output.eta;
    end
end
indM = reshape((1:K*L)',L,K);
X = repmat(((1:K)-0.5)*output.dx,L,1);
Y = repmat(((1:L)-0.5)'*output.dx,1,K);

N = length(betaX);
model = zeros(L,K)+output.zeta;
for i=1:N
    ind_s = selectSectionInd(indM, rho(i)/output.dx*3, betaX(i)/output.dx+0.5, betaY(i)/output.dx+0.5);
    R = sqrt( ( X(ind_s) - betaX(i) ).^2 + (Y(ind_s) - betaY(i)).^2);
    model(ind_s) = model(ind_s) + eta(i)*exp(-R.^2/(2*rho(i)^2));
end
output.pModel = model;