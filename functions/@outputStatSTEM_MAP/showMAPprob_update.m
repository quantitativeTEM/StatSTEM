function showMAPprob_update(obj,input)
% showMAPprob - Shows the maximum a posteriori (MAP) probability rule updating
% during fitting, including image and model fit with optimized coordinates
%
%   syntax: showMAPprob(obj)
%       obj - outputStatSTEM_MAP file
%       input - inputStatSTEM file

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2020, EMAT, University of Antwerp
% Author: K.H.W. van den Bos, J. Fatermans
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if nargin<1
    return
end

if ~isempty(obj.GUI)
    ax = obj.ax;
else
    ax = gca;
end

pos = [0.1300 0.1100 0.7750 0.8150];
set(ax,'units','normalized','Position',pos)
hold off
% left upper part: plot of raw image data, including fitted coordinates
subplot(2,2,1),imagesc(input.obs),colormap gray,axis equal off,title('Raw image');
if ~isempty(obj.models{end}.coordinates)
    hold on, ...
    plot(obj.models{end}.coordinates(:,1)/obj.dx+0.5,obj.models{end}.coordinates(:,2)/obj.dx+0.5,'r+','MarkerSize',20);
end
% right upper part: plot of model fit, including fitted coordinates
subplot(2,2,2),imagesc(obj.models{end}.model),colormap gray,axis equal off,title('Fitted model');
if ~isempty(obj.models{end}.coordinates)
    hold on,...
    plot(obj.models{end}.coordinates(:,1)/obj.dx+0.5,obj.models{end}.coordinates(:,2)/obj.dx+0.5,'r+','MarkerSize',20);
end
% bottom part: plot of MAP probability curve
subplot(2,2,[3 4]),plot(obj.N,obj.MAPprob,'.','MarkerSize', 20,'color', [0 0 0]),xlabel('Number of atomic columns'),...
    ylabel('Relative probability (logscale)'), xticks(obj.N);
