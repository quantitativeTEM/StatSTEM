function f = criterion_MAP_zeta(p,psizex,psizey,w,sigma)
%--------------------------------------------------------------------------
% Criterion to fit constant background to image
% Syntax: - p: unknown parameter vector (background)
%         - psizex, psizey: x-and y dimensions of image (in pixels)
%         - w: image data
%         - sigma: sqrt(w)
%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2020, EMAT, University of Antwerp
% Author: J. Fatermans
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

model = zeros(psizey,psizex) + p(1);

f = (w - model)./sigma;