function out = selectImageFromStack(obs)

if size(obs,3)==1
    out = obs;
    return
else
    out = obs(:,:,1);
end
Nmax = size(obs,3);

%% Make GUI
screensize = get( 0, 'Screensize' );
cent = [screensize(3) screensize(4)];
hf = figure('units','pixels','outerposition',[cent(1)*0.05 cent(2)*0.05 cent(1)*0.9 cent(2)*0.9],'Name','Select image from stack',...
    'NumberTitle','off','Color',[0.8 0.8 0.8],'DeleteFCN',@deleteFigure,'Visible','off');
set(hf,'units','normalized')
% Insert two panels
hp1 = uipanel('Parent',hf,'units','normalized','Position',[0,0,1,0.05],'ShadowColor',[0 0 0],'ForegroundColor',[0 0 0],'HighlightColor',[0.95 0.95 0.95],'Title','Select image');
Slider = uicontrol('Parent',hp1,'Style','slider','units','normalized','Position',[0.005 0.05 0.395 0.9],'Min',1,'Max',Nmax,'Value',1,'SliderStep', [1/(Nmax-1) 1]);
e1 = uicontrol('Parent',hp1,'Style','Edit','String','1','Units','Normalized','Position',[0.4 0.05 0.05 0.9]);

Tb = uicontrol('Parent',hp1,'Style','Togglebutton','String','Take average','Units','Normalized','Position',[0.5 0.05 0.1 0.9]);
uicontrol('Parent',hp1,'Style','Edit','String','Begin:','Units','Normalized','Position',[0.6 0.05 0.05 0.9],'Enable','inactive');
eAMin = uicontrol('Parent',hp1,'Style','Edit','String','1','Units','Normalized','Position',[0.65 0.05 0.05 0.9]);
uicontrol('Parent',hp1,'Style','Edit','String','End:','Units','Normalized','Position',[0.7 0.05 0.05 0.9],'Enable','inactive');
eAMax = uicontrol('Parent',hp1,'Style','Edit','String',num2str(Nmax),'Units','Normalized','Position',[0.75 0.05 0.05 0.9]);

Export = uicontrol('Parent',hp1,'Style','Pushbutton','String','Use selected image','Units','Normalized','Position',[0.85 0.05 0.145 0.9]);

% Create axes
ax = axes('Units','Normalized','Position',[0.05 0.1 0.9 0.85]);
% Show image
axes(ax);
imagesc(obs(:,:,1));colormap gray; axis equal off

set(Slider,'Callback',@sliderVal)
set(e1,'Callback',@getVal)
set(Tb,'Callback',@switchMean)
set(Export,'Callback',@exportImg)
set(hf,'Visible','on')
set(eAMin,'Callback',@getMinAv)
set(eAMax,'Callback',@getMaxAv)
waitfor(hf)

    function getVal(hObject,~)
        val = str2double(get(hObject,'String'));
        if isnan(val) || val<1
            val = 1;
            set(hObject,'String',num2str(val))
        elseif val>Nmax
            val = Nmax;
            set(hObject,'String',num2str(val))
        else
            val = round(val);
            set(hObject,'String',num2str(val))
        end
        set(Slider,'Value',val)
        set(Tb,'Value',false)
        upImg()
        showImg()
    end

    function getMinAv(hObject,~)
        val = str2double(get(hObject,'String'));
        if isnan(val) || val<1
            val = 1;
            set(hObject,'String',num2str(val))
        elseif val>Nmax
            val = Nmax;
            set(hObject,'String',num2str(val))
        else
            val = round(val);
            set(hObject,'String',num2str(val))
        end
        valMax = str2double(get(eAMax,'String'));
        if val>valMax
            valMax = val;
        end
        set(eAMax,'String',num2str(valMax))
        set(Tb,'Value',true)
        upImg()
        showImg()
    end

    function getMaxAv(hObject,~)
        val = str2double(get(hObject,'String'));
        if isnan(val) || val<1
            val = 1;
            set(hObject,'String',num2str(val))
        elseif val>Nmax
            val = Nmax;
            set(hObject,'String',num2str(val))
        else
            val = round(val);
            set(hObject,'String',num2str(val))
        end
        valMin = str2double(get(eAMin,'String'));
        if val<valMin
            valMin = val;
        end
        set(eAMin,'String',num2str(valMin))
        set(Tb,'Value',true)
        upImg()
        showImg()
    end

    function sliderVal(hObject,~)
        val = get(hObject,'Value');
        val = round(val);
        set(hObject,'Value',val)
        set(e1,'String',num2str(val))
        set(Tb,'Value',false)
        upImg()
        showImg()
    end

    function upImg()
        button_state = get(Tb,'Value');
        if button_state
            valMin = str2double(get(eAMin,'String'));
            valMax = str2double(get(eAMax,'String'));
            out = mean(obs(:,:,valMin:valMax),3);
        else
            val = str2double(get(e1,'String'));
            out = obs(:,:,val);
        end
    end
    
    function showImg()
        axes(ax)
        imagesc(out);colormap gray; axis equal off
    end

    function switchMean(~,~)
        upImg()
        showImg()
    end

    function exportImg(~,~)
        close(hf)
    end

    function deleteFigure(~,~)
        upImg()
    end
end