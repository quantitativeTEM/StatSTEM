function f = criterion_MAP(p,X,Y,w,N,sigma,model_loop,rho)
%--------------------------------------------------------------------------
% Criterion to fit model with fixed background and column width to image
% Syntax: - p: unknown parameter vector (column intensities and positions)
%         - X,Y: meshgrid of x-y dimensions
%         - w: image data
%         - N: number of Gaussian peaks
%         - sigma: sqrt(w)
%         - model_loop: fitted model of previous loop iterations
%         - rho: column width (pixels)
%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2020, EMAT, University of Antwerp
% Author: J. Fatermans
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
model = model_loop;
for nn = 1:N
    R2 = (X-p(3*nn-1)).^2 + (Y-p(3*nn)).^2;
    model = model + p(3*nn-2)*exp(-0.5*R2./rho^2);
end

f = (w - model)./sigma;