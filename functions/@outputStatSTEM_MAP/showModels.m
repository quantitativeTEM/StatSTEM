function hfig = showModels(obj,input)
% showModels - Show the different fitted models obtained for MAP
%
% syntax: showModels(obj)
%   obj   - outputStatSTEM_MAP file
%   input - inputStatSTEM file
%   hfig  - reference to created figure 
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos, J. Fatermans
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

%% Make GUI
screensize = get( 0, 'Screensize' );
cent = [screensize(3) screensize(4)];
hfig = figure('units','pixels','outerposition',[cent(1)*0.05 cent(2)*0.05 cent(1)*0.9 cent(2)*0.9],'Name','Show models fitted for MAP',...
    'NumberTitle','off','Color',[0.8 0.8 0.8],'Visible','on');
set(hfig,'units','normalized')

% Create axes
ax = axes('Parent',hfig,'Units','Normalized','Position',[0.05 0.05 0.4 0.75]);
ax2 = axes('Parent',hfig,'Units','Normalized','Position',[0.55 0.05 0.4 0.75]);
% Show image 1
axes(ax);
n1 = find(obj.MAPprob==max(obj.MAPprob));
n1 = n1(1);
if nargin<2
    showModel(obj.models{n1})
else
    showObservation(input)
end
plotFitCoordinates(obj.models{n1})

% Show image 2
axes(ax2);
if nargin<2
    n2 = min([obj.Nmodels,2]);
else
    n2 = n1;
end
showModel(obj.models{n2})
plotFitCoordinates(obj.models{n2})

stringModels = cell(obj.Nmodels,1);
N = obj.N;
for i=1:obj.Nmodels
    stringModels{i,1} = ['Model with ',num2str(N(i)),' columns'];
end
if nargin<2
    stringObs = stringModels;
else
    for i=1:obj.Nmodels
        stringObs{i,1} = ['Observation with ',num2str(N(i)),' columns'];
    end
end


% Pop-up menu's
if nargin<2
    uicontrol('Parent',hfig,'Style','popupmenu','units','normalized','Position',[0.05 0.85 0.4 0.1],'String',stringObs,'Callback',{@newModel,1},'Value',n1);
else
    uicontrol('Parent',hfig,'Style','popupmenu','units','normalized','Position',[0.05 0.85 0.4 0.1],'String',stringObs,'Callback',{@newCoor},'Value',n1);
end
uicontrol('Parent',hfig,'Style','popupmenu','units','normalized','Position',[0.55 0.85 0.4 0.1],'String',stringModels,'Callback',{@newModel,2},'Value',n2);

    function newModel(hObject,~,num)
        val = get(hObject,'Value');
        if val==n1 && num==1
            return
        elseif val==n2 && num==2
            return
        end
        if num==1
            axes(ax)
            n1 = val;
        else
            axes(ax2)
            n2 = val;
        end
        showModel(obj.models{val})
        plotFitCoordinates(obj.models{val})
    end

    function newCoor(hObject,~)
        val = get(hObject,'Value');
        if val==n1 && num==1
            return
        end
        n1 = val;
        deleteImageObject(ax,'Fitted coordinates')
        plotFitCoordinates(obj.models{val})
    end 
        
end