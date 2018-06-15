function [output,obj] = selNewModel(obj,input)
% selNewModel - Select an new model from MAP probability curve
%
%   syntax: [output,obj] = selNewModel(obj)
%       obj    - outputStatSTEM_MAP file
%       input  - inputStatSTEM file
%       output - outputStatSTEM file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos, J. Fatermans
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

%% Select axis
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