function deleteImageObject(ax,name)
% deleteImageObject - delete objects from the shown image
%
%   syntax: deleteImageObject(ax,name)
%       ax   - handle to axes
%       name - name of object
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

axes(ax)
chld = get(ax,'Children');
if isempty(chld)
    return
end
indImg = false(length(chld),1);
v = version('-release');
v = str2double(v(1:4));
for i=1:length(chld)
    if v<2015 && strcmp(get(chld(i),'Type'),'image')
        indImg(i) = true;
    elseif isa(chld(i),'matlab.graphics.primitive.Image')
        indImg(i) = true;
    end
end
tagNames = get(chld,'Tag');
ind = strcmp(tagNames,name) & ~indImg;
if ~any(ind)
    % Check matlab version
    v = version('-release');
    v = str2double(v(1:4));
    if v<2015
        for i=1:length(tagNames)
            if length(tagNames{i})>1
                tagName = tagNames{i};
                ind(i) = strcmp(tagName(2:end),name(2:end)) & ~indImg(i);
            end
        end
        if ~any(ind)
            return
        end
    else
        return
    end
end
delete(chld(ind))