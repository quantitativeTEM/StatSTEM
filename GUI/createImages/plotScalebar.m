function plotScalebar(ax,dim)
% plotScalebar - add a scalebar in the current image
%
%   syntax: plotScalebar(ax,dim)
%       ax  - reference to axes
%       dim - length of the scalebar (Å)
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% First find image
data = get(ax,'Children');
val = 0;
for n=1:size(data,1)
    if isa(data(n),'matlab.graphics.primitive.Image')
        val = n;
        break
    end
end
if val==0
    return % no image
end
img = data(val);

x_axis = get(img,'XData');
y_axis = get(img,'YData');

% Put scalebar always at 3% from the edges
x = [x_axis(end)*0.97 - dim , x_axis(end)*0.97];
y = [y_axis(end)*0.97 , y_axis(end)*0.97];

% Now plot the scalebar
hold(ax,'on')
h = plot(ax,x,y,'w','LineWidth',2);
hold(ax,'off')

% Add reference to scalebar to userdata of axes
data = get(ax,'Userdata');
data = [data;{'Scalebar',h}];
set(ax,'Userdata',data)
