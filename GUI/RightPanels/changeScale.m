function changeScale(hObject,event,ref)
% changeScale - Callback for changing the scalebar size
%
%   syntax: changeScale(hObject,event,ref)
%       hObject - Reference to object
%       event   - structure recording button events
%       ref     - reference to selected tab
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------



% Check if value is correct
str = get(hObject,'String');
num = str2double(str);
if isempty(str) || strcmp(str,'-')
    error = 1;
elseif isnan(num)
    error = 1;
elseif num<0 || abs(num)~=num
    error = 1;
else
    error = 0;
end

% Find reference to tab and the userdata
tab = get(ref,'SelectedTab');
usr = get(tab,'Userdata');

% If the number is incorrect, cancel operation
if error
    set(hObject,'String',usr.oldScalebar);
    h_error = errordlg('Error: Please insert a positive number');
    waitfor(h_error)
    return
end

% Check if an image is shown
imgShown = 0;
if isfield(usr,'images') && isfield(usr.images,'ax')
    chld = get(usr.images.ax,'Children');
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
    if any(indImg)
    	imgShown = 1;
    end
end
if imgShown==0
    return
end

% Update marker size in all files
fNNew = fieldnames(usr.file);
for n=1:length(fNNew)
    usr.file.(fNNew{n}).mscale = num;
end

% Find reference to tab and the userdata
ind = strcmp(get(chld,'Tag'),'Scalebar') & ~indImg;
if any(ind)
    % Update scalebar
    plotScalebar(usr.images.ax,num);
    delete(chld(ind))
end

% Update userdata
set(tab,'Userdata',usr)