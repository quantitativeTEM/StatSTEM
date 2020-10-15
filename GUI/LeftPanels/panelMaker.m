function [h,panels] = panelMaker(h,option,forCompiling)
% panelMaker - Create panel with java buttons
%
%   syntax: h = panelMaker(h,option)
%       h       - structure holding references to StatSTEM interface
%       option  - indicate whether the panels are made for the tab
%       panels  - structure containing panel options
%       'Preparation', 'Fit Model' or 'Analysis'
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2020, EMAT, University of Antwerp
% Author: K. H. W. van den Bos, J. Fatermans
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Find all panels
pth = mfilename('fullpath');
pth = pth(1:end-10);
pan = dir([pth,filesep,option,filesep,'*.m']);

if forCompiling
    % Make sure that in this part all main panels are specified when
    % compiling
    switch option
        case 'Preparation'
            optName = 'prep';
            % First load primary panels
            pan(1).name = 'panelPFR.m';
            pan(2).name = 'panelAddRemove.m';
            pan(3).name = 'panelAssignTypes.m';
            pan(4).name = 'panelImgPar.m';
            %pan(5).name = 'panelImpPeak.m';
        case 'Fit Model'
            optName = 'fit';
            pan(1).name = 'panelFitMain.m';
            pan(2).name = 'panelFitModelSelection.m';
        case 'Analysis'
            optName = 'ana';
            % First load primary panels
            pan(1).name = 'panelSelColumns.m';
            pan(2).name = 'panelIndexing.m';
            pan(3).name = 'panelAtomCountStat.m';
            pan(4).name = 'panelAtomCountSim.m';
            pan(5).name = 'panelAtomCountHMM.m';
            pan(6).name = 'panel3Dmodel.m';
            pan(7).name = 'panelStrainMap.m';
    end
else
    switch option
        case 'Preparation'
            optName = 'prep';
            % First load primary panels
            pan = findSwitchNamePanel(pan,'panelPFR.m',1);
            pan = findSwitchNamePanel(pan,'panelAddRemove.m',2);
            pan = findSwitchNamePanel(pan,'panelAssignTypes.m',3);
            pan = findSwitchNamePanel(pan,'panelImgPar.m',4);
            %pan = findSwitchNamePanel(pan,'panelImpPeak.m',5);
        case 'Fit Model'
            optName = 'fit';
        case 'Analysis'
            optName = 'ana';
            % First load primary panels
            pan = findSwitchNamePanel(pan,'panelSelColumns.m',1);
            pan = findSwitchNamePanel(pan,'panelIndexing.m',2);
            pan = findSwitchNamePanel(pan,'panelAtomCountStat.m',3);
            pan = findSwitchNamePanel(pan,'panelAtomCountSim.m',4);
            pan = findSwitchNamePanel(pan,'panelAtomCountHMM.m',5);
            pan = findSwitchNamePanel(pan,'panel3Dmodel.m',6);
            pan = findSwitchNamePanel(pan,'panelStrainMap.m',7);
    end
end

%% Import java function, since standard MATLAB code cannot be used
import javax.swing.*;
import java.awt.*;

%% Width determined by mac or pc
if ispc
    w = 168;
    font = javax.swing.plaf.FontUIResource('Segoe UI',java.awt.Font.PLAIN,12);
else
    w = 168;
    font = java.awt.Font('Lucida Grande',java.awt.Font.PLAIN,10);
end

%% Create the main panel
jpan = JPanel; % Create main panel

% Set Layout
% The two arguments to the BoxLayout constructor are the container that it 
% manages and the axis along which the components will be laid out.
jpan.setLayout(BoxLayout(jpan, BoxLayout.Y_AXIS));
set(jpan,'Border',border.LineBorder(Color(0.95,0.95,0.95),0,false))

opt = h.left.(optName);
panels = cell(length(pan),1);
for n=1:length(pan)
    panInt = eval(pan(n).name(1:end-2));
    if isfield(panInt,'row')
        nRow = length(panInt.row);
    else
        nRow = 0;
    end
    showAdv = 0;
    if isfield(panInt,'advanced') && ~isempty(fieldnames(panInt.advanced))
        nAdv = 1;
        if isfield(panInt,'showAdv') && panInt.showAdv==1
            showAdv = 1;
        end
    else
        nAdv = 0;
    end
    if ~isempty(panInt.name)
        % Create the panel frame
        jPanHead = JPanel;
        hgt = 24;
        jPanHead.setLayout(BoxLayout(jPanHead, BoxLayout.Y_AXIS));
        jPanHead.setSize(Dimension(w,hgt));jPanHead.setPreferredSize(Dimension(w,hgt));jPanHead.setMaximumSize(Dimension(w,hgt))
        jPanHead.setAlignmentX(Component.LEFT_ALIGNMENT);
        jPanHead.setBackground(Color(0.7,0.7,0.7))
        set(jPanHead,'Border',border.MatteBorder(1,1,0,1,Color(0.3,0.3,0.3)))

        % First create the header
        jHead = JTextField;
        jHead.setAlignmentX(0.5);
        jHead.setFont(font);
        jPanHead.add(jHead);
        jHead.setText(['- ',panInt.name])
        jHead.setEditable(false)
        jHead.setFocusable(false)
        jHead.setSize(Dimension(170,22))
        jHead.setMaximumSize(Dimension(170,22))
        jHead.setPreferredSize(Dimension(170,22))
        jHead.setBackground(Color(0.3,0.3,0.3))
        jHead.setForeground(Color(1,1,1))
        jPanHead.add(Box.createRigidArea(Dimension(0,1)));
        jPanHead.setSize(Dimension(w,hgt));jPanHead.setPreferredSize(Dimension(w,hgt));jPanHead.setMaximumSize(Dimension(w,hgt))
        % Reference
        opt.(['panel',num2str(n)]).header = jPanHead;
        opt.(['panel',num2str(n)]).headerText = jHead;
        jpan.add(jPanHead);
        jHeadMain = jHead;
    end
    
    % Create buttons row per row
    hgt = 1 + ~showAdv + 24*nRow + 24*nAdv;
    jPanInt = JPanel;
    jPanInt.setLayout(BoxLayout(jPanInt, BoxLayout.Y_AXIS));
    jPanInt.setSize(Dimension(w,hgt));jPanInt.setPreferredSize(Dimension(w,hgt));jPanInt.setMaximumSize(Dimension(w,hgt))
    jPanInt.setAlignmentX(Component.LEFT_ALIGNMENT);
    jPanInt.setBackground(Color(0.7,0.7,0.7))
    set(jPanInt,'Border',border.MatteBorder(isempty(panInt.name),1,1,1,Color(0.3,0.3,0.3)))
    jPanInt.add(Box.createRigidArea(Dimension(0,1)));
    for m=1:length(panInt.row)
        jPanRow = JPanel(GridBagLayout);
        fNames = fieldnames(panInt.row(m));
        nOpt = sum(strncmp(fNames,'option',6));
        for k=1:nOpt
            optSel = panInt.row(m).(['option',num2str(k)]);
            if ~isempty(optSel)
                if isempty(optSel.bgcolor)
                    optSel.bgcolor = [0.7,0.7,0.7];
                end
                jPanRow.add(optSel.button);
                % Reference
                opt.(['panel',num2str(n)]).(['row',num2str(m)]).(['option',num2str(k)]) = optSel;
            end
        end
        set(jPanRow,'Border',border.LineBorder(Color(0.7,0.7,0.7),1,false))
        jPanRow.setBackground(Color(0.7,0.7,0.7))
        jPanInt.add(jPanRow);
        jPanInt.add(Box.createRigidArea(Dimension(0,1)));
        % Reference
        opt.(['panel',num2str(n)]).(['row',num2str(m)]).panel = jPanRow;
    end
    
    % Now the advanced panel if present
    if nAdv==1
        % Button for showing advanced options
        jAdv = JPanel(GridLayout(1,1));
        jAdvBut = JCheckBox('Selected',false);
        set(jAdvBut,'Text','Show options')
        jAdvBut.setFont(font);
        jAdvBut.setBackground(Color(0.7,0.7,0.7))
%         jAdvBut.setFocusable(false)
        jAdvBut.setSelected(showAdv)
        jAdv.add(jAdvBut);
        jAdv.setSize(java.awt.Dimension(162, 22));
        jAdv.setPreferredSize(Dimension(162, 22));
        jAdv.setMaximumSize(Dimension(162, 22));
        set(jAdv,'Border',border.LineBorder(Color(0.7,0.7,0.7),1,false))
        jAdv.setBackground(Color(0.7,0.7,0.7))
        jPanInt.add(jAdv); % Add jButton to a JPanel
        set(jPanInt,'Border',border.MatteBorder(isempty(panInt.name),1,~showAdv,1,Color(0.3,0.3,0.3)))
        % Store reference
        opt.(['panel',num2str(n)]).advanced.main = jAdv;
        opt.(['panel',num2str(n)]).advanced.mainBut = jAdvBut;
    else
        jAdvBut = [];
    end
    
    jpan.add(jPanInt);
    opt.(['panel',num2str(n)]).panel = jPanInt;
    jPanMain = jPanInt;
    % Created panels for advanced options
    jRefAdvPan = cell(0,1);
    if nAdv==1
        nA = length(panInt.advanced);
        jRefAdvPan = cell(nA,1);
        for p=1:nA
            nRow = length(panInt.advanced(p).panel.row);
            if mod(p,2)==0
                bgC = 0.85;
            else
                bgC = 0.95;
            end
            % Create buttons row per row
            jPanInt = JPanel;
            hgt = 1+24*nRow + 24*(~isempty(panInt.advanced(p).panel.name));
            jPanInt.setLayout(BoxLayout(jPanInt, BoxLayout.Y_AXIS));
            jPanInt.setSize(Dimension(w,hgt));jPanInt.setPreferredSize(Dimension(w,hgt));jPanInt.setMaximumSize(Dimension(w,hgt))
            jPanInt.setAlignmentX(Component.LEFT_ALIGNMENT);
            jPanInt.setBackground(Color(bgC,bgC,bgC))
            jPanInt.setVisible(showAdv)
            if p==nA
                set(jPanInt,'Border',border.MatteBorder(0,1,1,1,Color(0.3,0.3,0.3)))
            else
                set(jPanInt,'Border',border.MatteBorder(0,1,0,1,Color(0.3,0.3,0.3)))
            end
            jPanInt.add(Box.createRigidArea(Dimension(0,1)));

            % First create the header (if present)
            if ~isempty(panInt.advanced(p).panel.name)
                jHead = JTextField;
                jHead.setAlignmentX(0.5);
                jHead.setFont(font);
                jPanInt.add(jHead);
                jHead.setText([' ',panInt.advanced(p).panel.name])
                jHead.setEditable(false)
%                 jHead.setFocusable(false)
                jHead.setSize(Dimension(168,22))
                jHead.setMaximumSize(Dimension(168,22))
                jHead.setPreferredSize(Dimension(168,22))
                jHead.setBackground(Color(0,0,0))
                jHead.setForeground(Color(1,1,1))
                set(jHead,'Border',border.MatteBorder(2,2,0,2,Color(bgC,bgC,bgC)))
                jPanInt.add(Box.createRigidArea(Dimension(0,2)));
                % Reference
                opt.(['panel',num2str(n)]).advanced.(['panel',num2str(p)]).headerText = jHead;
            else
                jPanInt.add(Box.createRigidArea(Dimension(0,1)));
            end

            for m=1:length(panInt.advanced(p).panel.row)
                jPanRow = JPanel(GridBagLayout);
                fNames = fieldnames(panInt.advanced(p).panel.row(m));
                nOpt = sum(strncmp(fNames,'option',6));
                for k=1:nOpt
                    optSel = panInt.advanced(p).panel.row(m).(['option',num2str(k)]);
                    if ~isempty(optSel)
                        if isempty(optSel.bgcolor)
                            optSel.bgcolor = [bgC,bgC,bgC];
                        end
                        jPanRow.add(optSel.button);
                        % Reference
                        opt.(['panel',num2str(n)]).advanced.(['panel',num2str(p)]).(['row',num2str(m)]).(['option',num2str(k)]) = optSel;
                    end
                end
                set(jPanRow,'Border',border.LineBorder(Color(bgC,bgC,bgC),1,false))
                jPanRow.setBackground(Color(bgC,bgC,bgC))
                jPanInt.add(jPanRow);
                jPanInt.add(Box.createRigidArea(Dimension(0,1)));
                % Reference
                opt.(['panel',num2str(n)]).advanced.(['panel',num2str(p)]).(['row',num2str(m)]).panel = jPanRow;
            end
            jpan.add(jPanInt);
            % Reference
            opt.(['panel',num2str(n)]).advanced.(['panel',num2str(p)]).panel = jPanInt;
            
            % Reference for callback of entire panel
            jRefAdvPan{p,1} = jPanInt;
        end
    end
    opt.(['inputPan',num2str(n)]) = panInt;
    h.left.(optName) = opt;
    jpan.add(Box.createRigidArea(Dimension(0,4)));
    panels{n,1} = panInt;
    
    % Make callback to show or hide the entire panel (if a header is shown)
    if ~isempty(panInt.name)
        javaCallback(jHeadMain,'MouseEnteredCallback',{@buttonPressed,@showHideEntirePanel,jPanHead,jPanMain,jRefAdvPan,jAdvBut},'MouseExitedCallback',{@buttonPressed,[]})
        
    end
end

%% Add scrollbar to panel and update GUI
% set(jpan,'Border',border.LineBorder(Color(0.95,0.95,0.95),1,false))
jscrollpane=JScrollPane(jpan); % Add jPanels to a JScrollPane
jscrollpane.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED)

% Javacomponent adds the requested component as a child of the requested 
% parent container and wraps it in a Matlab Handle-Graphics container
[jj,hh]=javacomponent(jscrollpane,[0 0 1 1],h.left.(optName).tab);
set(jj,'Border',border.LineBorder(Color(0.95,0.95,0.95),1,false))
set(hh,'units','normalized','Position',[0 0 1 1])
set(jj,'MouseMovedCallback',{@cursorArrow,h.fig})

h.left.(optName).main = hh;
h.left.(optName).jmain = jj;

function showHideEntirePanel(jButton,~,jPanHead,jPanel,jRefAdvPan,jAdvBut)
% First check if panel is shown
state = jPanel.isVisible;
% Show/hide panel
jPanel.setVisible(~state)
% Update text
set(jPanHead,'Border',javax.swing.border.MatteBorder(1,1,state,1,java.awt.Color(0.3,0.3,0.3)))
txt = char(jButton.getText);
if state
    txt(1) = '+';
else
    txt(1) = '-';
end
jButton.setText(txt)
% Show/hide advanced panels
nA = length(jRefAdvPan);
if nA>0
    stateAdv = jAdvBut.isSelected;
    state = stateAdv & ~state;
    for i=1:nA
        jRefAdvPan{i,1}.setVisible(state)
    end
end



function pan = findSwitchNamePanel(pan,name,N)

n = 0;
ind = 0;
while ind==0 && n<10000
    n=n+1;
    if strcmp(pan(n).name,name)
        ind = n;
    end
end
if n<10000
    panInt = pan;
    pan(N) = panInt(ind);
    pan(ind) = panInt(N);
end
