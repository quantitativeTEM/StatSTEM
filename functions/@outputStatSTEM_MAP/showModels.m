function hfig = showModels(obj,input)
% showModels - Visualization tool to help decide which model needs to be
% selected from the MAP probability curve
%
% syntax: showModels(obj)
%   obj   - outputStatSTEM_MAP file
%   input - inputStatSTEM file
%   hfig  - reference to created figure 
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2020, EMAT, University of Antwerp
% Author: K.H.W. van den Bos, J. Fatermans
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Make GUI
screensize = get(0, 'Screensize' );
cent = [screensize(3) screensize(4)];
hfig = figure('units','pixels','outerposition',[cent(1)*0.05 cent(2)*0.05 cent(1)*0.9 cent(2)*0.9],'Name','Overview MAP',...
    'NumberTitle','off','Color',[0.8 0.8 0.8],'Visible','on');
set(hfig,'units','normalized')

% Create axes
ax1 = axes('Parent',hfig,'Units','Normalized','Position',[0.05 0.55 0.4 0.4]);
ax3 = axes('Parent',hfig,'Units','Normalized','Position',[0.55 0.55 0.4 0.4]);
ax2 = axes('Parent',hfig,'Units','Normalized','Position',[0.05 0.05 0.9 0.4]);
n = obj.NselMod;
% Show raw image data, including fitted coordinates
axes(ax1);
%if nargin<2
 %   showModel(obj.models{n1})
%else
showObservation(input)
%end
plotFitCoordinates(obj.models{n})

% Show MAP probability curve
axes(ax2);
 plot(obj.N,obj.MAPprob,'.','MarkerSize',20,'color', [0 0 0]),xlabel('Number of atomic columns'),...
     ylabel('Relative probability (logscale)'),hold on,...,
     plot(n-1+obj.N(1),obj.MAPprob(n),'rx','MarkerSize',20),xticks(obj.N);

% Show model fit including fitted coordinates
axes(ax3);
%if nargin<2
 %   n2 = min([obj.Nmodels,2]);
%else
%end
showModel(obj.models{n})
plotFitCoordinates(obj.models{n})

stringModels = cell(obj.Nmodels,1);
N = obj.N;
for i=1:obj.Nmodels
    stringModels{i,1} = [num2str(N(i)),' atomic columns'];
end

% Pop-up menu showing possibility of number of columns
uicontrol('Parent',hfig,'Style','popupmenu','units','normalized','Position',[0.425 0.70 0.15 0.1],'String',stringModels,'Callback',{@newModel},'Value',n);

    function newModel(hObject,~)
        val = get(hObject,'Value');
        axes(ax1)
        deleteImageObject(ax1,'Fitted coordinates')
        plotFitCoordinates(obj.models{val})
        axes(ax2);
        cla;
         plot(obj.N,obj.MAPprob,'.','MarkerSize',20,'color',[0 0 0]),xlabel('Number of atomic columns'),ylabel('Relative probability (logscale)'),hold on,...
            plot(val-1+obj.N(1),obj.MAPprob(val),'rx','MarkerSize',20),xticks(obj.N);
        axes(ax3)
        showModel(obj.models{val})
        plotFitCoordinates(obj.models{val})
    end
        
end