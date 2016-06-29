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
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

axes(ax)
val = get(ax,'Userdata');
if isempty(val)
    return
end
ind = strcmp(val(:,1),name);
if ~any(ind)
    return
end
ind = find(ind);
for i=1:length(ind)
    h_obj = val{ind(i),2};

    for n=1:length(h_obj)
        if h_obj(n)~=0
            delete(h_obj(n))
        end
    end
end
% Store reference to coordinates
val = val(~strcmp(val(:,1),name),:);
set(ax,'Userdata',val)