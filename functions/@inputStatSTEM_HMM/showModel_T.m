function showModel_T(obj)
% showModel_T - Show the fitted model in the StatSTEM interface
%
%   syntax: showModel_T(obj,t)
%       obj   - inputStatSTEM object
%       t - frame number
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if isempty(obj.model_T)
    return
end

T = size(obj.model_T,3);
x_axis = (1:size(obj.model_T,2))*obj.dx;
y_axis = (1:size(obj.model_T,1))*obj.dx;

tab = obj.ax.Parent.Parent.Parent;
usr = get(tab,'Userdata');
pan = obj.ax.Parent;
imT = imagesc(x_axis,y_axis,obj.model_T(:,:,1));
axis equal;
axis off;
colormap gray
axis([x_axis(1),x_axis(end),y_axis(1),y_axis(end)]) % Set limits
caxis([min(min(obj.obs_T(:))),max(max(obj.obs_T(:)))])

htext = 0.025;
wtext = 0.05;
hslider = 0.025;
wslider = 0.2;
posText = [0.5-wtext/2 0.1 wtext htext];
posSlider = [posText(1)+wtext/2-wslider/2 posText(2)-htext*2 wslider hslider];
TextT = uicontrol('Parent',pan,'style','text',...
    'units','normalized','position',posText);
SliderT = uicontrol('Parent',pan,'style','slider','units','normalized','position',posSlider,...
    'min', 1, 'max', T,'Value',1);
addlistener(SliderT, 'Value', 'PostSet', @callbackfn);
    function callbackfn(source,eventdata)
        t = round(get(eventdata.AffectedObject, 'Value'));
        
        % Show observation
        imT.CData = obj.model_T(:,:,t);
        axis equal;
        axis off;
        colormap gray
        axis([x_axis(1),x_axis(end),y_axis(1),y_axis(end)]) % Set limits
        caxis([min(min(obj.model_T(:,:,t))),max(max(obj.model_T(:,:,t)))])
        
        TextT.String = num2str(t);
    end
end
