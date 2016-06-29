function h = panelAnalysis(h)
% panelAnalysis - Create the analysis panel
%
%   syntax: h = panelAnalysis(h)
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

%% Create the main panel
jpanAna = JPanel; % Create main panel

% Set Layout
% The two arguments to the BoxLayout constructor are the container that it 
% manages and the axis along which the components will be laid out.
jpanAna.setLayout(BoxLayout(jpanAna, BoxLayout.Y_AXIS));
%% First panel
% Create to include all 
jPanAtom = JPanel;
jPanAtom.setLayout(BoxLayout(jPanAtom, BoxLayout.Y_AXIS));
jPanAtom.setSize(Dimension(170,91));jPanAtom.setPreferredSize(Dimension(170,91));jPanAtom.setMaximumSize(Dimension(170,91))
jPanAtom.setAlignmentX(Component.LEFT_ALIGNMENT);
jPanAtom.setBackground(Color(0.8,0.8,0.8))
% set(jPanAtom,'Border',border.LineBorder(Color(0.95,0.95,0.95),1,false))
set(jPanAtom,'Border',border.MatteBorder(1,1,0,1,Color(0.95,0.95,0.95)))

% Create a text box indicating the purpose of the buttons
jEditAtom = JTextField;
jEditAtom.setAlignmentX(0.5);
jPanAtom.add(jEditAtom);
jEditAtom.setText('+ Atom counting')
jEditAtom.setEditable(false)
jEditAtom.setFocusable(false)
jEditAtom.setSize(Dimension(170,22))
jEditAtom.setMaximumSize(Dimension(170,22))
jEditAtom.setPreferredSize(Dimension(170,22))
jEditAtom.setBackground(Color(0.7,0.7,0.7))
jPanAtom.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.atom.text = jEditAtom;

% Button for running the routine
jRunICL = JPanel(GridLayout(1,1));
jRunICLBut = JButton();
set(jRunICLBut,'Text','Run ICL')
jRunICLBut.setEnabled(false)
jRunICLBut.setFocusable(false)
jRunICLBut.setBackground(Color(0.8,0.8,0.8))
jRunICL.add(jRunICLBut);
jRunICL.setSize(java.awt.Dimension(170, 22));
jRunICL.setPreferredSize(Dimension(170, 22));
jRunICL.setMaximumSize(Dimension(170, 22));
set(jRunICL,'Border',border.LineBorder(Color(0.8,0.8,0.8),1,false))
jRunICL.setBackground(Color(0.8,0.8,0.8))
jPanAtom.add(jRunICL); % Add jButton to a JPanel
% jPanAtom.add(Box.createRigidArea(Dimension(0,2)));
% Reference
h.left.ana.panel.atom.PanRun = jRunICL;
h.left.ana.panel.atom.runBut =jRunICLBut;

% Button for aborting the routine
jAbortICL = JPanel(GridLayout(1,1));
jAbortICLBut = JButton();
set(jAbortICLBut,'Text','Stop ICL')
jAbortICLBut.setBackground(Color(0.8,0.8,0.8))
jAbortICLBut.setFocusable(false)
jAbortICLBut.setEnabled(false)
jAbortICL.add(jAbortICLBut);
jAbortICL.setSize(java.awt.Dimension(170, 22));
jAbortICL.setPreferredSize(Dimension(170, 22));
jAbortICL.setMaximumSize(Dimension(170, 22));
set(jAbortICL,'Border',border.LineBorder(Color(0.8,0.8,0.8),1,false))
jAbortICL.setBackground(Color(0.8,0.8,0.8))
jPanAtom.add(jAbortICL); % Add jButton to a JPanel
jPanAtom.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.atom.PanAbort = jAbortICL;
h.left.ana.panel.atom.AbortBut =jAbortICLBut;

% Button for showing advanced options
jAdvButPan = JPanel(GridLayout(1,1));
jAdvBut = JCheckBox('Selected',true);
set(jAdvBut,'Text','Show advanced options')
jAdvBut.setBackground(Color(0.85,0.85,0.85))
jAdvBut.setFocusable(false)
jAdvButPan.add(jAdvBut);
jAdvButPan.setSize(java.awt.Dimension(170, 22));
jAdvButPan.setPreferredSize(Dimension(170, 22));
jAdvButPan.setMaximumSize(Dimension(170, 22));
set(jAdvButPan,'Border',border.LineBorder(Color(0.85,0.85,0.85),1,false))
jAdvButPan.setBackground(Color(0.85,0.85,0.85))
jPanAtom.add(jAdvButPan); % Add jButton to a JPanel
% jPanAtom.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.atom.PanAdv = jAdvButPan;
h.left.ana.panel.atom.AdvBut = jAdvBut;

% Add the panel to the main panel
h.left.ana.panel.atom.main = jPanAtom;
jpanAna.add(h.left.ana.panel.atom.main);

%% Advance panel for atom counting
% Create to include all advanced options
jPanAtomAdv = JPanel;
jPanAtomAdv.setLayout(BoxLayout(jPanAtomAdv, BoxLayout.Y_AXIS));
jPanAtomAdv.setSize(Dimension(170,200));jPanAtomAdv.setPreferredSize(Dimension(170,200));jPanAtomAdv.setMaximumSize(Dimension(170,200))
jPanAtomAdv.setAlignmentX(Component.LEFT_ALIGNMENT);
jPanAtomAdv.setBackground(Color(0.85,0.85,0.85))
set(jPanAtomAdv,'Border',border.MatteBorder(0,1,0,1,Color(0.95,0.95,0.95)))
jPanAtomAdv.add(Box.createRigidArea(Dimension(0,1)));

% The pre analysis advanced options panel
jPanPreAtomAdv = JPanel;
jPanPreAtomAdv.setLayout(BoxLayout(jPanPreAtomAdv, BoxLayout.Y_AXIS));
jPanPreAtomAdv.setSize(Dimension(169,112));jPanPreAtomAdv.setPreferredSize(Dimension(169,112));jPanPreAtomAdv.setMaximumSize(Dimension(169,112))
% jPanPreAtomAdv.setAlignmentX(Component.LEFT_ALIGNMENT);
jPanPreAtomAdv.setBackground(Color(0.85,0.85,0.85))
set(jPanPreAtomAdv,'Border',border.MatteBorder(1,1,1,1,Color(0.3,0.3,0.3)))
jPanAtomAdv.add(jPanPreAtomAdv);
jPanAtomAdv.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.atomAdv.prePan = jPanPreAtomAdv;

% The header
jPanPreAtomHead = JTextField;
jPanPreAtomHead.setAlignmentX(0.5);
jPanPreAtomAdv.add(jPanPreAtomHead);
jPanPreAtomHead.setText(' Pre-analysis options')
jPanPreAtomHead.setEditable(false)
jPanPreAtomHead.setFocusable(false)
jPanPreAtomHead.setSize(Dimension(170,22))
jPanPreAtomHead.setMaximumSize(Dimension(170,22))
jPanPreAtomHead.setPreferredSize(Dimension(170,22))
jPanPreAtomHead.setBackground(Color(0.3,0.3,0.3))
jPanPreAtomHead.setForeground(Color(1,1,1))
set(jPanPreAtomHead,'Border',border.MatteBorder(1,1,1,1,Color(0.85,0.85,0.85)))
jPanPreAtomAdv.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.atomAdv.preHeader = jPanPreAtomHead;

% Create options to limit the maximum number of components that will be
% estimated
jPanMaxNum = JPanel(GridBagLayout);
jPanMaxNum.setBackground(Color(0.85,0.85,0.85))
jTextMaxNum = JTextField;
set(jTextMaxNum,'Text','Max components:');
jTextMaxNum.setAlignmentX(Component.LEFT_ALIGNMENT);
jTextMaxNum.setEditable(false)
jTextMaxNum.setBackground(Color(0.85,0.85,0.85))
set(jTextMaxNum,'Border',border.LineBorder(Color(0.85,0.85,0.85),1,false))
jTextMaxNum.setSize(Dimension(100,20));jTextMaxNum.setPreferredSize(Dimension(100, 20));jTextMaxNum.setMaximumSize(Dimension(100, 20));
jTextMaxNum.setToolTipText('Define the maximum number of components to estimate')
jPanMaxNum.add(jTextMaxNum);
jMaxVal = JTextField;
set(jMaxVal,'Text','50');
jMaxVal.setSize(Dimension(58,18));jMaxVal.setPreferredSize(Dimension(58, 18));jMaxVal.setMaximumSize(Dimension(58, 18));
jMaxVal.setEnabled(false)
jMaxVal.setToolTipText('Define the maximum number of components to estimate')
jPanMaxNum.add(jMaxVal);
jPanPreAtomAdv.add(jPanMaxNum); 
jPanPreAtomAdv.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.atomAdv.maxCompPan = jPanMaxNum;
h.left.ana.panel.atomAdv.maxCompTxt = jTextMaxNum;
h.left.ana.panel.atomAdv.maxComp = jMaxVal;

% Create buttons to select and deselect columns
jPanSelColImg = JPanel(GridBagLayout);
jPanSelColImg.setBackground(Color(0.85,0.85,0.85))
jSelColImg = JButton();
set(jSelColImg,'Text','Select columns in image')
jSelColImg.setEnabled(false)
jSelColImg.setMargin(Insets(0,0,0,0))
jSelColImg.setBackground(Color(0.85,0.85,0.85))

jSelColImg.setFocusable(false)
jPanSelColImg.add(jSelColImg);
jSelColImg.setSize(java.awt.Dimension(160, 20));jSelColImg.setPreferredSize(Dimension(160, 20));jSelColImg.setMaximumSize(Dimension(160, 20));
jPanPreAtomAdv.add(jPanSelColImg); % Add jButton to a JPanel
jPanPreAtomAdv.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.atomAdv.selColPan = jPanSelColImg;
h.left.ana.panel.atomAdv.selCol = jSelColImg;

% Create buttons to select and deselect columns
jPanSelColHist = JPanel(GridBagLayout);
jPanSelColHist.setBackground(Color(0.85,0.85,0.85))
jSelColHist = JButton();
set(jSelColHist,'Text','Select columns in histgram')
jSelColHist.setEnabled(false)
jSelColHist.setMargin(Insets(0,0,0,0))
jSelColHist.setBackground(Color(0.85,0.85,0.85))
jSelColHist.setFocusable(false)
jPanSelColHist.add(jSelColHist);
jSelColHist.setSize(java.awt.Dimension(160, 20));jSelColHist.setPreferredSize(Dimension(160, 20));jSelColHist.setMaximumSize(Dimension(160, 20));
jPanPreAtomAdv.add(jPanSelColHist); % Add jButton to a JPanel
jPanPreAtomAdv.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.atomAdv.selColHistPan = jPanSelColHist;
h.left.ana.panel.atomAdv.selColHist = jSelColHist;

% Create buttons to select and deselect columns
jPanSelColType = JPanel(GridBagLayout);
jPanSelColType.setBackground(Color(0.85,0.85,0.85))
jSelColType = JButton();
set(jSelColType,'Text','Select columns on type')
jSelColType.setEnabled(false)
jSelColType.setMargin(Insets(0,0,0,0))
jSelColType.setBackground(Color(0.85,0.85,0.85))
jSelColType.setFocusable(false)
jPanSelColType.add(jSelColType);
jSelColType.setSize(java.awt.Dimension(160, 20));jSelColType.setPreferredSize(Dimension(160, 20));jSelColType.setMaximumSize(Dimension(160, 20));
jPanPreAtomAdv.add(jPanSelColType); % Add jButton to a JPanel
jPanPreAtomAdv.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.atomAdv.selColTypePan = jPanSelColType;
h.left.ana.panel.atomAdv.selColType = jSelColType;

%% The post analysis advanced options panel
jPanPostAtomAdv = JPanel;
jPanPostAtomAdv.setLayout(BoxLayout(jPanPostAtomAdv, BoxLayout.Y_AXIS));
jPanPostAtomAdv.setSize(Dimension(169,90));jPanPostAtomAdv.setPreferredSize(Dimension(169,90));jPanPostAtomAdv.setMaximumSize(Dimension(169,90))
% jPanPreAtomAdv.setAlignmentX(Component.LEFT_ALIGNMENT);
jPanPostAtomAdv.setBackground(Color(0.85,0.85,0.85))
set(jPanPostAtomAdv,'Border',border.MatteBorder(1,1,1,1,Color(0.1,0.1,0.1)))
jPanAtomAdv.add(jPanPostAtomAdv);
jPanAtomAdv.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.atomAdv.postPan = jPanPostAtomAdv;

% The header
jPanPostAtomHead = JTextField;
jPanPostAtomHead.setAlignmentX(0.5);
jPanPostAtomAdv.add(jPanPostAtomHead);
jPanPostAtomHead.setText(' Post-analysis options')
jPanPostAtomHead.setEditable(false)
jPanPostAtomHead.setFocusable(false)
jPanPostAtomHead.setSize(Dimension(170,22))
jPanPostAtomHead.setMaximumSize(Dimension(170,22))
jPanPostAtomHead.setPreferredSize(Dimension(170,22))
jPanPostAtomHead.setBackground(Color(0.1,0.1,0.1))
jPanPostAtomHead.setForeground(Color(1,1,1))
set(jPanPostAtomHead,'Border',border.MatteBorder(1,1,1,1,Color(0.85,0.85,0.85)))
jPanPostAtomAdv.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.atomAdv.postHeader = jPanPostAtomHead;

% Create options to insert an offset in atomcounting
jPanOffset = JPanel(GridBagLayout);
jPanOffset.setBackground(Color(0.85,0.85,0.85))
jTextOffset = JTextField;
set(jTextOffset,'Text','Counting offset:');
jTextOffset.setAlignmentX(Component.LEFT_ALIGNMENT);
jTextOffset.setEditable(false)
jTextOffset.setBackground(Color(0.85,0.85,0.85))
set(jTextOffset,'Border',border.LineBorder(Color(0.85,0.85,0.85),1,false))
jTextOffset.setSize(Dimension(100,20));jTextOffset.setPreferredSize(Dimension(100, 20));jTextOffset.setMaximumSize(Dimension(100, 20));
jTextOffset.setToolTipText('Define the offset in the atom counting results')
jPanOffset.add(jTextOffset);
jOffset = JTextField;
set(jOffset,'Text','0');
jOffset.setSize(Dimension(58,18));jOffset.setPreferredSize(Dimension(58, 18));jOffset.setMaximumSize(Dimension(58, 18));
jOffset.setEnabled(false)
jOffset.setToolTipText('Define the offset in the atom counting results')
jPanOffset.add(jOffset);
jPanPostAtomAdv.add(jPanOffset); 
jPanPostAtomAdv.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.atomAdv.offsetPan = jPanOffset;
h.left.ana.panel.atomAdv.offsetText = jTextOffset;
h.left.ana.panel.atomAdv.offset = jOffset;

% Create options change the selected minimum
jPanMinICL = JPanel(GridBagLayout);
jPanMinICL.setBackground(Color(0.85,0.85,0.85))
jMinICL = JButton();
set(jMinICL,'Text','Select new ICL minimum');
jMinICL.setEnabled(false)
jMinICL.setMargin(Insets(0,0,0,0))
jMinICL.setBackground(Color(0.85,0.85,0.85))
jMinICL.setFocusable(false)
jPanMinICL.add(jMinICL);
jMinICL.setSize(java.awt.Dimension(160, 20));jMinICL.setPreferredSize(Dimension(160, 20));jMinICL.setMaximumSize(Dimension(160, 20));
jPanPostAtomAdv.add(jPanMinICL); % Add jButton to a JPanel
jPanPostAtomAdv.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.atomAdv.minICLPan = jPanMinICL;
h.left.ana.panel.atomAdv.minICL = jMinICL;

% Create options to load library values
jPanLib = JPanel(GridBagLayout);
jPanLib.setBackground(Color(0.85,0.85,0.85))
jLibBut = JButton();
set(jLibBut,'Text','Load library values');
jLibBut.setEnabled(false)
jLibBut.setMargin(Insets(0,0,0,0))
jLibBut.setBackground(Color(0.85,0.85,0.85))
jLibBut.setFocusable(false)
jPanLib.add(jLibBut);
jLibBut.setSize(java.awt.Dimension(160, 20));jLibBut.setPreferredSize(Dimension(160, 20));jLibBut.setMaximumSize(Dimension(160, 20));
jPanPostAtomAdv.add(jPanLib); % Add jButton to a JPanel
jPanPostAtomAdv.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.atomAdv.incLibPan = jPanLib;
h.left.ana.panel.atomAdv.incLib = jLibBut;

% Add the panel to the main panel
h.left.ana.panel.atomAdv.main = jPanAtomAdv;
jpanAna.add(h.left.ana.panel.atomAdv.main);


% %% Panel for strain measurements
% % Create to include all advanced options
% jPanStrain = JPanel;
% jPanStrain.setLayout(BoxLayout(jPanStrain, BoxLayout.Y_AXIS));
% jPanStrain.setSize(Dimension(170,94));jPanStrain.setPreferredSize(Dimension(170,94));jPanStrain.setMaximumSize(Dimension(170,94))
% jPanStrain.setAlignmentX(Component.LEFT_ALIGNMENT);
% jPanStrain.setBackground(Color(0.8,0.8,0.8))
% set(jPanStrain,'Border',border.MatteBorder(2,1,1,1,Color(0.95,0.95,0.95)))
% 
% % Create a text box indicating the purpose of the buttons
% jEditStrain = JTextField;
% jEditStrain.setAlignmentX(0.5);
% jPanStrain.add(jEditStrain);
% jEditStrain.setText('+ Strain mapping')
% jEditStrain.setEditable(false)
% jEditStrain.setFocusable(false)
% jEditStrain.setSize(Dimension(170,22))
% jEditStrain.setMaximumSize(Dimension(170,22))
% jEditStrain.setPreferredSize(Dimension(170,22))
% jEditStrain.setBackground(Color(0.7,0.7,0.7))
% jPanStrain.add(Box.createRigidArea(Dimension(0,1)));
% % Reference
% h.left.ana.panels.strain.text = jEditStrain;
% 
% % Add the panel to the main panel
% h.left.ana.panel.strain.main = jPanStrain;
% jpanAna.add(h.left.ana.panel.strain.main);

%% Add scrollbar to panel and update GUI
% set(jpan,'Border',border.LineBorder(Color(0.95,0.95,0.95),1,false))
jscrollpane=JScrollPane(jpanAna); % Add jPanels to a JScrollPane
jscrollpane.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED)

% Javacomponent adds the requested component as a child of the requested 
% parent container and wraps it in a Matlab Handle-Graphics container
[jj,hh]=javacomponent(jscrollpane,[0 0 1 1],h.left.ana.tab);
set(jj,'Border',border.LineBorder(Color(0.95,0.95,0.95),1,false))
set(hh,'units','normalized','Position',[0 0 1 1])
set(jj,'MouseMovedCallback',{@cursorArrow,h.fig})

h.left.ana.jmain = jj;
h.left.ana.main = hh;