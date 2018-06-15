function obj = selectBack(obj)
% selectBack - Button callback selecting a background value in the image
%
%   syntax: selectBack(jObject,event,h)
%       jObject - Reference to button
%       event   - structure recording button events
%       h       - structure holding references to StatSTEM interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if obj.GUI==0
    figure;
    showObservation(obj);
end

%% Select axis
ax = gca;
axis(ax);
hold on;

%% Select background
% Let user select a region
title(ax,'Select region, press ESC to exit')
coor = gregion_AxInFig();
title(ax,'')
if ~isempty(coor)
    in = inpolygon(obj.X,obj.Y,coor(:,1),coor(:,2));
    obj.zeta = mean(mean(obj.obs(in)));
end