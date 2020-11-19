function f = criterion_lin(p,X,Y,psizex,psizey,w,sigma,N,xy,etamin)
%--------------------------------------------------------------------------
% Criterion to fit background, column width, and column intensities by linearization
% Syntax: - p: unknown parameter vector (background and width)
%         - X,Y: meshgrid of x-y dimensions (pixels)
%         - psizex, psizey: x-and y dimensions of image (pixels)
%         - w: image data
%         - sigma: sqrt(w)
%         - N: number of Gaussian peaks
%         - xy: fixed atomic column positions
%         - etamin: a priori minimum allowed column intensity
%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2020, EMAT, University of Antwerp
% Author: J. Fatermans
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

w_vec = w(:);
sigma_vec = sigma(:);
m_vec = (w_vec-p(1))./sigma_vec;
Ga = zeros(length(m_vec),N);
for ii = 1:N
    R2 = (X-xy(ii,1)).^2 + (Y-xy(ii,2)).^2;
    g = exp(-0.5*R2./p(2)^2);
    Ga(:,ii) = g(:)./sigma_vec;
end
GaT = Ga.';
GaTGa = GaT*Ga;
GaTY = GaT*m_vec;
eta = GaTGa\GaTY;
eta(eta<etamin) = etamin;
fb = zeros(psizey,psizex) + p(1);
for jj = 1:N
    R2 = (X-xy(jj,1)).^2 + (Y-xy(jj,2)).^2;
    fb = fb + eta(jj)*exp(-0.5*R2./p(2)^2);
end
f = (w - fb)./sigma;