function h = messagePanel(h)
% messagePanel - Create a panel to show message
%
% Create a java panel in the StatSTEM interface to display messages
%
%   syntax: h = messagePanel(h)
%       h       - structure holding references to GUI interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

%% Import java functions (standard MATLAB code cannot be used)
import javax.swing.*;
import java.awt.*;

%% Create the main panel
jpan = JPanel; % Create main panel

% Create a text box indicating the purpose of the buttons
jText = JTextArea;
jText.setAlignmentX(0.5);
jpan.add(jText);
str = sprintf('Welcome to StatSTEM v3.0 beta, have fun analysing\nWhen using StatSTEM please cite: A. De Backer, K.H.W. van den Bos, et. al., Ultramicroscopy 171 (2016), p.104-116');
jText.setText(str)
jText.setEditable(false)
jText.setFocusable(true)
jText.setBackground(Color(0.95,0.95,0.95))
jText.setForeground(Color(1,0,0))
jText.setLineWrap(true)
jscrollpane=JScrollPane(jText);
jscrollpane.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED)
% Reference
h.right.message.text = jText;

%% Add scrollbar to panel and update GUI
% % set(jpan,'Border',border.LineBorder(Color(0.95,0.95,0.95),1,false))
% jscrollpane=JScrollPane(jpan); % Add jPanels to a JScrollPane
% jscrollpane.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED)

% Javacomponent adds the requested component as a child of the requested 
% parent container and wraps it in a Matlab Handle-Graphics container
[jj,hh]=javacomponent(jscrollpane,[0.003 0.003 0.994 0.95],h.right.message.panel);
set(jj,'Border',border.LineBorder(Color(0.95,0.95,0.95),1,false))
set(hh,'units','normalized','Position',[0.003 0.003 0.994 0.95])
set(jscrollpane,'Border',border.LineBorder(Color(0.5,0.5,0.5),1,false))

h.right.message.textPanel = hh;
h.right.message.jTextPanel = jj;