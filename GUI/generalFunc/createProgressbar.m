function [hPb, hContainer] = createProgressbar(parent,position)
% createProgressbar - Create a java progressbar
%
%   syntax: [hPb, hContainer] = createProgressbar(parent,position)
%       parent     - Reference panel or figure to hold the progressbar
%       position   - Position of the progressbar (normalized units)
%       hPb        - java handle to progressbar
%       hContainer - matlab handle to progressbar
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------


jPb = javax.swing.JProgressBar;
jPb.setStringPainted(1);jPb.setIndeterminate(0)
jPb.setValue(100)
% 
% Note: use the default 'StringPainted'=0 for block-style progress,
% and 'StringPainted'=1 for continuous style.
[hPb, hContainer] = javacomponent(jPb,position,parent);
set(hContainer,'units','normalized','Position',position)