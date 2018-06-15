function showAdvPanel(jObject,event,panel)
% showAdvPanel - Show or hide panel with advanced options
%
%   syntax: showAdvPanel(jObject,event,panel)
%       jObject  - Reference to button
%       event    - structure recording button events
%       panel    - structure containing references to panels
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Check value of button
val = jObject.isSelected;

% Set border
head = any(strcmp(fieldnames(panel),'header')); % is header present
set(panel.panel,'Border',javax.swing.border.MatteBorder(~head,1,~val,1,java.awt.Color(0.3,0.3,0.3)))
dim = panel.panel.getSize;
width = dim.getWidth;
height = dim.getHeight;
if val
    height = height - 1;
else
    height = height + 1;
end
dim = java.awt.Dimension(width,height);
panel.panel.setSize(dim);
panel.panel.setMaximumSize(dim);
panel.panel.setPreferredSize(dim);

% Show or hide advanced panels
N = sum(strncmp(fieldnames(panel.advanced),'panel',5));
for n=1:N
    panel.advanced.(['panel',num2str(n)]).panel.setVisible(val);
end
