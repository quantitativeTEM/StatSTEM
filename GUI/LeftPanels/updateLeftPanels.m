function updateLeftPanels(h,file,fitOpt)
% updateLeftPanels - Update fields and buttons in the left panels
%
%   syntax: updateLeftPanels(h,file,fitOpt)
%       h      - reference to all GUI objects
%       file   - Structure containing the file information
%       fitOpt - Structure containing the fit options
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Check matlab version, and switch opengl
v = version('-release');
v = str2double(v(1:4));


hfUS = get(h.fig,'Userdata');
if ~isempty(hfUS)
    if isfield(hfUS,'fitting')
        if hfUS.fitting
            file = [];
        end
    end
end

if isempty(file)
    % Preparation panel
    h.left.peak.panels.addRem.addType.setEnabled(false)
    h.left.peak.panels.addRem.addBut.setEnabled(false)
    h.left.peak.panels.addRem.changeType.setEnabled(false)
    h.left.peak.panels.pfr.RunBut.setEnabled(false)
    h.left.peak.panels.pfr.TuneBut.setEnabled(false)
    h.left.peak.panels.import.But.setEnabled(false)
    h.left.peak.panels.pixel.Val.setEnabled(false)
    set(h.left.peak.panels.pixel.Val,'Text','')
    
    % Fit model panel
    h.left.fit.panels.Back.AutBackBut.setEnabled(false)
    h.left.fit.panels.Width.DiffBut.setEnabled(false)
    h.left.fit.panels.Width.SameBut.setEnabled(false)
    h.left.fit.panels.Width.UserBut.setEnabled(false)
    h.left.fit.panels.Width.EditBut.setEnabled(false)
    h.left.fit.panels.Test.But.setEnabled(false)
    h.left.fit.panels.Parallel.Val.setEnabled(false)
    
    % Analysis panel
    h.left.ana.panel.acl.incLib.setEnabled(false)
    h.left.ana.panel.strain.loadPUC.setEnabled(false)
    
    file.input.coordinates = [];
    file.input.types = {'1'};
else
    % Preparation panel
    h.left.peak.panels.addRem.addType.setEnabled(true)
    h.left.peak.panels.addRem.addBut.setEnabled(true)
    h.left.peak.panels.addRem.changeType.setEnabled(true)
    h.left.peak.panels.pfr.RunBut.setEnabled(true)
    h.left.peak.panels.pfr.TuneBut.setEnabled(true)
    h.left.peak.panels.import.But.setEnabled(true)
    h.left.peak.panels.pixel.Val.setEnabled(true)
    
    % Fit model panel
    h.left.fit.panels.Back.AutBackBut.setEnabled(true)
    h.left.fit.panels.Width.DiffBut.setEnabled(true)
    h.left.fit.panels.Width.SameBut.setEnabled(true)
    h.left.fit.panels.Width.UserBut.setEnabled(true)
    h.left.fit.panels.Width.EditBut.setEnabled(true)
    h.left.fit.panels.Test.But.setEnabled(true)
%     h.left.fit.panels.Parallel.Val.setEnabled(true)
    
    % Analysis panel
    h.left.ana.panel.acl.incLib.setEnabled(true)
    h.left.ana.panel.strain.loadPUC.setEnabled(true)
end

%% Preparation panel
% Update the number of atom types, if necessary
str1 = [file.input.types;{'Add';'Remove';'Names'}];
num = get(h.left.peak.panels.addRem.addType,'ItemCount');
if length(str1)~=num
    h.left.peak.panels.addRem.addType.setModel(javax.swing.DefaultComboBoxModel(str1))
    h.left.peak.panels.addRem.changeType.setModel(javax.swing.DefaultComboBoxModel(str1))
    h.left.ana.panel.strainAdv.selType.setModel(javax.swing.DefaultComboBoxModel(str1(1:end-3)))
else
    str2 = cell(num,1);
    for n=1:num
        str2{n,1} = h.left.peak.panels.addRem.addType.getItemAt(n-1);
    end
    if any(~strcmp(str1,str2))
        h.left.peak.panels.addRem.addType.setModel(javax.swing.DefaultComboBoxModel(str1))
        h.left.peak.panels.addRem.changeType.setModel(javax.swing.DefaultComboBoxModel(str1))
        h.left.ana.panel.strainAdv.selType.setModel(javax.swing.DefaultComboBoxModel(str1(1:end-3)))
    end
end

% Update other preparation parts
if ~isempty(file.input.coordinates)
    h.left.peak.panels.addRem.remBut.setEnabled(true)
    h.left.peak.panels.addRem.remAllBut.setEnabled(true)
    h.left.peak.panels.addRem.selRegBut.setEnabled(true)
    h.left.peak.panels.addRem.remRegBut.setEnabled(true)
    h.left.peak.panels.addRem.changeBut.setEnabled(true)
else
    h.left.peak.panels.addRem.remBut.setEnabled(false)
    h.left.peak.panels.addRem.remAllBut.setEnabled(false)
    h.left.peak.panels.addRem.selRegBut.setEnabled(false)
    h.left.peak.panels.addRem.remRegBut.setEnabled(false)
    h.left.peak.panels.addRem.changeBut.setEnabled(false)
end
if any(strcmp(fieldnames(file.input),'dx'))
    set(h.left.peak.panels.pixel.Val,'Text',num2str(file.input.dx))
else
    set(h.left.peak.panels.pixel.Val,'Text','')
end


%% Fit model panel
if ~isempty(file.input.coordinates)
    h.left.fit.panRout.runBut.setEnabled(true)
else
    h.left.fit.panRout.runBut.setEnabled(false)
end


if v<2015
    warning('off','all')
    % Back
    if fitOpt.model.fitzeta
        state = 'on';
    else
        state = 'off';
    end
    switchBack = strcmp(get(h.left.fit.panels.Back.AutBackBut,'Selected'),state);
    if state
        set(h.left.fit.panels.Back.AutBackBut,'Selected','on')
    else
        set(h.left.fit.panels.Back.AutBackBut,'Selected','off')
    end
    warning('on','all')
else
    % Back
    if fitOpt.model.fitzeta
        state = true;
    else
        state = false;
    end
    switchBack = get(h.left.fit.panels.Back.AutBackBut,'Selected')~=state;
    set(h.left.fit.panels.Back.AutBackBut,'Selected',state)
end
if switchBack
    enableBack(h.left.fit.panels.Back.AutBackBut,[],h)
end

% Widthtype
if v<2015
    warning('off','all')
    if fitOpt.model.widthtype==1
        set(h.left.fit.panels.Width.SameBut,'Selected','on')
        set(h.left.fit.panels.Width.DiffBut,'Selected','off')
        set(h.left.fit.panels.Width.UserBut,'Selected','off')
    elseif fitOpt.model.widthtype==0
        set(h.left.fit.panels.Width.SameBut,'Selected','off')
        set(h.left.fit.panels.Width.DiffBut,'Selected','on')
        set(h.left.fit.panels.Width.UserBut,'Selected','off')
    else
        set(h.left.fit.panels.Width.SameBut,'Selected','off')
        set(h.left.fit.panels.Width.DiffBut,'Selected','off')
        set(h.left.fit.panels.Width.UserBut,'Selected','on')
    end
    
    % Test
    if fitOpt.model.test
        set(h.left.fit.panels.Test.But,'Selected','on')
    else
        set(h.left.fit.panels.Test.But,'Selected','off')
    end
    warning('on','all')
else
    if fitOpt.model.widthtype==1
        set(h.left.fit.panels.Width.SameBut,'Selected',true)
        set(h.left.fit.panels.Width.DiffBut,'Selected',false)
        set(h.left.fit.panels.Width.UserBut,'Selected',false)
    elseif fitOpt.model.widthtype==0
        set(h.left.fit.panels.Width.SameBut,'Selected',false)
        set(h.left.fit.panels.Width.DiffBut,'Selected',true)
        set(h.left.fit.panels.Width.UserBut,'Selected',false)
    else
        set(h.left.fit.panels.Width.SameBut,'Selected',false)
        set(h.left.fit.panels.Width.DiffBut,'Selected',false)
        set(h.left.fit.panels.Width.UserBut,'Selected',true)
    end
    
    % Test
    if fitOpt.model.test
        set(h.left.fit.panels.Test.But,'Selected',true)
    else
        set(h.left.fit.panels.Test.But,'Selected',false)
    end
end
if isfield(file,'output')
    h.left.fit.panels.Test.CoorBut.setEnabled(true)
else
    h.left.fit.panels.Test.CoorBut.setEnabled(false)
end
set(h.left.fit.panels.Parallel.Val,'Text',num2str(fitOpt.model.numWorkers))


%% Analysis panel
if any(strcmp(fieldnames(file),'output'))
    state_fitting = true;
    h.left.ana.panel.atomAdv.maxComp.setEnabled(true)
    h.left.ana.panel.atomAdv.selCol.setEnabled(true)
    h.left.ana.panel.atomAdv.selColHist.setEnabled(true)
    h.left.ana.panel.atomAdv.selColType.setEnabled(true)
    if isempty(fitOpt.atom.selCoor)
        h.left.ana.panel.atomAdv.selCol.setForeground(javax.swing.plaf.ColorUIResource(0,0,0))
        set(h.left.ana.panel.atomAdv.selCol,'Text','Select columns in image')
    else
        h.left.ana.panel.atomAdv.selCol.setForeground(java.awt.Color(1,0,0))
        set(h.left.ana.panel.atomAdv.selCol,'Text','Delete selected region')
    end
    if isempty(fitOpt.atom.minVol) && isempty(fitOpt.atom.maxVol)
        h.left.ana.panel.atomAdv.selColHist.setForeground(javax.swing.plaf.ColorUIResource(0,0,0))
        set(h.left.ana.panel.atomAdv.selColHist,'Text','Select columns in histogram')
    else
        h.left.ana.panel.atomAdv.selColHist.setForeground(java.awt.Color(1,0,0))
        set(h.left.ana.panel.atomAdv.selColHist,'Text','Delete selected interval')
    end
    if isempty(fitOpt.atom.selType)
        h.left.ana.panel.atomAdv.selColType.setForeground(javax.swing.plaf.ColorUIResource(0,0,0))
        set(h.left.ana.panel.atomAdv.selColType,'Text','Select columns on type')
    else
        h.left.ana.panel.atomAdv.selColType.setForeground(java.awt.Color(1,0,0))
        set(h.left.ana.panel.atomAdv.selColType,'Text','Delete selection on type')
    end
else
    state_fitting = false;
    h.left.ana.panel.atomAdv.maxComp.setEnabled(false)
    h.left.ana.panel.atomAdv.selCol.setEnabled(false)
    h.left.ana.panel.atomAdv.selCol.setForeground(javax.swing.plaf.ColorUIResource(0,0,0))
    set(h.left.ana.panel.atomAdv.selCol,'Text','Select columns in image')
    h.left.ana.panel.atomAdv.selColHist.setEnabled(false)
    h.left.ana.panel.atomAdv.selColHist.setForeground(javax.swing.plaf.ColorUIResource(0,0,0))
    set(h.left.ana.panel.atomAdv.selColHist,'Text','Select columns in histogram')
    h.left.ana.panel.atomAdv.selColType.setEnabled(false)
    h.left.ana.panel.atomAdv.selColType.setForeground(javax.swing.plaf.ColorUIResource(0,0,0))
    set(h.left.ana.panel.atomAdv.selColType,'Text','Select columns on type')
end
set(h.left.ana.panel.atomAdv.maxComp,'Text',num2str(fitOpt.atom.n_c))
if any(strcmp(fieldnames(file),'atomcounting'))
    h.left.ana.panel.atomAdv.minICL.setEnabled(true)
    h.left.ana.panel.atomAdv.offset.setEnabled(true)
    set(h.left.ana.panel.atomAdv.offset,'Text',num2str(file.atomcounting.offset))
%     
%     if any(strcmp(fieldnames(file.atomcounting),'fitting'))
%         state_fitting = false;
%     else
%         state_fitting = true;
%     end
else
    h.left.ana.panel.atomAdv.minICL.setEnabled(false)
    h.left.ana.panel.atomAdv.offset.setEnabled(false)
    set(h.left.ana.panel.atomAdv.offset,'Text','0')
end

% For matching with simulations
state = false;
if any(strcmp(fieldnames(file),'output'))
    if any(strcmp(fieldnames(file.input),'library'))
        state = true;
    end
end
h.left.ana.panel.acl.matchSCS.setEnabled(state)

h.left.ana.panel.atom.runBut.setEnabled(state_fitting)

% For strain mapping
state = false;
if any(strcmp(fieldnames(file),'output'))
    if isempty(fitOpt.strain.selCoor)
        h.left.ana.panel.strainAdv.selCol.setForeground(javax.swing.plaf.ColorUIResource(0,0,0))
        set(h.left.ana.panel.strainAdv.selCol,'Text','Select columns in image')
    else
        h.left.ana.panel.strainAdv.selCol.setForeground(java.awt.Color(1,0,0))
        set(h.left.ana.panel.strainAdv.selCol,'Text','Delete selected region')
    end
    if any(strcmp(fieldnames(file),'strainmapping'))
        if any(strcmp(fieldnames(file.strainmapping),'coor_relaxed'))
            state = true;
        end
    end
    h.left.ana.panel.strain.strainBut.setEnabled(state)
    if any(strcmp(fieldnames(file.input),'projUnit'))
        state = true;
    end
    h.left.ana.panel.strain.makeDisp.setEnabled(state)
    state = false;
    if any(strcmp(fieldnames(file),'strainmapping')) && any(strcmp(fieldnames(file.input),'projUnit'))
        if any(strcmp(fieldnames(file.strainmapping),'refCoor'))
            state = true;
        end
    end
    h.left.ana.panel.strainAdv.autALat.setEnabled(state)
    h.left.ana.panel.strainAdv.showALatAut.setEnabled(state)
    h.left.ana.panel.strainAdv.usrALat.setEnabled(state)
    h.left.ana.panel.strainAdv.selectALat.setEnabled(state)
    state = true;
else
    h.left.ana.panel.strainAdv.selCol.setForeground(javax.swing.plaf.ColorUIResource(0,0,0))
    set(h.left.ana.panel.strainAdv.selCol,'Text','Select columns in image')
    h.left.ana.panel.strain.strainBut.setEnabled(state)
    h.left.ana.panel.strain.makeDisp.setEnabled(state)
    h.left.ana.panel.strainAdv.autALat.setEnabled(state)
    h.left.ana.panel.strainAdv.showALatAut.setEnabled(state)
    h.left.ana.panel.strainAdv.usrALat.setEnabled(state)
    h.left.ana.panel.strainAdv.selectALat.setEnabled(state)
end
h.left.ana.panel.strainAdv.selCol.setEnabled(state)
h.left.ana.panel.strainAdv.selType.setEnabled(state)
h.left.ana.panel.strainAdv.cenCoor.setEnabled(state)
h.left.ana.panel.strainAdv.showCen.setEnabled(state)
h.left.ana.panel.strainAdv.usrCoor.setEnabled(state)
h.left.ana.panel.strainAdv.selectCoor.setEnabled(state)
h.left.ana.panel.strainAdv.impFitABut.setEnabled(state)
if state && h.left.ana.panel.strainAdv.impFitABut.isSelected
    state = true;
else
    state = false;
end
h.left.ana.panel.strainAdv.impFitNUC.setEnabled(state)
h.left.ana.panel.strainAdv.impFitNUCText.setEnabled(state)
h.left.ana.panel.strainAdv.impFitParAll.setEnabled(state)
h.left.ana.panel.strainAdv.impFitParTeta.setEnabled(state)