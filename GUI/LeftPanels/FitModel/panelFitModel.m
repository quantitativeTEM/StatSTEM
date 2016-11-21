function h = panelFitModel(h)
% panelFitModel - Create the fit program panel
%
%   syntax: h = panelFitModel(h)
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

%% Check version of MATLAB
v = version('-release');
v = str2double(v(1:4));

%% Create the main panel
jpanFit = JPanel; % Create main panel

% Set Layout
% The two arguments to the BoxLayout constructor are the container that it 
% manages and the axis along which the components will be laid out.
jpanFit.setLayout(BoxLayout(jpanFit, BoxLayout.Y_AXIS));
jpanFit.setBackground(Color(0.95,0.95,0.95))
%% First panel
% Create panel for running the fit program
jPanRunFit = JPanel;
jPanRunFit.setLayout(BoxLayout(jPanRunFit, BoxLayout.Y_AXIS));
jPanRunFit.setSize(Dimension(168,74));jPanRunFit.setPreferredSize(Dimension(168,74));jPanRunFit.setMaximumSize(Dimension(168,74))
jPanRunFit.setAlignmentX(Component.LEFT_ALIGNMENT);
jPanRunFit.setBackground(Color(0.7,0.7,0.7))
set(jPanRunFit,'Border',border.MatteBorder(1,1,0,1,Color(0.3,0.3,0.3)))
jPanRunFit.add(Box.createRigidArea(Dimension(0,1)));

% Button for running the routine
jFitButPan = JPanel(GridLayout(1,1));
jFitBut = JButton();
set(jFitBut,'Text','Run fitting routine')
jFitBut.setFont(font);
jFitBut.setBackground(Color(0.7,0.7,0.7))
jFitBut.setFocusable(false)
jFitButPan.add(jFitBut);
jFitButPan.setSize(java.awt.Dimension(170, 22));
jFitButPan.setPreferredSize(Dimension(170, 22));
jFitButPan.setMaximumSize(Dimension(170, 22));
set(jFitButPan,'Border',border.LineBorder(Color(0.7,0.7,0.7),1,false))
jFitButPan.setBackground(Color(0.7,0.7,0.7))
jPanRunFit.add(jFitButPan); % Add jButton to a JPanel
jPanRunFit.add(Box.createRigidArea(Dimension(0,2)));
% Reference
h.left.fit.panRout.PanRun = jFitButPan;
h.left.fit.panRout.runBut =jFitBut;

% Button for aborting the routine
jAbortButPan = JPanel(GridLayout(1,1));
jAbortBut = JButton();
set(jAbortBut,'Text','Abort fitting routine')
jAbortBut.setFont(font);
jAbortBut.setBackground(Color(0.7,0.7,0.7))
jAbortBut.setFocusable(false)
jAbortBut.setEnabled(false)
% jAbortBut.setToolTipText('Function not available')
jAbortButPan.add(jAbortBut);
jAbortButPan.setSize(java.awt.Dimension(170, 22));
jAbortButPan.setPreferredSize(Dimension(170, 22));
jAbortButPan.setMaximumSize(Dimension(170, 22));
set(jAbortButPan,'Border',border.LineBorder(Color(0.7,0.7,0.7),1,false))
jAbortButPan.setBackground(Color(0.7,0.7,0.7))
jPanRunFit.add(jAbortButPan); % Add jButton to a JPanel
jPanRunFit.add(Box.createRigidArea(Dimension(0,2)));
% Reference
h.left.fit.panRout.PanAbort = jAbortButPan;
h.left.fit.panRout.AbortBut =jAbortBut;

% Button for showing advanced options
jAdvButPan = JPanel(GridLayout(1,1));
jAdvBut = JCheckBox('Selected',true);
set(jAdvBut,'Text','Show options')
jAdvBut.setFont(font);
jAdvBut.setBackground(Color(0.7,0.7,0.7))
jAdvBut.setFocusable(false)
jAdvButPan.add(jAdvBut);
jAdvButPan.setSize(java.awt.Dimension(170, 22));
jAdvButPan.setPreferredSize(Dimension(170, 22));
jAdvButPan.setMaximumSize(Dimension(170, 22));
set(jAdvButPan,'Border',border.LineBorder(Color(0.7,0.7,0.7),1,false))
jAdvButPan.setBackground(Color(0.7,0.7,0.7))
jPanRunFit.add(jAdvButPan); % Add jButton to a JPanel
jPanRunFit.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.fit.panRout.PanAdv = jAdvButPan;
h.left.fit.panRout.AdvBut =jAdvBut;

% Add the panel to the main panel
h.left.fit.panRout.main = jPanRunFit;
jpanFit.add(h.left.fit.panRout.main);

%% The advance panel
% Create main panel for advance options of the fit program
jPanAdvFit = JPanel;
jPanAdvFit.setLayout(BoxLayout(jPanAdvFit, BoxLayout.Y_AXIS));
jPanAdvFit.setSize(Dimension(168,288));jPanAdvFit.setPreferredSize(Dimension(168,288));jPanAdvFit.setMaximumSize(Dimension(168,288))
jPanAdvFit.setAlignmentX(Component.LEFT_ALIGNMENT);
jPanAdvFit.setBackground(Color(0.95,0.95,0.95))
set(jPanAdvFit,'Border',border.MatteBorder(0,1,1,1,Color(0.3,0.3,0.3)))
jPanAdvFit.add(Box.createRigidArea(Dimension(0,1)));

% Create main panel for background options
jPanBackground = JPanel;
jPanBackground.setLayout(BoxLayout(jPanBackground, BoxLayout.Y_AXIS));
jPanBackground.setSize(Dimension(170,74));jPanBackground.setPreferredSize(Dimension(170,74));jPanBackground.setMaximumSize(Dimension(170,74))
jPanBackground.setAlignmentX(Component.LEFT_ALIGNMENT);
jPanBackground.setBackground(Color(0.95,0.95,0.95))
set(jPanBackground,'Border',border.MatteBorder(0,0,0,0,Color(0.95,0.95,0.95)))
jPanAdvFit.add(jPanBackground);
h.left.fit.panels.Back.main = jPanBackground;

% Create a text box indicating the purpose of the buttons
jEditBack = JTextField;
jEditBack.setAlignmentX(0.5);
jPanBackground.add(jEditBack);
jEditBack.setText(' Background')
jEditBack.setFont(font);
jEditBack.setEditable(false)
% jEditBack.setFocusable(false)
jEditBack.setSize(Dimension(170,22))
jEditBack.setMaximumSize(Dimension(170,22))
jEditBack.setPreferredSize(Dimension(170,22))
jEditBack.setBackground(Color(0,0,0))
jEditBack.setForeground(Color(1,1,1))
set(jEditBack,'Border',border.MatteBorder(2,2,0,2,Color(0.95,0.95,0.95)))
% Reference
h.left.fit.panels.Back.header = jEditBack;

% Select automatic background fitting
jAutBackPan = JPanel(GridLayout(1,1));
jAutBackBut = JCheckBox();
set(jAutBackBut,'Text','Fit background')
jAutBackBut.setFont(font);
if v<2015
    warning('off','all')
    set(jAutBackBut,'Selected','on')
    warning('on','all')
else
    set(jAutBackBut,'Selected',true)
end
jAutBackBut.setFocusable(false)
jAutBackBut.setEnabled(false)
jAutBackBut.setBackground(Color(0.95,0.95,0.95))
jAutBackPan.add(jAutBackBut);
jAutBackPan.setSize(java.awt.Dimension(166, 22));
jAutBackPan.setPreferredSize(Dimension(166, 22));
jAutBackPan.setMaximumSize(Dimension(166, 22));
set(jAutBackPan,'Border',border.LineBorder(Color(0.95,0.95,0.95),1,false))
jAutBackPan.setBackground(Color(0.95,0.95,0.95))
jPanBackground.add(jAutBackPan); % Add jButton to a JPanel
% Reference
h.left.fit.panels.Back.AutBackPan = jAutBackPan;
h.left.fit.panels.Back.AutBackBut = jAutBackBut;

% Add two buttons next to each other, first create a boxed panel
jBackPan = JPanel(GridBagLayout);
jBackPan.setBackground(Color(0.95,0.95,0.95))
jBackText = JTextField;
set(jBackText,'Text','Value:');
jBackText.setFont(font);
jBackText.setEditable(false)
jBackText.setBackground(Color(0.95,0.95,0.95))
set(jBackText,'Border',border.LineBorder(Color(0.95,0.95,0.95),1,false))
jBackText.setSize(Dimension(35,20));jBackText.setPreferredSize(Dimension(35, 20));jBackText.setMaximumSize(Dimension(35, 20));
jBackPan.add(jBackText);
jBackVal = JTextField;
set(jBackVal,'Text','Automatic');
jBackVal.setFont(font);
jBackVal.setSize(Dimension(75,18));jBackVal.setPreferredSize(Dimension(75, 18));jBackVal.setMaximumSize(Dimension(75, 18));
jBackVal.setEnabled(false)
jBackPan.add(jBackVal);
jBackSelBut = JButton();
set(jBackSelBut,'Text','Select')
jBackSelBut.setFont(font);
jBackSelBut.setEnabled(false)
jBackSelBut.setMargin(Insets(0,0,0,0))
jBackSelBut.setBackground(Color(0.95,0.95,0.95))
jBackSelBut.setFocusable(false)
jBackPan.add(jBackSelBut);
jBackSelBut.setSize(java.awt.Dimension(50, 20));jBackSelBut.setPreferredSize(Dimension(50, 20));jBackSelBut.setMaximumSize(Dimension(50, 20));
jPanBackground.add(jBackPan); % Add jButton to a JPanel
jPanBackground.add(Box.createRigidArea(Dimension(0,1)));
% jPanAdvFit.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.fit.panels.Back.BackPan  = jBackPan;
h.left.fit.panels.Back.Text    = jBackText;
h.left.fit.panels.Back.Val = jBackVal;
h.left.fit.panels.Back.SelBut = jBackSelBut;


%% Create main panel for width type option
jPanWidth = JPanel;
jPanWidth.setLayout(BoxLayout(jPanWidth, BoxLayout.Y_AXIS));
jPanWidth.setSize(Dimension(168,92));jPanWidth.setPreferredSize(Dimension(168,92));jPanWidth.setMaximumSize(Dimension(168,92))
jPanWidth.setAlignmentX(Component.LEFT_ALIGNMENT);
jPanWidth.setBackground(Color(0.85,0.85,0.85))
set(jPanWidth,'Border',border.LineBorder(Color(0.85,0.85,0.85),1,false))
jPanAdvFit.add(jPanWidth);
h.left.fit.panels.Width.main = jPanWidth;

% Create a text box indicating the purpose of the buttons
jEditWidth = JTextField;
jEditWidth.setAlignmentX(0.5);
jPanWidth.add(jEditWidth);
jEditWidth.setText(' Column Width')
jEditWidth.setFont(font);
jEditWidth.setEditable(false)
% jEditWidth.setFocusable(false)
jEditWidth.setSize(Dimension(170,22))
jEditWidth.setMaximumSize(Dimension(170,22))
jEditWidth.setPreferredSize(Dimension(170,22))
jEditWidth.setBackground(Color(0,0,0))
jEditWidth.setForeground(Color(1,1,1))
set(jEditWidth,'Border',border.MatteBorder(2,2,0,2,Color(0.85,0.85,0.85)))
h.left.fit.panels.Width.header = jEditWidth;

% Create a toggle buttons to select fit method
jSameWidth = JRadioButton('Selected',true);
jSameWidth.setAlignmentX(0.5);
jPanWidth.add(jSameWidth);
jSameWidth.setText('Same width')
jSameWidth.setFont(font);
jSameWidth.setToolTipText('Use the same width for each atomic column of the same type')
jSameWidth.setFocusable(false)
jSameWidth.setSize(Dimension(170,22))
jSameWidth.setMaximumSize(Dimension(170,22))
jSameWidth.setPreferredSize(Dimension(170,22))
jSameWidth.setBackground(Color(0.85,0.85,0.85))
h.left.fit.panels.Width.SameBut = jSameWidth;
jDifWidth = JRadioButton('Selected',false);
jDifWidth.setAlignmentX(0.5);
jPanWidth.add(jDifWidth);
jDifWidth.setText('Different width')
jDifWidth.setFont(font);
jDifWidth.setToolTipText('Use a different width for each atomic column')
jDifWidth.setFocusable(false)
jDifWidth.setSize(Dimension(170,22))
jDifWidth.setMaximumSize(Dimension(170,22))
jDifWidth.setPreferredSize(Dimension(170,22))
jDifWidth.setBackground(Color(0.85,0.85,0.85))
h.left.fit.panels.Width.DiffBut = jDifWidth;
jUserWidthPan = JPanel(GridBagLayout);
jUserWidthPan.setBackground(Color(0.85,0.85,0.85))
jUserWidth = JRadioButton('Selected',false);
jUserWidth.setAlignmentX(0.5);
jUserWidth.setText('User defined')
jUserWidth.setFont(font);
jUserWidth.setToolTipText('Use a user defined width for each atomic column (type)')
jUserWidth.setFocusable(false)
jUserWidth.setSize(Dimension(110,22))
jUserWidth.setMaximumSize(Dimension(110,22))
jUserWidth.setPreferredSize(Dimension(110,22))
jUserWidth.setBackground(Color(0.85,0.85,0.85))
jUserWidthPan.add(jUserWidth);
jUserWidth.setAlignmentX(0);
% Create a buttons to store fitted coordinates as input
jUserWidthBut = JButton();
set(jUserWidthBut,'Text','Edit');
jUserWidthBut.setFont(font);
jUserWidthBut.setAlignmentX(0.5);
jUserWidthBut.setToolTipText('Edit the user defined widths for each column (type)')
jUserWidthBut.setEnabled(false)
jUserWidthBut.setMargin(Insets(0,0,0,0))
jUserWidthBut.setBackground(Color(0.85,0.85,0.85))
jUserWidthBut.setFocusable(false)
jUserWidthPan.add(jUserWidthBut);
jUserWidthBut.setSize(Dimension(53,20))
jUserWidthBut.setMaximumSize(Dimension(53,20))
jUserWidthBut.setPreferredSize(Dimension(53,20))
jPanWidth.add(jUserWidthPan);
jPanWidth.add(Box.createRigidArea(Dimension(0,2)));
h.left.fit.panels.Width.UserBut = jUserWidth;
h.left.fit.panels.Width.EditBut = jUserWidthBut;

% Add space
% jPanAdvFit.add(Box.createRigidArea(Dimension(0,1)));

%% Create main panel for test fit option
jPanTest = JPanel;
jPanTest.setLayout(BoxLayout(jPanTest, BoxLayout.Y_AXIS));
jPanTest.setSize(Dimension(168,68));jPanTest.setPreferredSize(Dimension(168,68));jPanTest.setMaximumSize(Dimension(168,68))
jPanTest.setAlignmentX(Component.LEFT_ALIGNMENT);
jPanTest.setBackground(Color(0.95,0.95,0.95))
set(jPanTest,'Border',border.LineBorder(Color(0.95,0.95,0.95),1,false))
jPanAdvFit.add(jPanTest);
h.left.fit.panels.Test.main = jPanTest;

% Create a text box indicating the purpose of the buttons
jEditTest = JTextField;
jEditTest.setAlignmentX(0.5);
jPanTest.add(jEditTest);
jEditTest.setText(' Test for convergence')
jEditTest.setFont(font);
jEditTest.setEditable(false)
% jEditTest.setFocusable(false)
jEditTest.setBackground(Color(0,0,0))
jEditTest.setForeground(Color(1,1,1))
jEditTest.setSize(Dimension(170,22))
jEditTest.setMaximumSize(Dimension(170,22))
jEditTest.setPreferredSize(Dimension(170,22))
set(jEditTest,'Border',border.MatteBorder(2,2,0,2,Color(0.95,0.95,0.95)))
h.left.fit.panels.Test.header = jEditTest;

% Create a toggle buttons to select fit method
jTestBut = JCheckBox('Selected',false);
set(jTestBut,'Text','Use test conditions');
jTestBut.setFont(font);
jTestBut.setToolTipText('Limit the maximum number of iterations to 4 and fit only column positions')
jTestBut.setBackground(Color(0.95,0.95,0.95))
jPanTest.add(jTestBut);
jTestBut.setAlignmentX(0.5);
jTestBut.setFocusable(false)
jTestBut.setSize(Dimension(166,22))
jTestBut.setMaximumSize(Dimension(166,22))
jTestBut.setPreferredSize(Dimension(166,22))
jTestBut.setBackground(Color(0.95,0.95,0.95))
h.left.fit.panels.Test.But = jTestBut;

% Create a buttons to store fitted coordinates as input
jCoorBut = JButton();
set(jCoorBut,'Text','Export fitted coordinates');
jCoorBut.setFont(font);
jCoorBut.setAlignmentX(0.5);
jCoorBut.setToolTipText('Make fitted coordinates the new input coordinates for a second fit')
jCoorBut.setEnabled(false)
jCoorBut.setMargin(Insets(0,0,0,0))
jCoorBut.setBackground(Color(0.95,0.95,0.95))
jCoorBut.setFocusable(false)
jPanTest.add(jCoorBut);
jCoorBut.setSize(Dimension(161,20))
jCoorBut.setMaximumSize(Dimension(161,20))
jCoorBut.setPreferredSize(Dimension(161,20))
h.left.fit.panels.Test.CoorBut = jCoorBut;

jPanAdvFit.add(Box.createRigidArea(Dimension(0,2)));


%% Create main panel for parallel computing
jPanPara = JPanel;
jPanPara.setLayout(BoxLayout(jPanPara, BoxLayout.Y_AXIS));
jPanPara.setSize(Dimension(168,49));jPanPara.setPreferredSize(Dimension(168,49));jPanPara.setMaximumSize(Dimension(168,49))
jPanPara.setAlignmentX(Component.LEFT_ALIGNMENT);
jPanPara.setBackground(Color(0.85,0.85,0.85))
set(jPanPara,'Border',border.LineBorder(Color(0.85,0.85,0.85),1,false))
jPanAdvFit.add(jPanPara);
h.left.fit.panels.Parallel.main = jPanPara;

% Create a text box indicating the purpose of the buttons
jEditPara = JTextField;
jEditPara.setAlignmentX(0.5);
jPanPara.add(jEditPara);
jEditPara.setText(' Parallel computing')
jEditPara.setFont(font);
jEditPara.setEditable(false)
% jEditTest.setFocusable(false)
jEditPara.setBackground(Color(0,0,0))
jEditPara.setForeground(Color(1,1,1))
set(jEditPara,'Border',border.MatteBorder(2,2,0,2,Color(0.85,0.85,0.85)))
jEditPara.setSize(Dimension(170,22))
jEditPara.setMaximumSize(Dimension(170,22))
jEditPara.setPreferredSize(Dimension(170,22))
h.left.fit.panels.Parallel.header = jEditPara;

% Add input box for entering the number of worker for parallel computing
jParaPan = JPanel(GridBagLayout);
jParaPan.setBackground(Color(0.85,0.85,0.85))
jParaText = JTextField;
set(jParaText,'Text','Number of CPU cores:');
jParaText.setFont(font);
jParaText.setEditable(false)
jParaText.setToolTipText(['The maximum number of workers are the number of CPU processors: ',num2str(feature('numCores'))])
jParaText.setBackground(Color(0.85,0.85,0.85))
set(jParaText,'Border',border.LineBorder(Color(0.85,0.85,0.85),1,false))
jParaText.setSize(Dimension(125,20));jParaText.setPreferredSize(Dimension(125, 20));jParaText.setMaximumSize(Dimension(125, 20));
jParaPan.add(jParaText);
jParaVal = JTextField;
set(jParaVal,'Text',num2str(feature('numCores')));
jParaVal.setSize(Dimension(35,18));jParaVal.setPreferredSize(Dimension(35, 18));jParaVal.setMaximumSize(Dimension(35, 18));
jParaVal.setEnabled(false)
jParaVal.setToolTipText(['The maximum number of workers are the number of CPU processors: ',num2str(feature('numCores'))])
jParaPan.add(jParaVal);
jPanPara.add(jParaPan); % Add jButton to a JPanel
% jPanAdvFit.add(Box.createRigidArea(Dimension(0,1)));
% Reference
h.left.fit.panels.Parallel.Text = jParaText;
h.left.fit.panels.Parallel.Val = jParaVal;

% Hide parallel computing panel for old MATLAB versions
if v<2015 || license('test','distrib_computing_toolbox')==0
    h.left.fit.panels.Parallel.main.setVisible(0)
    jPanAdvFit.setSize(Dimension(168,240));jPanAdvFit.setPreferredSize(Dimension(168,240));jPanAdvFit.setMaximumSize(Dimension(168,240))
end

% Reference main advance panel
h.left.fit.panAdv.main = jPanAdvFit;
jpanFit.add(h.left.fit.panAdv.main);

%% Add scrollbar to panel and update GUI
% set(jpan,'Border',border.LineBorder(Color(0.95,0.95,0.95),1,false))
jscrollpane=JScrollPane(jpanFit); % Add jPanels to a JScrollPane
jscrollpane.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED)

% Javacomponent adds the requested component as a child of the requested 
% parent container and wraps it in a Matlab Handle-Graphics container
[jj,hh]=javacomponent(jscrollpane,[0 0 1 1],h.left.fit.tab);
set(jj,'Border',border.LineBorder(Color(0.95,0.95,0.95),1,false))
set(hh,'units','normalized','Position',[0 0 1 1])
set(jj,'MouseMovedCallback',{@cursorArrow,h.fig})

h.left.fit.jmain = jj;
h.left.fit.main = hh;