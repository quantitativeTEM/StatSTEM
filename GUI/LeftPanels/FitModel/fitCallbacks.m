function h = fitCallbacks(h)
% fitCallbacks - Define callback functions for fit program panel
%
%   syntax: h = fitCallbacks(h)
%       h       - structure holding references to StatSTEM interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Fit model
javaCallback(h.left.fit.panRout.runBut,'MouseEnteredCallback',{@buttonPressed,@runFitProgram,h},'MouseExitedCallback',{@buttonPressed,[]})

% Advance options
javaCallback(h.left.fit.panRout.AdvBut,'MouseEnteredCallback',{@buttonPressed,@showAdvPanel,h},'MouseExitedCallback',{@buttonPressed,[]})

% Enabling modification background value
javaCallback(h.left.fit.panels.Back.Val,'KeyReleasedCallback',{@setBack,h},'FocusLostCallback',{@updateBack,h})
javaCallback(h.left.fit.panels.Back.SelBut,'MouseEnteredCallback',{@buttonPressed,@selectBack,h},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.fit.panels.Width.SameBut,'MouseEnteredCallback',{@buttonPressed,@changeWidthType,h,1,h.left.fit.panels.Width.DiffBut,h.left.fit.panels.Width.UserBut},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.fit.panels.Width.DiffBut,'MouseEnteredCallback',{@buttonPressed,@changeWidthType,h,0,h.left.fit.panels.Width.UserBut,h.left.fit.panels.Width.SameBut},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.fit.panels.Width.UserBut,'MouseEnteredCallback',{@buttonPressed,@changeWidthType,h,2,h.left.fit.panels.Width.SameBut,h.left.fit.panels.Width.DiffBut},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.fit.panels.Back.AutBackBut,'MouseEnteredCallback',{@buttonPressed,@enableBack,h},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.fit.panels.Test.But,'MouseEnteredCallback',{@buttonPressed,@optFitting,h,'test'},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.fit.panels.Test.CoorBut,'MouseEnteredCallback',{@buttonPressed,@outputIsInput,h},'MouseExitedCallback',{@buttonPressed,[]})
javaCallback(h.left.fit.panels.Parallel.Val,'KeyReleasedCallback',{@setNumWorkFit,h},'FocusLostCallback',{@updateNumWorkFit,h})
javaCallback(h.left.fit.panels.Width.EditBut,'MouseEnteredCallback',{@buttonPressed,@editRho,h},'MouseExitedCallback',{@buttonPressed,[]})