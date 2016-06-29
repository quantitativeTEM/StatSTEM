function h = panelStatSTEM(h,img)

%% Import java function, since standard MATLAB code cannot be used
import javax.swing.*;
import java.awt.*;

%% Create the main panel
jpan = JPanel; % Create main panel

% Create image
imgJ = im2java(img);
jlab = JLabel();
imgIcon = ImageIcon(imgJ);
jlab.setIcon(imgIcon);
jlab.setBounds(0,0,190,158);
jpan.add(jlab);

%% Put panel in GUI
% Javacomponent adds the requested component as a child of the requested 
% parent container and wraps it in a Matlab Handle-Graphics container
[jj,hh]=javacomponent(jpan,[0 0.1 1 0.35],h.left.main);
set(jj,'Border',border.LineBorder(Color(0.95,0.95,0.95),1,false))
set(hh,'units','normalized','Position',[0 0.1 1 0.35])

h.left.StatSTEM.panel = hh;
h.left.StatSTEM.jpanel = jj;