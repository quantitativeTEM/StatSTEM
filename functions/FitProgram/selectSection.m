function [obs_s, X_s, Y_s,K_s, L_s] = selectSection(obs, X, Y, box, betaX, betaY)
% selectSection - select part of an image
%
%   syntax: [obs_s, X_s, Y_s,K_s, L_s] = selectSection(obs, X, Y, box, betaX, betaY)
%       obs   - the observation (image)
%       X     - X-grid
%       Y     - Y-grid
%       box   - size of selected image part
%       betaX - the x-coordinates of selected column
%       betaY - the y-coordinates of selected column
%       obs_s - the selected part of the image
%       X_s   - X-grid of the selected part of the image
%       Y_s   - Y-grid of the selected part of the image
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
if round(betaX-box) < 1
    if round(betaY-box) < 1 && round(betaX+box)>size(obs,2) && round(betaY+box)>size(obs,1)
        obs_s = obs;
        X_s = X;
        Y_s = Y;
    elseif round(betaY-box) < 1
        obs_s = obs(1:round(betaY+box),1:round(betaX+box));
        X_s = X(1:round(betaY+box),1:round(betaX+box));
        Y_s = Y(1:round(betaY+box),1:round(betaX+box));
    elseif round(betaY+box) > size(obs,1)
        obs_s = obs(round(betaY-box):end,1:round(betaX+box));
        X_s = X(round(betaY-box):end,1:round(betaX+box));
        Y_s = Y(round(betaY-box):end,1:round(betaX+box));
    else
        obs_s = obs(round(betaY-box):round(betaY+box),1:round(betaX+box));
        X_s = X(round(betaY-box):round(betaY+box),1:round(betaX+box));
        Y_s = Y(round(betaY-box):round(betaY+box),1:round(betaX+box));
    end
elseif round(betaX+box) > size(obs,2)
    if round(betaY-box) < 1
        obs_s = obs(1:round(betaY+box),round(betaX-box):end);
        X_s = X(1:round(betaY+box),round(betaX-box):end);
        Y_s = Y(1:round(betaY+box),round(betaX-box):end);
    elseif round(betaY+box) > size(obs,1)
        obs_s = obs(round(betaY-box):end,round(betaX-box):end);
        X_s = X(round(betaY-box):end,round(betaX-box):end);
        Y_s = Y(round(betaY-box):end,round(betaX-box):end);
    else
        obs_s = obs(round(betaY-box):round(betaY+box),round(betaX-box):end);
        X_s = X(round(betaY-box):round(betaY+box),round(betaX-box):end);
        Y_s = Y(round(betaY-box):round(betaY+box),round(betaX-box):end);
    end
elseif round(betaY-box) < 1
    obs_s = obs(1:round(betaY+box),round(betaX-box):round(betaX+box));
    X_s = X(1:round(betaY+box),round(betaX-box):round(betaX+box));
    Y_s = Y(1:round(betaY+box),round(betaX-box):round(betaX+box));
elseif round(betaY+box) > size(obs,1)
    obs_s = obs(round(betaY-box):end,round(betaX-box):round(betaX+box));
    X_s = X(round(betaY-box):end,round(betaX-box):round(betaX+box));
    Y_s = Y(round(betaY-box):end,round(betaX-box):round(betaX+box));
else
    obs_s = obs(round(betaY-box):round(betaY+box),round(betaX-box):round(betaX+box));
    X_s = X(round(betaY-box):round(betaY+box),round(betaX-box):round(betaX+box));
    Y_s = Y(round(betaY-box):round(betaY+box),round(betaX-box):round(betaX+box));
end

K_s = size(obs_s,2);    % size of the box/section around the single atom column
L_s = size(obs_s,1);

