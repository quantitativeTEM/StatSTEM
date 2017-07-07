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

%% Width determined by mac or pc
if ispc
    font = javax.swing.plaf.FontUIResource('Segoe UI',java.awt.Font.PLAIN,12);
else
    font = java.awt.Font('Lucida Grande',java.awt.Font.PLAIN,12);
end

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
jPanAtom.setSize(Dimension(168,92));jPanAtom.setPreferredSize(Dimension(168,92));jPanAtom.setMaximumSize(Dimension(168,92))
jPanAtom.setAlignmentX(Component.LEFT_ALIGNMENT);
jPanAtom.setBackground(Color(0.7,0.7,0.7))
% set(jPanAtom,'Border',border.LineBorder(Color(0.95,0.95,0.95),1,false))
set(jPanAtom,'Border',border.MatteBorder(1,1,1,1,Color(0.3,0.3,0.3)))

% Create a text box indicating the purpose of the buttons
jEditAtom = JTextField;
jEditAtom.setAlignmentX(0.5);
jPanAtom.add(jEditAtom);
jEditAtom.setText('+ Atom counting - Statistical')
jEditAtom.setToolTipText('Atom counting - Statistical method')
jEditAtom.setFont(font);
jEditAtom.setEditable(false)
jEditAtom.setFocusable(false)
jEditAtom.setSize(Dimension(168,22))
jEditAtom.setMaximumSize(Dimension(168,22))
jEditAtom.setPreferredSize(Dimension(168,22))
jEditAtom.setBackground(Color(0.3,0.3,0.3))
jEditAtom.setForeground(Color(1,1,1))
jPanAtom.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.atom.text = jEditAtom;

% Button for running the routine
jRunICL = JPanel(GridLayout(1,1));
jRunICLBut = JButton();
set(jRunICLBut,'Text','Run ICL')
jRunICLBut.setFont(font);
jRunICLBut.setEnabled(false)
jRunICLBut.setFocusable(false)
jRunICLBut.setBackground(Color(0.7,0.7,0.7))
jRunICL.add(jRunICLBut);
jRunICL.setSize(java.awt.Dimension(168, 22));
jRunICL.setPreferredSize(Dimension(168, 22));
jRunICL.setMaximumSize(Dimension(168, 22));
set(jRunICL,'Border',border.LineBorder(Color(0.7,0.7,0.7),1,false))
jRunICL.setBackground(Color(0.7,0.7,0.7))
jPanAtom.add(jRunICL); % Add jButton to a JPanel
% jPanAtom.add(Box.createRigidArea(Dimension(0,2)));
% Reference
h.left.ana.panel.atom.PanRun = jRunICL;
h.left.ana.panel.atom.runBut =jRunICLBut;

% Button for aborting the routine
jAbortICL = JPanel(GridLayout(1,1));
jAbortICLBut = JButton();
set(jAbortICLBut,'Text','Stop ICL')
jAbortICLBut.setFont(font);
jAbortICLBut.setBackground(Color(0.7,0.7,0.7))
jAbortICLBut.setFocusable(false)
jAbortICLBut.setEnabled(false)
jAbortICL.add(jAbortICLBut);
jAbortICL.setSize(java.awt.Dimension(168, 22));
jAbortICL.setPreferredSize(Dimension(168, 22));
jAbortICL.setMaximumSize(Dimension(168, 22));
set(jAbortICL,'Border',border.LineBorder(Color(0.7,0.7,0.7),1,false))
jAbortICL.setBackground(Color(0.7,0.7,0.7))
jPanAtom.add(jAbortICL); % Add jButton to a JPanel
jPanAtom.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.atom.PanAbort = jAbortICL;
h.left.ana.panel.atom.AbortBut =jAbortICLBut;

% Button for showing advanced options
jAdvButPan = JPanel(GridLayout(1,1));
jAdvBut = JCheckBox('Selected',false);
set(jAdvBut,'Text','Show options')
jAdvBut.setFont(font);
jAdvBut.setBackground(Color(0.7,0.7,0.7))
jAdvBut.setFocusable(false)
jAdvButPan.add(jAdvBut);
jAdvButPan.setSize(java.awt.Dimension(168, 22));
jAdvButPan.setPreferredSize(Dimension(168, 22));
jAdvButPan.setMaximumSize(Dimension(168, 22));
set(jAdvButPan,'Border',border.LineBorder(Color(0.7,0.7,0.7),1,false))
jAdvButPan.setBackground(Color(0.7,0.7,0.7))
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
jPanAtomAdv.setSize(Dimension(168,186));jPanAtomAdv.setPreferredSize(Dimension(168,186));jPanAtomAdv.setMaximumSize(Dimension(168,186))
jPanAtomAdv.setAlignmentX(Component.LEFT_ALIGNMENT);
jPanAtomAdv.setBackground(Color(0.95,0.95,0.95))
set(jPanAtomAdv,'Border',border.MatteBorder(0,1,1,1,Color(0.3,0.3,0.3)))
jPanAtomAdv.add(Box.createRigidArea(Dimension(0,1)));

% The pre analysis advanced options panel
jPanPreAtomAdv = JPanel;
jPanPreAtomAdv.setLayout(BoxLayout(jPanPreAtomAdv, BoxLayout.Y_AXIS));
jPanPreAtomAdv.setSize(Dimension(168,112));jPanPreAtomAdv.setPreferredSize(Dimension(168,112));jPanPreAtomAdv.setMaximumSize(Dimension(168,112))
% jPanPreAtomAdv.setAlignmentX(Component.LEFT_ALIGNMENT);
jPanPreAtomAdv.setBackground(Color(0.95,0.95,0.95))
set(jPanPreAtomAdv,'Border',border.MatteBorder(0,0,0,0,Color(0.7,0.7,0.7)))
jPanAtomAdv.add(jPanPreAtomAdv);
jPanAtomAdv.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.atomAdv.prePan = jPanPreAtomAdv;

% The header
jPanPreAtomHead = JTextField;
jPanPreAtomHead.setAlignmentX(0.5);
jPanPreAtomAdv.add(jPanPreAtomHead);
jPanPreAtomHead.setText(' Pre-analysis options')
jPanPreAtomHead.setFont(font);
jPanPreAtomHead.setEditable(false)
jPanPreAtomHead.setFocusable(false)
jPanPreAtomHead.setSize(Dimension(168,22))
jPanPreAtomHead.setMaximumSize(Dimension(168,22))
jPanPreAtomHead.setPreferredSize(Dimension(168,22))
jPanPreAtomHead.setBackground(Color(0,0,0))
jPanPreAtomHead.setForeground(Color(1,1,1))
set(jPanPreAtomHead,'Border',border.MatteBorder(2,2,0,2,Color(0.95,0.95,0.95)))
jPanPreAtomAdv.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.atomAdv.preHeader = jPanPreAtomHead;

% Create options to limit the maximum number of components that will be
% estimated
jPanMaxNum = JPanel(GridBagLayout);
jPanMaxNum.setBackground(Color(0.95,0.95,0.95))
jTextMaxNum = JTextField;
set(jTextMaxNum,'Text','Max components:');
jTextMaxNum.setFont(font);
jTextMaxNum.setAlignmentX(Component.LEFT_ALIGNMENT);
jTextMaxNum.setEditable(false)
jTextMaxNum.setBackground(Color(0.95,0.95,0.95))
set(jTextMaxNum,'Border',border.LineBorder(Color(0.95,0.95,0.95),1,false))
jTextMaxNum.setSize(Dimension(100,20));jTextMaxNum.setPreferredSize(Dimension(100, 20));jTextMaxNum.setMaximumSize(Dimension(100, 20));
jTextMaxNum.setToolTipText('Define the maximum number of components to estimate')
jPanMaxNum.add(jTextMaxNum);
jMaxVal = JTextField;
set(jMaxVal,'Text','50');
jMaxVal.setFont(font);
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
jPanSelColImg.setBackground(Color(0.95,0.95,0.95))
jSelColImage = JButton();
set(jSelColImage,'Text','Select columns in image')
jSelColImage.setFont(font);
jSelColImage.setEnabled(false)
jSelColImage.setMargin(Insets(0,0,0,0))
jSelColImage.setBackground(Color(0.95,0.95,0.95))

jSelColImage.setFocusable(false)
jPanSelColImg.add(jSelColImage);
jSelColImage.setSize(java.awt.Dimension(160, 20));jSelColImage.setPreferredSize(Dimension(160, 20));jSelColImage.setMaximumSize(Dimension(160, 20));
jPanPreAtomAdv.add(jPanSelColImg); % Add jButton to a JPanel
jPanPreAtomAdv.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.atomAdv.selColPan = jPanSelColImg;
h.left.ana.panel.atomAdv.selCol = jSelColImage;

% Create buttons to select and deselect columns
jPanSelColHist = JPanel(GridBagLayout);
jPanSelColHist.setBackground(Color(0.95,0.95,0.95))
jSelColHist = JButton();
set(jSelColHist,'Text','Select columns in histgram')
jSelColHist.setToolTipText('Select columns in histogram')
jSelColHist.setFont(font);
jSelColHist.setEnabled(false)
jSelColHist.setMargin(Insets(0,0,0,0))
jSelColHist.setBackground(Color(0.95,0.95,0.95))
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
jPanSelColType.setBackground(Color(0.95,0.95,0.95))
jSelColType = JButton();
set(jSelColType,'Text','Select columns on type')
jSelColType.setFont(font);
jSelColType.setEnabled(false)
jSelColType.setMargin(Insets(0,0,0,0))
jSelColType.setBackground(Color(0.95,0.95,0.95))
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
jPanPostAtomAdv.setSize(Dimension(170,70));jPanPostAtomAdv.setPreferredSize(Dimension(170,70));jPanPostAtomAdv.setMaximumSize(Dimension(170,70))
% jPanPreAtomAdv.setAlignmentX(Component.LEFT_ALIGNMENT);
jPanPostAtomAdv.setBackground(Color(0.85,0.85,0.85))
set(jPanPostAtomAdv,'Border',border.MatteBorder(0,0,0,0,Color(0.7,0.7,0.7)))
jPanAtomAdv.add(jPanPostAtomAdv);
jPanAtomAdv.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.atomAdv.postPan = jPanPostAtomAdv;

% The header
jPanPostAtomHead = JTextField;
jPanPostAtomHead.setAlignmentX(0.5);
jPanPostAtomAdv.add(jPanPostAtomHead);
jPanPostAtomHead.setText(' Post-analysis options')
jPanPostAtomHead.setFont(font);
jPanPostAtomHead.setEditable(false)
jPanPostAtomHead.setFocusable(false)
jPanPostAtomHead.setSize(Dimension(168,22))
jPanPostAtomHead.setMaximumSize(Dimension(168,22))
jPanPostAtomHead.setPreferredSize(Dimension(168,22))
jPanPostAtomHead.setBackground(Color(0.1,0.1,0.1))
jPanPostAtomHead.setForeground(Color(1,1,1))
set(jPanPostAtomHead,'Border',border.MatteBorder(3,2,0,2,Color(0.85,0.85,0.85)))
jPanPostAtomAdv.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.atomAdv.postHeader = jPanPostAtomHead;

% Create options to insert an offset in atomcounting
jPanOffset = JPanel(GridBagLayout);
jPanOffset.setBackground(Color(0.85,0.85,0.85))
jTextOffset = JTextField;
set(jTextOffset,'Text','Counting offset:');
jTextOffset.setFont(font);
jTextOffset.setAlignmentX(Component.LEFT_ALIGNMENT);
jTextOffset.setEditable(false)
jTextOffset.setBackground(Color(0.85,0.85,0.85))
set(jTextOffset,'Border',border.LineBorder(Color(0.85,0.85,0.85),1,false))
jTextOffset.setSize(Dimension(100,20));jTextOffset.setPreferredSize(Dimension(100, 20));jTextOffset.setMaximumSize(Dimension(100, 20));
jTextOffset.setToolTipText('Define the offset in the atom counting results')
jPanOffset.add(jTextOffset);
jOffset = JTextField;
set(jOffset,'Text','0');
jOffset.setFont(font);
jOffset.setSize(Dimension(56,18));jOffset.setPreferredSize(Dimension(56, 18));jOffset.setMaximumSize(Dimension(56, 18));
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
jMinICL.setFont(font);
jMinICL.setEnabled(false)
jMinICL.setMargin(Insets(0,0,0,0))
jMinICL.setBackground(Color(0.85,0.85,0.85))
jMinICL.setFocusable(false)
jPanMinICL.add(jMinICL);
jMinICL.setSize(java.awt.Dimension(160, 20));jMinICL.setPreferredSize(Dimension(160, 20));jMinICL.setMaximumSize(Dimension(160, 20));
jPanPostAtomAdv.add(jPanMinICL); % Add jButton to a JPanel
% jPanPostAtomAdv.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.atomAdv.minICLPan = jPanMinICL;
h.left.ana.panel.atomAdv.minICL = jMinICL;

% Add the panel to the main panel
h.left.ana.panel.atomAdv.main = jPanAtomAdv;
jpanAna.add(h.left.ana.panel.atomAdv.main);
h.left.ana.panel.atomAdv.main.setVisible(0);

%% Panel for atomcounting by library
% Create to include all 
jPanACL = JPanel;
jPanACL.setLayout(BoxLayout(jPanACL, BoxLayout.Y_AXIS));
jPanACL.setSize(Dimension(168,71));jPanACL.setPreferredSize(Dimension(168,71));jPanACL.setMaximumSize(Dimension(168,71))
jPanACL.setAlignmentX(Component.LEFT_ALIGNMENT);
jPanACL.setBackground(Color(0.7,0.7,0.7))
% set(jPanAtom,'Border',border.LineBorder(Color(0.95,0.95,0.95),1,false))
set(jPanACL,'Border',border.MatteBorder(1,1,1,1,Color(0.3,0.3,0.3)))

% Create a text box indicating the purpose of the buttons
jEditACL = JTextField;
jEditACL.setAlignmentX(0.5);
jPanACL.add(jEditACL);
jEditACL.setText('+ Atom counting - Simulation')
jEditACL.setToolTipText('Atom counting - Simulation method')
jEditACL.setFont(font);
jEditACL.setEditable(false)
jEditACL.setFocusable(false)
jEditACL.setSize(Dimension(168,22))
jEditACL.setMaximumSize(Dimension(168,22))
jEditACL.setPreferredSize(Dimension(168,22))
jEditACL.setBackground(Color(0.3,0.3,0.3))
jEditACL.setForeground(Color(1,1,1))
jPanACL.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.acl.text = jEditACL;

% Create options to load library values
jPanLib = JPanel(GridLayout(1,1));
jPanLib.setBackground(Color(0.8,0.8,0.8))
jLibBut = JButton();
set(jLibBut,'Text','Load library values');
jLibBut.setFont(font);
jLibBut.setEnabled(false)
% jLibBut.setMargin(Insets(0,0,0,0))
jLibBut.setBackground(Color(0.7,0.7,0.7))
jLibBut.setFocusable(false)
jPanLib.add(jLibBut);
jPanLib.setSize(java.awt.Dimension(168, 22));jPanLib.setPreferredSize(Dimension(168, 22));jPanLib.setMaximumSize(Dimension(168, 22));
set(jPanLib,'Border',border.LineBorder(Color(0.7,0.7,0.7),1,false))
jPanACL.add(jPanLib); % Add jButton to a JPanel
jPanACL.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.acl.incLibPan = jPanLib;
h.left.ana.panel.acl.incLib = jLibBut;

% Create options to match scattering cross-sections with library values
jPanMatchSCS = JPanel(GridLayout(1,1));
jPanMatchSCS.setBackground(Color(0.7,0.7,0.7))
jMatchSCSBut = JButton();
set(jMatchSCSBut,'Text','Match with simulations');
jMatchSCSBut.setFont(font);
jMatchSCSBut.setEnabled(false)
% jLibBut.setMargin(Insets(0,0,0,0))
jMatchSCSBut.setBackground(Color(0.7,0.7,0.7))
jMatchSCSBut.setFocusable(false)
jPanMatchSCS.add(jMatchSCSBut);
jPanMatchSCS.setSize(java.awt.Dimension(168, 22));jPanMatchSCS.setPreferredSize(Dimension(168, 22));jPanMatchSCS.setMaximumSize(Dimension(168, 22));
set(jPanMatchSCS,'Border',border.LineBorder(Color(0.7,0.7,0.7),1,false))
jPanACL.add(jPanMatchSCS); % Add jButton to a JPanel
jPanACL.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.acl.matchPan = jPanMatchSCS;
h.left.ana.panel.acl.matchSCS = jMatchSCSBut;

% Add the panel to the main panel
jpanAna.add(Box.createRigidArea(Dimension(0,4)));
h.left.ana.panel.acl.main = jPanACL;
jpanAna.add(h.left.ana.panel.acl.main);

%% Panel for strain measurements
% Create to include all advanced options
jPanStrain = JPanel;
jPanStrain.setLayout(BoxLayout(jPanStrain, BoxLayout.Y_AXIS));
jPanStrain.setSize(Dimension(168,117));jPanStrain.setPreferredSize(Dimension(168,117));jPanStrain.setMaximumSize(Dimension(168,117))
jPanStrain.setAlignmentX(Component.LEFT_ALIGNMENT);
jPanStrain.setBackground(Color(0.7,0.7,0.7))
set(jPanStrain,'Border',border.MatteBorder(1,1,1,1,Color(0.3,0.3,0.3)))

% Create a text box indicating the purpose of the buttons
jEditStrain = JTextField;
jEditStrain.setAlignmentX(0.5);
jPanStrain.add(jEditStrain);
jEditStrain.setText('+ Strain mapping')
jEditStrain.setFont(font);
jEditStrain.setEditable(false)
jEditStrain.setFocusable(false)
jEditStrain.setSize(Dimension(168,22))
jEditStrain.setMaximumSize(Dimension(168,22))
jEditStrain.setPreferredSize(Dimension(168,22))
jEditStrain.setBackground(Color(0.3,0.3,0.3))
jEditStrain.setForeground(Color(1,1,1))
jPanStrain.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.strain.text = jEditStrain;

% Create options to load projected unit cell
jPanPUC = JPanel(GridLayout(1,1));
jPanPUC.setBackground(Color(0.8,0.8,0.8))
jPUCBut = JButton();
set(jPUCBut,'Text','Projected unit cell');
jPUCBut.setToolTipText('Select a projected unit cell with its properties')
jPUCBut.setFont(font);
jPUCBut.setEnabled(false)
% jLibBut.setMargin(Insets(0,0,0,0))
jPUCBut.setBackground(Color(0.7,0.7,0.7))
jPUCBut.setFocusable(false)
jPanPUC.add(jPUCBut);
jPanPUC.setSize(java.awt.Dimension(168, 22));jPanPUC.setPreferredSize(Dimension(168, 22));jPanPUC.setMaximumSize(Dimension(168, 22));
set(jPanPUC,'Border',border.LineBorder(Color(0.7,0.7,0.7),1,false))
jPanStrain.add(jPanPUC); % Add jButton to a JPanel
jPanStrain.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.strain.panPUC = jPanPUC;
h.left.ana.panel.strain.loadPUC = jPUCBut;

% Create button to make a displacement map
jPanDisp = JPanel(GridLayout(1,1));
jPanDisp.setBackground(Color(0.8,0.8,0.8))
jDispBut = JButton();
set(jDispBut,'Text','Make displacement map');
jDispBut.setToolTipText('Make a displacement map')
jDispBut.setFont(font);
jDispBut.setEnabled(false)
% jLibBut.setMargin(Insets(0,0,0,0))
jDispBut.setBackground(Color(0.7,0.7,0.7))
jDispBut.setFocusable(false)
jPanDisp.add(jDispBut);
jPanDisp.setSize(java.awt.Dimension(168, 22));jPanDisp.setPreferredSize(Dimension(168, 22));jPanDisp.setMaximumSize(Dimension(168, 22));
set(jPanDisp,'Border',border.LineBorder(Color(0.7,0.7,0.7),1,false))
jPanStrain.add(jPanDisp); % Add jButton to a JPanel
jPanStrain.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.strain.panDisp = jPanDisp;
h.left.ana.panel.strain.makeDisp = jDispBut;

% Create button to make a strain map
jPanStrainMap = JPanel(GridLayout(1,1));
jPanStrainMap.setBackground(Color(0.7,0.7,0.7))
jStrainBut = JButton();
set(jStrainBut,'Text','Make strain map');
jStrainBut.setToolTipText('Make a strain map')
jStrainBut.setFont(font);
jStrainBut.setEnabled(false)
% jLibBut.setMargin(Insets(0,0,0,0))
jStrainBut.setBackground(Color(0.7,0.7,0.7))
jStrainBut.setFocusable(false)
jPanStrainMap.add(jStrainBut);
jPanStrainMap.setSize(java.awt.Dimension(168, 22));jPanStrainMap.setPreferredSize(Dimension(168, 22));jPanStrainMap.setMaximumSize(Dimension(168, 22));
set(jPanStrainMap,'Border',border.LineBorder(Color(0.7,0.7,0.7),1,false))
jPanStrain.add(jPanStrainMap); % Add jButton to a JPanel
jPanStrain.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.strain.panStrain = jPanStrainMap;
h.left.ana.panel.strain.strainBut = jStrainBut;

% Create togglebutton to show options
jPanOptStrain = JPanel(GridLayout(1,1));
jPanOptStrain.setBackground(Color(0.7,0.7,0.7))
jOptStrainBut = JCheckBox('Selected',false);
set(jOptStrainBut,'Text','Show options');
jOptStrainBut.setFont(font);
jOptStrainBut.setEnabled(true)
jOptStrainBut.setBackground(Color(0.7,0.7,0.7))
jOptStrainBut.setFocusable(false)
jPanOptStrain.add(jOptStrainBut);
jPanOptStrain.setSize(java.awt.Dimension(168, 22));jPanOptStrain.setPreferredSize(Dimension(168, 22));jPanOptStrain.setMaximumSize(Dimension(168, 22));
set(jPanOptStrain,'Border',border.LineBorder(Color(0.7,0.7,0.7),1,false))
jPanStrain.add(jPanOptStrain); % Add jButton to a JPanel
jPanStrain.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.strain.panOptions = jPanOptStrain;
h.left.ana.panel.strain.optBut = jOptStrainBut;

% Add the panel to the main panel
jpanAna.add(Box.createRigidArea(Dimension(0,4)));
h.left.ana.panel.strain.main = jPanStrain;
jpanAna.add(h.left.ana.panel.strain.main);

%% Advanced options strain mapping
% Create to include all advanced options
jPanStrainAdv = JPanel;
jPanStrainAdv.setLayout(BoxLayout(jPanStrainAdv, BoxLayout.Y_AXIS));
jPanStrainAdv.setSize(Dimension(168,302));jPanStrainAdv.setPreferredSize(Dimension(168,302));jPanStrainAdv.setMaximumSize(Dimension(168,302))
jPanStrainAdv.setAlignmentX(Component.LEFT_ALIGNMENT);
jPanStrainAdv.setBackground(Color(0.95,0.95,0.95))
jPanStrainAdv.setVisible(0)
set(jPanStrainAdv,'Border',border.MatteBorder(0,1,1,1,Color(0.3,0.3,0.3)))
jPanStrainAdv.add(Box.createRigidArea(Dimension(0,1)));

% Option panel for selecting coordinates
jPanGenOpt = JPanel;
jPanGenOpt.setLayout(BoxLayout(jPanGenOpt, BoxLayout.Y_AXIS));
jPanGenOpt.setSize(Dimension(168,42));jPanGenOpt.setPreferredSize(Dimension(168,42));jPanGenOpt.setMaximumSize(Dimension(168,42))
jPanGenOpt.setBackground(Color(0.95,0.95,0.95))
set(jPanGenOpt,'Border',border.MatteBorder(0,0,0,0,Color(0.7,0.7,0.7)))
jPanStrainAdv.add(jPanGenOpt);
jPanStrainAdv.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.strainAdv.genPan = jPanGenOpt;

% The header
jPanGenHead = JTextField;
jPanGenHead.setAlignmentX(0.5);
jPanGenOpt.add(jPanGenHead);
jPanGenHead.setText(' General options')
jPanGenHead.setFont(font);
jPanGenHead.setEditable(false)
jPanGenHead.setFocusable(false)
jPanGenHead.setSize(Dimension(168,22))
jPanGenHead.setMaximumSize(Dimension(168,22))
jPanGenHead.setPreferredSize(Dimension(168,22))
jPanGenHead.setBackground(Color(0,0,0))
jPanGenHead.setForeground(Color(1,1,1))
set(jPanGenHead,'Border',border.MatteBorder(2,2,0,2,Color(0.95,0.95,0.95)))
jPanGenOpt.add(Box.createRigidArea(Dimension(0,2)));
% Reference
h.left.ana.panel.strainAdv.genHeader = jPanGenHead;

% Create buttons to select and deselect columns
jPanSelColStr = JPanel(GridBagLayout);
jPanSelColStr.setBackground(Color(0.95,0.95,0.95))
jSelColStr = JButton();
set(jSelColStr,'Text','Select columns in image')
jSelColStr.setFont(font);
jSelColStr.setEnabled(false)
jSelColStr.setMargin(Insets(0,0,0,0))
jSelColStr.setBackground(Color(0.95,0.95,0.95))
jSelColStr.setFocusable(false)
jPanSelColStr.add(jSelColStr);
jSelColStr.setSize(java.awt.Dimension(160, 20));jSelColStr.setPreferredSize(Dimension(160, 20));jSelColStr.setMaximumSize(Dimension(160, 20));
jPanGenOpt.add(jPanSelColStr); % Add jButton to a JPanel
jPanGenOpt.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.strainAdv.genColPan = jPanSelColStr;
h.left.ana.panel.strainAdv.selCol = jSelColStr;

%% Advanced option strain mapping reference coordinate
% Option panel for reference coordinate
jPanRefCoor = JPanel;
jPanRefCoor.setLayout(BoxLayout(jPanRefCoor, BoxLayout.Y_AXIS));
jPanRefCoor.setSize(Dimension(168,95));jPanRefCoor.setPreferredSize(Dimension(168,95));jPanRefCoor.setMaximumSize(Dimension(168,95))
% jPanPreAtomAdv.setAlignmentX(Component.LEFT_ALIGNMENT);
jPanRefCoor.setBackground(Color(0.85,0.85,0.85))
set(jPanRefCoor,'Border',border.MatteBorder(0,0,0,0,Color(0.7,0.7,0.7)))
jPanStrainAdv.add(jPanRefCoor);
jPanStrainAdv.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.strainAdv.refPan = jPanRefCoor;

% The header
jPanRefHead = JTextField;
jPanRefHead.setAlignmentX(0.5);
jPanRefCoor.add(jPanRefHead);
jPanRefHead.setText(' Reference coordinate')
jPanRefHead.setFont(font);
jPanRefHead.setEditable(false)
jPanRefHead.setFocusable(false)
jPanRefHead.setSize(Dimension(168,22))
jPanRefHead.setMaximumSize(Dimension(168,22))
jPanRefHead.setPreferredSize(Dimension(168,22))
jPanRefHead.setBackground(Color(0,0,0))
jPanRefHead.setForeground(Color(1,1,1))
set(jPanRefHead,'Border',border.MatteBorder(2,2,0,2,Color(0.85,0.85,0.85)))
jPanRefCoor.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.strainAdv.refHeader = jPanRefHead;

% Option to change the type of the reference coordinate
jPanType = JPanel(GridBagLayout);
jPanType.setBackground(Color(0.85,0.85,0.85));
jTypeText = JTextField;
jTypeText.setAlignmentX(0.5);
jPanType.add(jTypeText);
jTypeText.setText('Type:');
jTypeText.setFont(font);
jTypeText.setEditable(false)
jTypeText.setFocusable(false)
jTypeText.setSize(Dimension(100,22))
jTypeText.setMaximumSize(Dimension(100,22))
jTypeText.setPreferredSize(Dimension(100,22))
jTypeText.setBackground(Color(0.85,0.85,0.85))
set(jTypeText,'Border',border.LineBorder(Color(0.85,0.85,0.85),1,false))
jTypeSel = JComboBox;
jTypeSel.setBackground(Color(0.85,0.85,0.85))
jTypeSel.setEnabled(false)
jTypeSel.setFocusable(false)
jTypeSel.setModel(javax.swing.DefaultComboBoxModel({'1'}))
jTypeSel.setSize(Dimension(58,18));jTypeSel.setPreferredSize(Dimension(58,18));jTypeSel.setMaximumSize(Dimension(58,18));
jPanType.add(jTypeSel);
jPanRefCoor.add(jPanType);
jPanRefCoor.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.strainAdv.selType = jTypeSel;

% Option to define reference coordinate
jPanCenCoor = JPanel(GridBagLayout);
jPanCenCoor.setBackground(Color(0.85,0.85,0.85));
jCheckCenCoor = JRadioButton('Selected',true);
set(jCheckCenCoor,'Text','Most central');
jCheckCenCoor.setFont(font);
jCheckCenCoor.setEnabled(false);
jCheckCenCoor.setBackground(Color(0.85,0.85,0.85))
jCheckCenCoor.setFocusable(false);
set(jCheckCenCoor,'Border',border.LineBorder(Color(0.85,0.85,0.85),1,false))
jCheckCenCoor.setSize(Dimension(100,20));jCheckCenCoor.setPreferredSize(Dimension(100, 20));jCheckCenCoor.setMaximumSize(Dimension(100, 20));
jPanCenCoor.add(jCheckCenCoor);
jShowCenCoor = JButton();
set(jShowCenCoor,'Text','Show');
jShowCenCoor.setFont(font);
jShowCenCoor.setAlignmentX(0.5);
jShowCenCoor.setToolTipText('Show the most central coordinate that will be used for the strain mapping')
jShowCenCoor.setEnabled(false)
jShowCenCoor.setMargin(Insets(0,0,0,0))
jShowCenCoor.setBackground(Color(0.85,0.85,0.85))
jShowCenCoor.setFocusable(false)
jPanCenCoor.add(jShowCenCoor);
jShowCenCoor.setSize(Dimension(58,20))
jShowCenCoor.setMaximumSize(Dimension(58,20))
jShowCenCoor.setPreferredSize(Dimension(58,20))
jPanRefCoor.add(jPanCenCoor);
jPanRefCoor.add(Box.createRigidArea(Dimension(0,1)));
jPanUsrCoor = JPanel(GridBagLayout);
jPanUsrCoor.setBackground(Color(0.85,0.85,0.85));
jUsrCoor = JRadioButton('Selected',false);
set(jUsrCoor,'Text','User defined');
jUsrCoor.setFont(font);
jUsrCoor.setEnabled(false);
jUsrCoor.setBackground(Color(0.85,0.85,0.85))
jUsrCoor.setFocusable(false);
set(jUsrCoor,'Border',border.LineBorder(Color(0.85,0.85,0.85),1,false))
jUsrCoor.setSize(Dimension(100,20));jUsrCoor.setPreferredSize(Dimension(100, 20));jUsrCoor.setMaximumSize(Dimension(100, 20));
jPanUsrCoor.add(jUsrCoor);
jSelCoor = JButton();
set(jSelCoor,'Text','Select');
jSelCoor.setFont(font);
jSelCoor.setAlignmentX(0.5);
jSelCoor.setToolTipText('Select the coordinate that will be used for the strain mapping')
jSelCoor.setEnabled(false)
jSelCoor.setMargin(Insets(0,0,0,0))
jSelCoor.setBackground(Color(0.85,0.85,0.85))
jSelCoor.setFocusable(false)
jPanUsrCoor.add(jSelCoor);
jSelCoor.setSize(Dimension(58,20))
jSelCoor.setMaximumSize(Dimension(58,20))
jSelCoor.setPreferredSize(Dimension(58,20))
jPanRefCoor.add(jPanUsrCoor);
jPanRefCoor.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.strainAdv.cenCoor = jCheckCenCoor;
h.left.ana.panel.strainAdv.showCen = jShowCenCoor;
h.left.ana.panel.strainAdv.usrCoor = jUsrCoor;
h.left.ana.panel.strainAdv.selectCoor = jSelCoor;

%% The a lattice direction panel
jPanAlat = JPanel;
jPanAlat.setLayout(BoxLayout(jPanAlat, BoxLayout.Y_AXIS));
jPanAlat.setSize(Dimension(168,160));jPanAlat.setPreferredSize(Dimension(168,160));jPanAlat.setMaximumSize(Dimension(168,160))
% jPanPreAtomAdv.setAlignmentX(Component.LEFT_ALIGNMENT);
jPanAlat.setBackground(Color(0.95,0.95,0.95))
set(jPanAlat,'Border',border.MatteBorder(0,0,0,0,Color(0.7,0.7,0.7)))
jPanStrainAdv.add(jPanAlat);
jPanStrainAdv.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.strainAdv.aLatPan = jPanAlat;

% The header
jALatHead = JTextField;
jALatHead.setAlignmentX(0.5);
jPanAlat.add(jALatHead);
jALatHead.setText(' Direction a lattice')
jALatHead.setFont(font);
jALatHead.setEditable(false)
jALatHead.setFocusable(false)
jALatHead.setSize(Dimension(168,22))
jALatHead.setMaximumSize(Dimension(168,22))
jALatHead.setPreferredSize(Dimension(168,22))
jALatHead.setBackground(Color(0.1,0.1,0.1))
jALatHead.setForeground(Color(1,1,1))
set(jALatHead,'Border',border.MatteBorder(3,2,0,2,Color(0.95,0.95,0.95)))
jALatHead.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.strainAdv.aLatHeader = jPanPostAtomHead;

% Option to define a lattice direction
jPanALatAut = JPanel(GridBagLayout);
jPanALatAut.setBackground(Color(0.95,0.95,0.95))
jCheckALatAut = JRadioButton('Selected',true);
set(jCheckALatAut,'Text','Automatic');
jCheckALatAut.setFont(font);
jCheckALatAut.setEnabled(false);
jCheckALatAut.setBackground(Color(0.95,0.95,0.95))
jCheckALatAut.setFocusable(false);
set(jCheckALatAut,'Border',border.LineBorder(Color(0.95,0.95,0.95),1,false))
jCheckALatAut.setSize(Dimension(100,20));jCheckALatAut.setPreferredSize(Dimension(100, 20));jCheckALatAut.setMaximumSize(Dimension(100, 20));
jPanALatAut.add(jCheckALatAut);
jShowALatAut = JButton();
set(jShowALatAut,'Text','Show');
jShowALatAut.setFont(font);
jShowALatAut.setAlignmentX(0.5);
jShowALatAut.setToolTipText('Show the direction of the a and b lattice from the automatic finder')
jShowALatAut.setEnabled(false)
jShowALatAut.setMargin(Insets(0,0,0,0))
jShowALatAut.setBackground(Color(0.95,0.95,0.95))
jShowALatAut.setFocusable(false)
jPanALatAut.add(jShowALatAut);
jShowALatAut.setSize(Dimension(58,20))
jShowALatAut.setMaximumSize(Dimension(58,20))
jShowALatAut.setPreferredSize(Dimension(58,20))
jPanAlat.add(jPanALatAut);
jPanAlat.add(Box.createRigidArea(Dimension(0,1)));
jPanUsrALat = JPanel(GridBagLayout);
jPanUsrALat.setBackground(Color(0.95,0.95,0.95))
jUsrALat = JRadioButton('Selected',false);
set(jUsrALat,'Text','User defined');
jUsrALat.setFont(font);
jUsrALat.setEnabled(false);
jUsrALat.setBackground(Color(0.95,0.95,0.95))
jUsrALat.setFocusable(false);
set(jUsrALat,'Border',border.LineBorder(Color(0.95,0.95,0.95),1,false))
jUsrALat.setSize(Dimension(100,20));jUsrALat.setPreferredSize(Dimension(100, 20));jUsrALat.setMaximumSize(Dimension(100, 20));
jPanUsrALat.add(jUsrALat);
jSelALat = JButton();
set(jSelALat,'Text','Select');
jSelALat.setFont(font);
jSelALat.setAlignmentX(0.5);
jSelALat.setToolTipText('Manually select the coordinate that will be used for the strain mapping')
jSelALat.setEnabled(false)
jSelALat.setMargin(Insets(0,0,0,0))
jSelALat.setBackground(Color(0.95,0.95,0.95))
jSelALat.setFocusable(false)
jPanUsrALat.add(jSelALat);
jSelALat.setSize(Dimension(58,20))
jSelALat.setMaximumSize(Dimension(58,20))
jSelALat.setPreferredSize(Dimension(58,20))
jPanAlat.add(jPanUsrALat);
jPanAlat.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.ana.panel.strainAdv.autALat = jCheckALatAut;
h.left.ana.panel.strainAdv.showALatAut = jShowALatAut;
h.left.ana.panel.strainAdv.usrALat = jUsrALat;
h.left.ana.panel.strainAdv.selectALat = jSelALat;

% Option to improve lattice direction and angle by fitting
jPanImpFitA = JPanel(GridLayout(1,1));
jPanImpFitA.setBackground(Color(0.95,0.95,0.95))
jImpFitA = JCheckBox('Selected',true);
set(jImpFitA,'Text','Improve values by fitting');
jImpFitA.setEnabled(false)
jImpFitA.setFont(font);
jImpFitA.setBackground(Color(0.95,0.95,0.95))
jImpFitA.setFocusable(false)
jPanImpFitA.add(jImpFitA);
jPanImpFitA.setSize(java.awt.Dimension(168, 22));jPanImpFitA.setPreferredSize(Dimension(168, 22));jPanImpFitA.setMaximumSize(Dimension(168, 22));
set(jPanImpFitA,'Border',border.LineBorder(Color(0.95,0.95,0.95),1,false))
jPanAlat.add(jPanImpFitA); % Add jButton to a JPanel
jPanAlat.add(Box.createRigidArea(Dimension(0,1)));
% % Fitting option
jPanImpFitOpt = JPanel(GridBagLayout);
jPanImpFitOpt.setBackground(Color(0.95,0.95,0.95))
jImpFitOptText = JTextField;
set(jImpFitOptText,'Text','Number of UCs:');
jImpFitOptText.setEnabled(false);
jImpFitOptText.setFont(font);
jImpFitOptText.setAlignmentX(Component.LEFT_ALIGNMENT);
jImpFitOptText.setEditable(false)
jImpFitOptText.setBackground(Color(0.95,0.95,0.95))
set(jImpFitOptText,'Border',border.LineBorder(Color(0.95,0.95,0.95),1,false))
jImpFitOptText.setSize(Dimension(95,20));jImpFitOptText.setPreferredSize(Dimension(95, 20));jImpFitOptText.setMaximumSize(Dimension(95, 20));
jImpFitOptText.setToolTipText('Define the number of unit cells that will be used for fitting the angle and a- and b-lattice parameters')
jPanImpFitOpt.add(jImpFitOptText);
jImpFitOptUC = JTextField;
set(jImpFitOptUC,'Text','3');
jImpFitOptUC.setFont(font);
jImpFitOptUC.setEnabled(false)
jImpFitOptUC.setSize(Dimension(43,18));jImpFitOptUC.setPreferredSize(Dimension(43, 18));jImpFitOptUC.setMaximumSize(Dimension(43, 18));
jImpFitOptUC.setEnabled(false)
jImpFitOptUC.setToolTipText('Define the number of unit cells that will be used for fitting the angle and a- and b-lattice parameters')
jPanImpFitOpt.add(jImpFitOptUC);
jPanAlat.add(jPanImpFitOpt); 
jPanAlat.add(Box.createRigidArea(Dimension(0,1)));
% Parameter option
jPanImpFitPar = JPanel(GridBagLayout);
jPanImpFitPar.setBackground(Color(0.95,0.95,0.95))
jImpFitParAll = JRadioButton('Selected',true);
set(jImpFitParAll,'Text','Fit angle, a and b');
jImpFitParAll.setEnabled(false)
jImpFitParAll.setFont(font);
jImpFitParAll.setBackground(Color(0.95,0.95,0.95))
jImpFitParAll.setFocusable(false)
jPanImpFitPar.add(jImpFitParAll);
jImpFitParAll.setSize(java.awt.Dimension(140, 22));jImpFitParAll.setPreferredSize(Dimension(140, 22));jImpFitParAll.setMaximumSize(Dimension(140, 22));
set(jPanImpFitPar,'Border',border.LineBorder(Color(0.85,0.85,0.85),1,false))
jPanAlat.add(jPanImpFitPar); % Add jButton to a JPanel
jPanImpFitPar2 = JPanel(GridBagLayout);
jPanImpFitPar2.setBackground(Color(0.95,0.95,0.95))
jImpFitParTeta = JRadioButton('Selected',false);
set(jImpFitParTeta,'Text','Fit only the angle');
jImpFitParTeta.setEnabled(false)
jImpFitParTeta.setFont(font);
jImpFitParTeta.setBackground(Color(0.95,0.95,0.95))
jImpFitParTeta.setFocusable(false)
jPanImpFitPar2.add(jImpFitParTeta);
jImpFitParTeta.setSize(java.awt.Dimension(140, 22));jImpFitParTeta.setPreferredSize(Dimension(140, 22));jImpFitParTeta.setMaximumSize(Dimension(140, 22));
set(jPanImpFitPar,'Border',border.LineBorder(Color(0.95,0.95,0.95),1,false))
jPanAlat.add(jPanImpFitPar2); % Add jButton to a JPanel
jPanAlat.add(Box.createRigidArea(Dimension(0,1)));

% Reference
h.left.ana.panel.strainAdv.impFitA = jPanImpFitA;
h.left.ana.panel.strainAdv.impFitABut = jImpFitA;
h.left.ana.panel.strainAdv.impFitNUCText = jImpFitOptText;
h.left.ana.panel.strainAdv.impFitNUC = jImpFitOptUC;
h.left.ana.panel.strainAdv.impFitParAll = jImpFitParAll;
h.left.ana.panel.strainAdv.impFitParTeta = jImpFitParTeta;

% Add the panel to the main panel
h.left.ana.panel.strainAdv.main = jPanStrainAdv;
jpanAna.add(h.left.ana.panel.strainAdv.main);
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