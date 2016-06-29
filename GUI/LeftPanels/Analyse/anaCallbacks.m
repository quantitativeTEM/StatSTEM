function h = anaCallbacks(h)
% anaCallbacks - Define callback functions for analysis panel
%
%   syntax: h = anaCallbacks(h)
%       h       - structure holding references to StatSTEM interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Run ICL
javaCallback(h.left.ana.panel.atom.runBut,'MouseEnteredCallback',{@buttonPressed,@runAtomCounting,h},'MouseExitedCallback',{@buttonPressed,[]})

% Advance options
javaCallback(h.left.ana.panel.atom.AdvBut,'MouseEnteredCallback',{@buttonPressed,@showAdvAtom,h},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.ana.panel.atomAdv.maxComp,'KeyReleasedCallback',{@changeMaxCompICL,h},'FocusLostCallback',{@updateMaxCompICL,h})
javaCallback(h.left.ana.panel.atomAdv.minICL,'MouseEnteredCallback',{@buttonPressed,@newICLmin,h},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.ana.panel.atomAdv.offset,'KeyReleasedCallback',{@changeOffset,h},'FocusLostCallback',{@updateOffset,h})
javaCallback(h.left.ana.panel.atomAdv.incLib,'MouseEnteredCallback',{@buttonPressed,@loadLibrary,h},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.ana.panel.atomAdv.selCol,'MouseEnteredCallback',{@buttonPressed,@selColumnAtom,h},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.ana.panel.atomAdv.selColHist,'MouseEnteredCallback',{@buttonPressed,@selColumnHist,h},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.ana.panel.atomAdv.selColType,'MouseEnteredCallback',{@buttonPressed,@selColumnType,h},'MouseExitedCallback',{@buttonPressed,[]})

