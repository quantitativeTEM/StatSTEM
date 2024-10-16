function showModel(obj,input)
% showModel - Show the fitted model in the StatSTEM interface
%
%   syntax: showModel(obj)
%       obj   - outputStatSTEM object
%       input - inputStatSTEM object (optional)
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if isempty(obj.model)
    return
end

x_axis = ((1:size(obj.model,2))-0.5)*obj.dx;
y_axis = ((1:size(obj.model,1))-0.5)*obj.dx;

% Show observation
imagesc(x_axis,y_axis,obj.model);axis equal off;colormap gray
axis([x_axis(1),x_axis(end),y_axis(1),y_axis(end)]) % Set limits

if nargin>1
    caxis([min(min(input.obs)),max(max(input.obs))])
end
