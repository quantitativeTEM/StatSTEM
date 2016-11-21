function updateNumUC(jObject,event)
% updateNumUC - Check if number is correct 
%
% Check whether the input value is a positive, real integer
%
%   syntax: updateNumUC(jObject,event,h)
%       jObject - Reference to object
%       event   - structure recording button events
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if ~jObject.isEnabled
    return
end

str = get(jObject,'Text');
num = str2double(str);
if isempty(str) || strcmp(str,'-')
    error = 1;
elseif isnan(num)
    error = 1;
elseif num<0
    error = 1;
else
    error = 0;
end

if error
    set(jObject,'Text','3');
    h_error = errordlg('Error: Please insert a positive number');
    waitfor(h_error)
    return
end