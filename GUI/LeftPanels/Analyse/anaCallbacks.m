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
javaCallback(h.left.ana.panel.atomAdv.offset,'KeyReleasedCallback',{@changeFocusTextField,h.left.ana.panel.atomAdv.offsetText},'FocusLostCallback',{@updateOffset,h})
javaCallback(h.left.ana.panel.atomAdv.selCol,'MouseEnteredCallback',{@buttonPressed,@selColumnAtom,h},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.ana.panel.atomAdv.selColHist,'MouseEnteredCallback',{@buttonPressed,@selColumnHist,h},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.ana.panel.atomAdv.selColType,'MouseEnteredCallback',{@buttonPressed,@selColumnType,h},'MouseExitedCallback',{@buttonPressed,[]})

% Match with simulations
javaCallback(h.left.ana.panel.acl.incLib,'MouseEnteredCallback',{@buttonPressed,@loadLibrary,h},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.ana.panel.acl.matchSCS,'MouseEnteredCallback',{@buttonPressed,@matchLib,h},'MouseExitedCallback',{@buttonPressed,[]})

% Strain mapping
javaCallback(h.left.ana.panel.strain.optBut,'MouseEnteredCallback',{@buttonPressed,@showAdvStrain,h},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.ana.panel.strain.loadPUC,'MouseEnteredCallback',{@buttonPressed,@loadPUC,h},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.ana.panel.strainAdv.selType,'PopupMenuWillBecomeVisibleCallback',{@selNewRefType,h});
javaCallback(h.left.ana.panel.strainAdv.showCen,'MouseEnteredCallback',{@buttonPressed,@cenCoorGUI,h},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.ana.panel.strainAdv.selectCoor,'MouseEnteredCallback',{@buttonPressed,@usrCoorGUI,h},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.ana.panel.strainAdv.usrCoor,'MouseEnteredCallback',{@buttonPressed,@changeRefCoor,h,h.left.ana.panel.strainAdv.cenCoor},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.ana.panel.strainAdv.cenCoor,'MouseEnteredCallback',{@buttonPressed,@changeRefCoor,h,h.left.ana.panel.strainAdv.usrCoor},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.ana.panel.strain.makeDisp,'MouseEnteredCallback',{@buttonPressed,@makeDisplacementMap,h},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.ana.panel.strain.strainBut,'MouseEnteredCallback',{@buttonPressed,@makeStrainMap,h},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.ana.panel.strainAdv.autALat,'MouseEnteredCallback',{@buttonPressed,@changeALat,h,h.left.ana.panel.strainAdv.usrALat},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.ana.panel.strainAdv.usrALat,'MouseEnteredCallback',{@buttonPressed,@changeALat,h,h.left.ana.panel.strainAdv.autALat},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.ana.panel.strainAdv.showALatAut,'MouseEnteredCallback',{@buttonPressed,@findALatAutomatic,h},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.ana.panel.strainAdv.selectALat,'MouseEnteredCallback',{@buttonPressed,@selectALat,h},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.ana.panel.strainAdv.impFitABut,'MouseEnteredCallback',{@buttonPressed,@enableUC,h},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.ana.panel.strainAdv.impFitNUC,'KeyReleasedCallback',{@changeFocusTextField,h.left.ana.panel.strainAdv.impFitNUCText},'FocusLostCallback',{@updateNumUC})
javaCallback(h.left.ana.panel.strainAdv.impFitParAll,'MouseEnteredCallback',{@buttonPressed,@changeAPar,h,h.left.ana.panel.strainAdv.impFitParTeta},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.ana.panel.strainAdv.impFitParTeta,'MouseEnteredCallback',{@buttonPressed,@changeAPar,h,h.left.ana.panel.strainAdv.impFitParAll},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.ana.panel.strainAdv.selCol,'MouseEnteredCallback',{@buttonPressed,@selColumnStrain,h},'MouseExitedCallback',{@buttonPressed,[]})








