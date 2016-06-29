function focusFields(h,state,f)
% focusFields - Change focus state in StatSTEM interface
%
% Change focusable state of all textfields in the left panels 
%
%   syntax: focusFields(h,state,f)
%       h     - reference to all GUI objects
%       state - Make focusable of unfocusable ('on'/'off')
%       f     - Specify which left panel ('prep'/'fit'/'ana'/'all')
%
%   Standard the focus state of the objects in all left panels are changed
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
if nargin<3
    f = {'all'};
end

% Preparation
if any(strcmp(f,'prep')) || any(strcmp(f,'all'))
    fieldsP{1,1} = h.left.peak.panels.pixel.Val;
    fieldsP{2,1} = h.left.peak.panels.pixel.text;
    fieldsP{3,1} = h.left.peak.panels.pixel.Unit;
    fieldsP{4,1} = h.left.peak.panels.pixel.header;
    fieldsP{5,1} = h.left.peak.panels.pixel.main;
    fieldsP{6,1} = h.left.peak.panels.import.mainOpen;
    fieldsP{7,1} = h.left.peak.panels.import.header;
    fieldsP{8,1} = h.left.peak.panels.pfr.mainOpen;
    fieldsP{9,1} = h.left.peak.panels.pfr.header;
    fieldsP{10,1} = h.left.peak.panels.addRem.mainOpen;
    fieldsP{11,1} = h.left.peak.panels.addRem.header;
    fieldsP{12,1} = h.left.peak.panels.addRem.addText;
    fieldsP{13,1} = h.left.peak.jmain;
else
    fieldsP = {};
end

% Fit model panel
if any(strcmp(f,'fit')) || any(strcmp(f,'all'))
    fieldsF{1,1} = h.left.fit.panRout.main;
    fieldsF{2,1} = h.left.fit.panRout.PanRun;
    fieldsF{3,1} = h.left.fit.panRout.PanAbort;
    fieldsF{4,1} = h.left.fit.panRout.PanAdv;
    fieldsF{5,1} = h.left.fit.panels.Back.main;
    fieldsF{6,1} = h.left.fit.panels.Back.header;
    fieldsF{7,1} = h.left.fit.panels.Back.AutBackPan;
    fieldsF{8,1} = h.left.fit.panels.Back.BackPan;
    fieldsF{9,1} = h.left.fit.panels.Back.Text;
    fieldsF{10,1} = h.left.fit.panels.Back.Val;
    fieldsF{11,1} = h.left.fit.panels.Width.header;
    fieldsF{12,1} = h.left.fit.panels.Width.main;
    fieldsF{13,1} = h.left.fit.panels.Test.main;
    fieldsF{14,1} = h.left.fit.panels.Test.header;
    fieldsF{15,1} = h.left.fit.panels.Parallel.main;
    fieldsF{16,1} = h.left.fit.panels.Parallel.header;
    fieldsF{17,1} = h.left.fit.panels.Parallel.Text;
    fieldsF{18,1} = h.left.fit.panels.Parallel.Val;
    fieldsF{19,1} = h.left.fit.panAdv.main;
    fieldsF{20,1} = h.left.fit.jmain;
else
    fieldsF = {};
end

% Analysis panel
if any(strcmp(f,'ana')) || any(strcmp(f,'all'))
    fieldsA{1,1} = h.left.ana.panel.atom.text;
    fieldsA{2,1} = h.left.ana.panel.atom.PanRun;
    fieldsA{3,1} = h.left.ana.panel.atom.PanAbort;
    fieldsA{4,1} = h.left.ana.panel.atom.PanAdv;
    fieldsA{5,1} = h.left.ana.panel.atom.main;
    fieldsA{6,1} = h.left.ana.panel.atomAdv.preHeader;
    fieldsA{7,1} = h.left.ana.panel.atomAdv.maxCompTxt;
    fieldsA{8,1} = h.left.ana.panel.atomAdv.maxCompPan;
    fieldsA{9,1} = h.left.ana.panel.atomAdv.selColPan;
    fieldsA{10,1} = h.left.ana.panel.atomAdv.selColHistPan;
    fieldsA{11,1} = h.left.ana.panel.atomAdv.prePan;
    fieldsA{12,1} = h.left.ana.panel.atomAdv.main;
    fieldsA{13,1} = h.left.ana.panel.atomAdv.postPan;
    fieldsA{14,1} = h.left.ana.panel.atomAdv.postHeader;
    fieldsA{15,1} = h.left.ana.panel.atomAdv.offsetPan;
    fieldsA{16,1} = h.left.ana.panel.atomAdv.offsetText;
    fieldsA{17,1} = h.left.ana.panel.atomAdv.offset;
    fieldsA{18,1} = h.left.ana.panel.atomAdv.minICLPan;
    fieldsA{19,1} = h.left.ana.panel.atomAdv.incLibPan;
    fieldsA{20,1} = h.left.ana.jmain;
    fieldsA{21,1} = h.left.ana.panel.atomAdv.maxComp;
else
    fieldsA = {};
end

% Fields GUI
fieldsGUI{1,1} = h.right.message.jTextPanel;
fieldsGUI{2,1} = h.right.message.text;

fields = [fieldsP;fieldsF;fieldsA;fieldsGUI];
for n=1:length(fields)
    fields{n,1}.setFocusable(state)
    if ~state
        javaCallback(fields{n,1},'MouseEnteredCallback',{@buttonPressed,@reqFocus,h},'MouseExitedCallback',{@buttonPressed,[]})
    else
        javaCallback(fields{n,1},'MouseEnteredCallback',[],'MouseExitedCallback',[],'MouseReleasedCallback',[])
    end
end

% Now the tabs
tab = get(h.right.tabgroup,'SelectedTab');
usr = get(tab,'Userdata');
% Find selected image
value = get(usr.figOptions.selImg.listbox,'Value');
% Now enable or disable the listbox and figure options
if state
    set(usr.figOptions.selImg.listbox,'Callback',{@imageChanged,tab,h},'Enable','on')
    set(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'CellSelectionCallback',{@optionSelected,tab},'Enable','on')
else
    set(usr.figOptions.selImg.listbox,'Callback',[],'Enable','inactive');
    set(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'CellSelectionCallback',[],'Enable','inactive')
end


