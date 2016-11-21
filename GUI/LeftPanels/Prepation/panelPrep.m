function h = panelPrep(h)
% panelPrep - Create preparation panel
%
%   syntax: h = panelPrep(h)
%       h       - structure holding references to StatSTEM interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

%% Import java function, since standard MATLAB code cannot be used
import javax.swing.*;
import java.awt.*;

%% Width determined by mac or pc
if ispc
    w = 168;
    font = javax.swing.plaf.FontUIResource('Segoe UI',java.awt.Font.PLAIN,12);
else
    w = 168;
    font = java.awt.Font('Lucida Grande',java.awt.Font.PLAIN,12);
end

%% Create the main panel
jpan = JPanel; % Create main panel

% Set Layout
% The two arguments to the BoxLayout constructor are the container that it 
% manages and the axis along which the components will be laid out.
jpan.setLayout(BoxLayout(jpan, BoxLayout.Y_AXIS));
set(jpan,'Border',border.LineBorder(Color(0.95,0.95,0.95),0,false))

%% First panel
% Create a panel for adding and removing peak locations
jPanAR = JPanel;
jPanAR.setLayout(BoxLayout(jPanAR, BoxLayout.Y_AXIS));
jPanAR.setSize(Dimension(w,145));jPanAR.setPreferredSize(Dimension(w,145));jPanAR.setMaximumSize(Dimension(w,145))
jPanAR.setAlignmentX(Component.LEFT_ALIGNMENT);
jPanAR.setBackground(Color(0.7,0.7,0.7))
set(jPanAR,'Border',border.MatteBorder(1,1,1,1,Color(0.3,0.3,0.3)))

% Create a text box indicating the purpose of the buttons
jEditAR = JTextField;
jEditAR.setAlignmentX(0.5);
jEditAR.setFont(font);
jPanAR.add(jEditAR);
jEditAR.setText('+ Add/Remove Peaks')
jEditAR.setEditable(false)
jEditAR.setFocusable(false)
jEditAR.setSize(Dimension(170,22))
jEditAR.setMaximumSize(Dimension(170,22))
jEditAR.setPreferredSize(Dimension(170,22))
jEditAR.setBackground(Color(0.3,0.3,0.3))
jEditAR.setForeground(Color(1,1,1))
jPanAR.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.peak.panels.addRem.header = jEditAR;

% Buttons for adding peak positions
jPanAdd = JPanel(GridBagLayout); % Box containing everything
jAddText = JTextField;
jAddText.setFont(font);
set(jAddText,'Text','Type:','Border',border.LineBorder(Color(0.7,0.7,0.7),1,false))
jAddText.setBackground(Color(0.7,0.7,0.7))
jAddText.setEditable(false);
jAddText.setFocusable(false)
if isunix
    xds = [33,64,65];
    yds = [20,18,20];
else
    xds = [33,64,65];
    yds = [20,18,20];
end
jAddText.setSize(Dimension(xds(1),yds(1)));jAddText.setPreferredSize(Dimension(xds(1), yds(1)));jAddText.setMaximumSize(Dimension(xds(1), yds(1)));
jAddType = JComboBox;
jAddType.setBackground(Color(0.7,0.7,0.7))
jAddType.setEnabled(false)
jAddType.setFocusable(false)
jAddType.setModel(javax.swing.DefaultComboBoxModel({'1';'Add';'Remove';'Names'}))
jAddType.setSize(Dimension(xds(2),yds(2)));jAddType.setPreferredSize(Dimension(xds(2), yds(2)));jAddType.setMaximumSize(Dimension(xds(2), yds(2)));
jAddBut = JButton();
set(jAddBut,'Text','Add')
jAddBut.setFont(font);
jAddBut.setBackground(Color(0.7,0.7,0.7))
jAddBut.setEnabled(false)
jAddBut.setFocusable(false)
jAddBut.setSize(Dimension(xds(3),yds(3)));jAddBut.setPreferredSize(Dimension(xds(3), yds(3)));jAddBut.setMaximumSize(Dimension(xds(3), yds(3)));
jPanAdd.add(jAddText);
jPanAdd.add(jAddType);
jPanAdd.add(jAddBut);
jPanAdd.setSize(java.awt.Dimension(166, 22));
jPanAdd.setPreferredSize(Dimension(166, 22));
jPanAdd.setMaximumSize(Dimension(166, 22));
set(jPanAdd,'Border',border.LineBorder(Color(0.7,0.7,0.7),1,false))
jPanAdd.setBackground(Color(0.7,0.7,0.7))
jPanAR.add(jPanAdd); % Add jButton to panel
jPanAR.add(Box.createRigidArea(Dimension(0,2)));
% Reference
h.left.peak.panels.addRem.addText = jAddText;
h.left.peak.panels.addRem.addPanel = jPanAdd;
h.left.peak.panels.addRem.addType  = jAddType;
h.left.peak.panels.addRem.addBut   = jAddBut;

% Add two buttons next to each other, first create a boxed panel
jPanRem = JPanel(GridLayout(1,2));
jRemBut = JButton();
set(jRemBut,'Text','Remove');
jRemBut.setFont(font);
jRemBut.setEnabled(false)
jRemBut.setFocusable(false)
jRemBut.setBackground(Color(0.7,0.7,0.7))
jPanRem.add(jRemBut);
jRemABut = JButton();
set(jRemABut,'Text','Remove all')%,'ToolTipText','Remove all')
jRemABut.setFont(font);
jRemABut.setEnabled(false)
jRemABut.setFocusable(false)
jRemABut.setBackground(Color(0.7,0.7,0.7))
jPanRem.add(jRemABut);jRemABut.setMargin(Insets(0,0,0,0))
jPanAR.add(jPanRem); % Add jButton to a JPanel
jPanRem.setSize(java.awt.Dimension(166, 22));
jPanRem.setPreferredSize(Dimension(166, 22));
jPanRem.setMaximumSize(Dimension(166, 22));
set(jPanRem,'Border',border.LineBorder(Color(0.7,0.7,0.7),1,false))
jPanRem.setBackground(Color(0.7,0.7,0.7))
jPanAR.add(Box.createRigidArea(Dimension(0,2)));
% Reference
h.left.peak.panels.addRem.remPanel  = jPanRem;
h.left.peak.panels.addRem.remBut    = jRemBut;
h.left.peak.panels.addRem.remAllBut = jRemABut;

% Select region button
jSelRegPan = JPanel(GridLayout(1,1));
jSelRegBut = JButton();
set(jSelRegBut,'Text','Select region')
jSelRegBut.setFont(font);
jSelRegBut.setEnabled(false)
jSelRegBut.setFocusable(false)
jSelRegBut.setBackground(Color(0.7,0.7,0.7))
jSelRegPan.add(jSelRegBut);
jSelRegPan.setSize(java.awt.Dimension(166, 22));
jSelRegPan.setPreferredSize(Dimension(166, 22));
jSelRegPan.setMaximumSize(Dimension(166, 22));
set(jSelRegPan,'Border',border.LineBorder(Color(0.7,0.7,0.7),1,false))
jSelRegPan.setBackground(Color(0.7,0.7,0.7))
jPanAR.add(jSelRegPan); % Add jButton to a JPanel
jPanAR.add(Box.createRigidArea(Dimension(0,2)));
% Reference
h.left.peak.panels.addRem.selRegPan = jSelRegPan;
h.left.peak.panels.addRem.selRegBut = jSelRegBut;

% Remove region button
jRemRegPan = JPanel(GridLayout(1,1));
jRemRegBut = JButton();
set(jRemRegBut,'Text','Remove region')
jRemRegBut.setFont(font);
jRemRegBut.setEnabled(false)
jRemRegBut.setFocusable(false)
jRemRegBut.setBackground(Color(0.7,0.7,0.7))
jRemRegPan.add(jRemRegBut);
jRemRegPan.setSize(java.awt.Dimension(166, 22));
jRemRegPan.setPreferredSize(Dimension(166, 22));
jRemRegPan.setMaximumSize(Dimension(166, 22));
set(jRemRegPan,'Border',border.LineBorder(Color(0.7,0.7,0.7),1,false))
jRemRegPan.setBackground(Color(0.7,0.7,0.7))
jPanAR.add(jRemRegPan); % Add jButton to a JPanel
jPanAR.add(Box.createRigidArea(Dimension(0,2)));
% Reference
h.left.peak.panels.addRem.remRegPan = jRemRegPan;
h.left.peak.panels.addRem.remRegBut = jRemRegBut;

jChangeATPan = JPanel(GridBagLayout);
jChangeAT = JButton();jChangeAT.setMargin(Insets(0,0,0,0))
set(jChangeAT,'Text','Change type to:')
jChangeAT.setFont(font);
jChangeAT.setEnabled(false)
jChangeAT.setFocusable(false)
jChangeAT.setBackground(Color(0.7,0.7,0.7))
jChangeAT.setSize(Dimension(107, 20));jChangeAT.setPreferredSize(Dimension(107, 20));
jChangeATList = JComboBox;
jChangeATList.setFont(font);
jChangeATList.setBackground(Color(0.7,0.7,0.7))
jChangeATList.setModel(javax.swing.DefaultComboBoxModel({'1';'Add';'Remove';'Names'}))
jChangeATList.setSize(Dimension(56,18));jChangeATList.setPreferredSize(Dimension(56, 18))
jChangeATList.setEnabled(false)
jChangeATList.setFocusable(false)
jChangeATPan.setSize(Dimension(168,22))
jChangeATPan.setPreferredSize(Dimension(168, 22));
jChangeATPan.setMaximumSize(Dimension(168, 22));
jChangeATPan.add(jChangeAT);
jChangeATPan.add(jChangeATList);
jPanAR.add(jChangeATPan);
set(jChangeATPan,'Border',border.LineBorder(Color(0.7,0.7,0.7),1,false))
jChangeATPan.setBackground(Color(0.7,0.7,0.7))
% Reference
h.left.peak.panels.addRem.changePan  = jChangeATPan;
h.left.peak.panels.addRem.changeBut  = jChangeAT;
h.left.peak.panels.addRem.changeType = jChangeATList;

% Add the add remove panel to the preparation panel
h.left.peak.panels.addRem.mainOpen = jPanAR;
jpan.add(h.left.peak.panels.addRem.mainOpen);

%% Second panel
% Create a for the peak finder routine
jPanPFR = JPanel;
jPanPFR.setLayout(BoxLayout(jPanPFR, BoxLayout.Y_AXIS));
jPanPFR.setSize(Dimension(168,73));jPanPFR.setPreferredSize(Dimension(168,73));jPanPFR.setMaximumSize(Dimension(168,73))
jPanPFR.setAlignmentX(Component.LEFT_ALIGNMENT);
jPanPFR.setBackground(Color(0.7,0.7,0.7))
set(jPanPFR,'Border',border.MatteBorder(1,1,1,1,Color(0.3,0.3,0.3)))

% Create a text box indicating the purpose of the buttons
jEditPFR = JTextField;
jEditPFR.setAlignmentX(0.5);
jPanPFR.add(jEditPFR);
jEditPFR.setText('+ Peak Finder Routine')
jEditPFR.setFont(font);
jEditPFR.setFocusable(false)
jEditPFR.setEditable(false)
jEditPFR.setSize(Dimension(170,22));jEditPFR.setMaximumSize(Dimension(170,22));jEditPFR.setPreferredSize(Dimension(170,22))
jEditPFR.setBackground(Color(0.3,0.3,0.3))
jEditPFR.setForeground(Color(1,1,1))
jPanPFR.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.peak.panels.pfr.header = jEditPFR;

% Button for running the routine
jRunPFR = JPanel(GridLayout(1,1));
jRunPFRBut = JButton();
set(jRunPFRBut,'Text','Execute routine')
jRunPFRBut.setFont(font);
jRunPFRBut.setBackground(Color(0.7,0.7,0.7))
jRunPFRBut.setEnabled(false)
jRunPFRBut.setFocusable(false)
jRunPFR.add(jRunPFRBut);
jRunPFR.setSize(java.awt.Dimension(166, 22));
jRunPFR.setPreferredSize(Dimension(166, 22));
jRunPFR.setMaximumSize(Dimension(166, 22));
set(jRunPFR,'Border',border.LineBorder(Color(0.7,0.7,0.7),1,false))
jRunPFR.setBackground(Color(0.7,0.7,0.7))
jPanPFR.add(jRunPFR); % Add jButton to a JPanel
jPanPFR.add(Box.createRigidArea(Dimension(0,2)));
% Reference
h.left.peak.panels.pfr.RunPan = jRunPFR;
h.left.peak.panels.pfr.RunBut = jRunPFRBut;

% Button for tunning the parameters
jTunePFR = JPanel(GridLayout(1,1));
jTunePFRBut = JButton();
set(jTunePFRBut,'Text','Tune parameters')
jTunePFRBut.setFont(font);
jTunePFRBut.setBackground(Color(0.7,0.7,0.7))
jTunePFRBut.setEnabled(false)
jTunePFRBut.setFocusable(false)
jTunePFR.add(jTunePFRBut);
jTunePFR.setSize(java.awt.Dimension(166, 22));
jTunePFR.setPreferredSize(Dimension(166, 22));
jTunePFR.setMaximumSize(Dimension(166, 22));
set(jTunePFR,'Border',border.LineBorder(Color(0.7,0.7,0.7),1,false))
jTunePFR.setBackground(Color(0.7,0.7,0.7))
jPanPFR.add(jTunePFR); % Add jButton to a JPanel
jPanPFR.add(Box.createRigidArea(Dimension(0,2)));
% Reference
h.left.peak.panels.pfr.TunePan = jTunePFR;
h.left.peak.panels.pfr.TuneBut = jTunePFRBut;

% Add the peak finder routine panel to the preparation panel
h.left.peak.panels.pfr.mainOpen = jPanPFR;
jpan.add(Box.createRigidArea(Dimension(0,4)));
jpan.add(h.left.peak.panels.pfr.mainOpen);

%% Thirth panel
% Create a for importing peak locations
jPanPix = JPanel;
jPanPix.setLayout(BoxLayout(jPanPix, BoxLayout.Y_AXIS));
jPanPix.setSize(Dimension(168,49));jPanPix.setPreferredSize(Dimension(168,49));jPanPix.setMaximumSize(Dimension(168,49))
jPanPix.setAlignmentX(Component.LEFT_ALIGNMENT);
jPanPix.setBackground(Color(0.7,0.7,0.7))
set(jPanPix,'Border',border.MatteBorder(1,1,1,1,Color(0.3,0.3,0.3)))

% % Create a text box indicating the purpose of the buttons
jEditPix = JTextField;
jEditPix.setAlignmentX(0.5);
jPanPix.add(jEditPix);
jEditPix.setText('+ Image parameters')
jEditPix.setFont(font);
jEditPix.setEditable(false)
jEditPix.setSize(Dimension(170,22));jEditPix.setMaximumSize(Dimension(170,22));jEditPix.setPreferredSize(Dimension(170,22))
jEditPix.setBackground(Color(0.3,0.3,0.3))
jEditPix.setForeground(Color(1,1,1))
jPanPix.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.peak.panels.pixel.header = jEditPix;

% Panel for pixel size
% Add two buttons next to each other, first create a boxed panel
jPixValPan = JPanel(GridBagLayout);
jPixValPan.setBackground(Color(0.7,0.7,0.7))
jPixText = JTextField;
set(jPixText,'Text','Pixel size:');
jPixText.setFont(font);
jPixText.setEditable(false)
jPixText.setBackground(Color(0.7,0.7,0.7))
set(jPixText,'Border',border.LineBorder(Color(0.7,0.7,0.7),1,false))
if isunix
    xps = [55,87,22];
else
    xps = [53,87,20];
end
jPixText.setSize(Dimension(xps(1),20));jPixText.setPreferredSize(Dimension(xps(1), 20));jPixText.setMaximumSize(Dimension(xps(1), 20));
jPixValPan.add(jPixText);
jPixVal = JTextField;
set(jPixVal,'Text','');
jPixVal.setFont(font);
jPixVal.setSize(Dimension(xps(2),18));jPixVal.setPreferredSize(Dimension(xps(2), 18));jPixVal.setMaximumSize(Dimension(xps(2), 18));
jPixVal.setEnabled(false)
jPixValPan.add(jPixVal);
jPixUnit = JTextField();
set(jPixUnit,'Text',char(197))
jPixUnit.setFont(font);
jPixUnit.setHorizontalAlignment(JTextField.CENTER);
jPixUnit.setAlignmentX(Component.CENTER_ALIGNMENT);
jPixUnit.setSize(java.awt.Dimension(xps(3), 18));jPixUnit.setPreferredSize(Dimension(xps(3), 18));jPixUnit.setMaximumSize(Dimension(xps(3), 18));
jPixUnit.setEnabled(false)
jPixValPan.add(jPixUnit);
jPanPix.add(jPixValPan); 
jPanPix.add(Box.createRigidArea(Dimension(0,2)));
% Reference
h.left.peak.panels.pixel.panVal = jPixValPan;
h.left.peak.panels.pixel.text = jPixText;
h.left.peak.panels.pixel.Val = jPixVal;
h.left.peak.panels.pixel.Unit = jPixUnit;

% Add the pixel size panel to the preparation panel
h.left.peak.panels.pixel.main = jPanPix;
jpan.add(Box.createRigidArea(Dimension(0,4)));
jpan.add(h.left.peak.panels.pixel.main);

%% Fourth panel
% Create a for importing peak locations
jPanImp = JPanel;
jPanImp.setLayout(BoxLayout(jPanImp, BoxLayout.Y_AXIS));
jPanImp.setSize(Dimension(168,49));jPanImp.setPreferredSize(Dimension(168,49));jPanImp.setMaximumSize(Dimension(168,49))
jPanImp.setAlignmentX(Component.LEFT_ALIGNMENT);
jPanImp.setBackground(Color(0.7,0.7,0.7))
set(jPanImp,'Border',border.MatteBorder(1,1,1,1,Color(0.3,0.3,0.3)))

% % Create a text box indicating the purpose of the buttons
jEditImp = JTextField;
jEditImp.setAlignmentX(0.5);
jPanImp.add(jEditImp);
jEditImp.setText('+ Import peak locations')
jEditImp.setFont(font);
jEditImp.setEditable(false)
jEditImp.setFocusable(false)
jEditImp.setSize(Dimension(170,22));jEditImp.setMaximumSize(Dimension(170,22));jEditImp.setPreferredSize(Dimension(170,22))
jEditImp.setBackground(Color(0.3,0.3,0.3))
jEditImp.setForeground(Color(1,1,1))
jPanImp.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.peak.panels.import.header = jEditImp;

% Button for importing peak locations
jImportP = JPanel(GridLayout(1,1));
jImport = JButton();
set(jImport,'Text','Load File')
jImport.setFont(font);
jImport.setBackground(Color(0.7,0.7,0.7))
jImport.setEnabled(false)
jImport.setFocusable(false)
jImportP.add(jImport);
jImportP.setSize(java.awt.Dimension(166, 22));
jImportP.setPreferredSize(Dimension(166, 22));
jImportP.setMaximumSize(Dimension(166, 22));
set(jImportP,'Border',border.LineBorder(Color(0.7,0.7,0.7),1,false))
jImportP.setBackground(Color(0.7,0.7,0.7))
jPanImp.add(jImportP); % Add jButton to a JPanel
jPanImp.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.peak.panels.import.PanBut = jImportP;
h.left.peak.panels.import.But =jImport;

% Add the pixel size panel to the preparation panel
h.left.peak.panels.import.mainOpen = jPanImp;
jpan.add(Box.createRigidArea(Dimension(0,4)));
jpan.add(h.left.peak.panels.import.mainOpen);

%% Add scrollbar to panel and update GUI
% set(jpan,'Border',border.LineBorder(Color(0.95,0.95,0.95),1,false))
jscrollpane=JScrollPane(jpan); % Add jPanels to a JScrollPane
jscrollpane.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED)

% Javacomponent adds the requested component as a child of the requested 
% parent container and wraps it in a Matlab Handle-Graphics container
[jj,hh]=javacomponent(jscrollpane,[0 0 1 1],h.left.peak.tab);
set(jj,'Border',border.LineBorder(Color(0.95,0.95,0.95),1,false))
set(hh,'units','normalized','Position',[0 0 1 1])
set(jj,'MouseMovedCallback',{@cursorArrow,h.fig})

h.left.peak.main = hh;
h.left.peak.jmain = jj;