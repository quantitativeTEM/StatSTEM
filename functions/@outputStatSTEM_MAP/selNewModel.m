function [output,obj] = selNewModel(obj,input)
% selNewModel - Select a model from the MAP probability curve
%
%   syntax: [output,obj] = selNewModel(obj)
%       obj    - outputStatSTEM_MAP file
%       input  - inputStatSTEM file
%       output - outputStatSTEM file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2020, EMAT, University of Antwerp
% Author: K.H.W. van den Bos, J. Fatermans
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

%% Select axis
if ~isempty(obj.GUI)
    ax = obj.ax;
else
    ax = gca;
end

pos = [0.1300 0.1100 0.7750 0.8150];
set(ax,'units','normalized','Position',pos)
n = obj.NselMod;
hold off
% Upper left part: plot of raw image data, including fitted coordinates for
% selected model
subplot(2,2,1),imagesc(input.obs), colormap gray, axis equal off, title('Raw image'), hold on, ...
    plot(obj.models{n}.coordinates(:,1)/obj.dx+0.5,obj.models{n}.coordinates(:,2)/obj.dx+0.5,'r+','MarkerSize',20);
% Upper right part: plot of model fit, including fitted coordinates for
% selected model
subplot(2,2,2), imagesc(obj.models{n}.model), colormap gray, axis equal off, title('Currently selected model'), hold on,...
    plot(obj.models{n}.coordinates(:,1)/obj.dx+0.5,obj.models{n}.coordinates(:,2)/obj.dx+0.5,'r+','MarkerSize',20);
% Lower part: plot of MAP probability curve
subplot(2,2,[3 4]), plot(obj.N,obj.MAPprob,'.','MarkerSize',20,'color',[0 0 0]),xlabel('Number of atomic columns'),...
    ylabel('Relative probability (logscale)'),hold on,plot(n-1+obj.N(1),obj.MAPprob(n),'rx','MarkerSize',20),...
    xticks(obj.N);

ax = gca;
hf = gcf;
axis(ax);
hold on;

% Select new minimum
title('Select the model of interest')
if nargin<2
    hfig = showModels(obj);
else
    hfig = showModels(obj,input);
end
h_pan = pan(hf);
h_cursor = datacursormode(hf);
[x,~] = ginput_AxInFig(ax,h_pan,h_cursor,hf);
delete(hfig)
title(ax,'')
selMin = round(x);
if isempty(selMin)
    selMin = obj.N(1);
elseif selMin<obj.N(1)
    selMin = obj.N(1);
elseif selMin>obj.M
    selMin = obj.M;
end
obj.NselMod = selMin-obj.N(1)+1;

output = getSelModel(obj);

% Calculate single atom sensitivity, and store in file as a message
obj.message = ['New model selected from MAP probability curve: ',num2str(selMin),' columns'];