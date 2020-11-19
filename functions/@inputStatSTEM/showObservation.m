function showObservation(obj)
% showObservation - Show the observation
%
%   syntax: showObservation(obj)
%       obj - inputStatSTEM object
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

x_axis = ((1:size(obj.obs,2))-0.5)*obj.dx;
y_axis = ((1:size(obj.obs,1))-0.5)*obj.dx;

% Show observation
imagesc(x_axis,y_axis,obj.obs);axis equal off;colormap gray
axis([x_axis(1),x_axis(end),y_axis(1),y_axis(end)]) % Set limits
    