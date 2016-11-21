function range = setRangeUI(range,cent)
% setRangeUI - GUI to set the colorbar range of a second axes
%
%   syntax: range = setRangeUI(range)
%       range - limits of the color range
%       cent  - Location of StatSTEM
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%------------------------------------------------------------------------

s = [200,160];
hfig = figure('units','pixels','outerposition',[cent(1)-s(1)/2 cent(2)-s(2)/2 s(1) s(2)],'Name','Colormap range','NumberTitle','off','Visible','on','Resize','off','DeleteFCN',@deleteFigure,'MenuBar','none','Color',[0.94,0.94,0.94]);

uicontrol('Parent',hfig,'Style','Text','String','Color data min:','Position',[10 80 80 22],'BackgroundColor',[0.94,0.94,0.94]);
uicontrol('Parent',hfig,'Style','Text','String','Color data max:','Position',[10 50 80 22],'BackgroundColor',[0.94,0.94,0.94]);

edit1 = uicontrol('Parent',hfig,'Style','Edit','String',range(1),'Position',[100 83 80 22],'Callback',{@isNum,range(1)});
edit2 = uicontrol('Parent',hfig,'Style','Edit','String',range(2),'Position',[100 53 80 22],'Callback',{@isNum,range(2)});

uicontrol('Parent',hfig,'Style','pushbutton','String','Apply','Position',[10 10 85 22],'Callback',{@storeRange,hfig,edit1,edit2});
uicontrol('Parent',hfig,'Style','pushbutton','String','Cancel','Position',[105 10 85 22],'Callback',{@cancelRange,hfig});

waitfor(hfig)

    function isNum(hObject,event,valRef)
        val = str2double(get(hObject,'String'));
        if isnan(val)
            set(hObject,'String',valRef)
        end
    end

    function storeRange(~,~,hfig,edit1,edit2)
        range(1) = str2double(get(edit1,'String'));
        range(2) = str2double(get(edit2,'String'));
        close(hfig)
    end
        

    function cancelRange(~,~,hfig)
        close(hfig)
    end
        
    function deleteFigure(hObject,~)
        uiresume(hObject)
        delete(hObject)
    end
end