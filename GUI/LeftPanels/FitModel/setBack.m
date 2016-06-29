function setBack(jObject,event,h)
% setBack - Callback for storing new background value
%
%   syntax: setBack(jObject,event,h)
%       jObject - Reference to java object
%       event   - structure recording button events
%       h       - structure holding references to GUI interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

str = get(jObject,'Text');
num = str2double(str);
if isempty(str) || strcmp(str,'-')
    num = 0;
elseif isnan(num)
    num=0;
	set(jObject,'Text','0')
end
tab = loadTab(h);
if isempty(tab)
    h_mes = errordlg('First load an image');
    waitfor(h_mes)
    return
end
% Load image
usr = get(tab,'Userdata');
usr.fitOpt.model.zeta = num;
% Save background
set(tab,'Userdata',usr)