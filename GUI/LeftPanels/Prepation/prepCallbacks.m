function h = prepCallbacks(h)
% prepCallbacks - Define preparation panel callback functions
%
%   syntax: h = prepCallbacks(h)
%       h       - structure holding references to StatSTEM interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Add remove peaks
javaCallback(h.left.peak.panels.addRem.addBut,'MouseEnteredCallback',{@buttonPressed,@addPeaks,h},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.peak.panels.addRem.remBut,'MouseEnteredCallback',{@buttonPressed,@removePeaks,h},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.peak.panels.addRem.remAllBut,'MouseEnteredCallback',{@buttonPressed,@removeAllPeaks,h},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.peak.panels.addRem.selRegBut,'MouseEnteredCallback',{@buttonPressed,@keepPeaks,h},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.peak.panels.addRem.remRegBut,'MouseEnteredCallback',{@buttonPressed,@deletePeaks,h},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.peak.panels.addRem.changeBut,'MouseEnteredCallback',{@buttonPressed,@changePeaks,h},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.peak.panels.addRem.addType,'PopupMenuWillBecomeInvisibleCallback',{@numberATypes,h,h.left.peak.panels.addRem.changeType});
javaCallback(h.left.peak.panels.addRem.changeType,'PopupMenuWillBecomeInvisibleCallback',{@numberATypes,h,h.left.peak.panels.addRem.addType});

% Peak finder routine
javaCallback(h.left.peak.panels.pfr.RunBut,'MouseEnteredCallback',{@buttonPressed,@RunPeakFinder,h},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.peak.panels.pfr.TuneBut,'MouseEnteredCallback',{@buttonPressed,@tuneParPeakFinding,h},'MouseExitedCallback',{@buttonPressed,[]})

% Import coordinates
javaCallback(h.left.peak.panels.import.But,'MouseEnteredCallback',{@buttonPressed,@importPeaks,h},'MouseExitedCallback',{@buttonPressed,[]})

% Image parameters
javaCallback(h.left.peak.panels.pixel.Val,'KeyReleasedCallback',{@changeDX,h},'FocusLostCallback',{@updateDX,h})

