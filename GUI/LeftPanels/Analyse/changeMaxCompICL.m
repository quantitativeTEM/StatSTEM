function changeMaxCompICL(jObject,event,h)
% changeMaxCompICL - Set the maximum number of components for atomcounting
%
% Change the maximum number of components that while be evaluated by the
% ICL for atomcounting in the StatSTEM interface
%
%   syntax: changeMaxCompICL(jObject,event,h)
%       jObject - Reference to object
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

str = get(jObject,'Text');
num = str2double(str);
if isempty(str) || strcmp(str,'-')
    num = 50;
elseif isnan(num)
    num=50;
	set(jObject,'Text','50')
elseif num<=0
    num = 50;
end
tab = loadTab(h);
if isempty(tab)
%     h_mes = errordlg('First load an image');
%     waitfor(h_mes)
    return
end
% Load image
usr = get(tab,'Userdata');
usr.fitOpt.atom.n_c = num;
% Save maximum components number
set(tab,'Userdata',usr)