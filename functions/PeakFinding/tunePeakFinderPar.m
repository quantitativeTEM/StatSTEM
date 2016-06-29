function settings = tunePeakFinderPar(obs,settings)
% tunePeakFinderPar - Interactive interface to choose define optimal
%                     parameters for the peak finding routine
%
%   syntax: settings = tunePeakFinderPar(obs,settings)
%       obs      - the observation
%       settings - structure containing the parameters
%
%   Input:
%       Four different filters can be choosen to smoothen the image: an
%       averaging filter ('average'), a disk filter ('disk'), a gaussian
%       filter ('gaussian') or no filter ('none'). The value of each filter
%       is related to the width of the filter.
%
%   Example:
%       settings.thres = 0 % Threshold value
%       settings.filter1.type = 'gaussian'; % Type of first filter
%       settings.filter1.val = 1;           % Value of the first filter
%       settings.filter2.type = 'none';     % Type of second filter
%       settings.filter2.val = 1;           % Value of the second filter
%       settings.filter3.type = 'none';     % Type of third filter
%       settings.filter3.val = 1;           % Value of the third filter
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if nargin<2
    settings.thres = 0;
    settings.filter1.type = 'none';
    settings.filter1.val = 1;
    settings.filter2.type = 'none';
    settings.filter2.val = 1;
    settings.filter3.type = 'none';
    settings.filter3.val = 1;
end
settings.store = 0;

% First create a new figure
screensize = get( 0, 'Screensize' );
s = [800 498];
hpf.fig = figure('units','pixels','outerposition',[screensize(3)/2-s(1)/2 screensize(4)/2-s(2)/2 s(1) s(2)],'Name','Peak Finder Parameters','NumberTitle','off','Visible','on','Resize','off','DeleteFCN',@deleteFigure,'MenuBar','none');

% Create two panels, one for showing the image and one for tuning the
% parameters
hpf.image.pan = uipanel('Parent',hpf.fig,'units','pixels','Position',[5 5 550 412],'ShadowColor',[0 0 0],'ForegroundColor',[0 0 0],'HighlightColor',[0.95 0.95 0.95],'BackgroundColor',[0.8 0.8 0.8]);
hpf.image.ax = axes('Parent',hpf.image.pan);
hpf.image.title = uicontrol('Parent',hpf.fig,'Style','text','String','Image','units','pixels','Position',[10 406 40 18],'FontSize',10,'BackgroundColor',[0.8 0.8 0.8]);
% set(hpf.image.pan,'units','normalized')
% set(hpf.image.title,'units','normalized')

hpf.par.pan = uipanel('Parent',hpf.fig,'units','pixels','Position',[560 35 230 382],'ShadowColor',[0 0 0],'ForegroundColor',[0 0 0],'HighlightColor',[0.95 0.95 0.95],'BackgroundColor',[0.8 0.8 0.8]);
hpf.par.title = uicontrol('Parent',hpf.fig,'Style','text','String','Parameters','units','pixels','Position',[565 406 70 18],'FontSize',10,'BackgroundColor',[0.8 0.8 0.8]);
% set(hpf.par.pan,'units','normalized')
% set(hpf.par.title,'units','normalized')

% Create panel to indicate the purpose of the program
hpf.help.pan = uipanel('Parent',hpf.fig,'units','pixels','Position',[5 427 785 38],'ShadowColor',[0 0 0],'ForegroundColor',[0 0 0],'HighlightColor',[0.95 0.95 0.95],'BackgroundColor',[0.8 0.8 0.8]);
str = 'In order to help the peak finder program to find the correct local maxima, noise should be removed from the image. Select one or multiple filters to make the image smooth. A threshold value can be added to remove background noise.';
hpf.help.text = uicontrol('Parent',hpf.help.pan,'Style','text','String',str,'units','normalized','Position',[0 0 1 1],'FontSize',10,'BackgroundColor',[0.8 0.8 0.8],'horizontalAlignment', 'left');
% set(hpf.help.pan,'units','normalized')
% set(hpf.help.text,'units','normalized')

% Threshold
hpf.par.thres.text = uicontrol('Parent',hpf.par.pan,'Style','text','String','Threshold value:','units','pixels','Position',[5 350 120 18],'FontSize',10,'HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8]);
low = min(min(obs));
high = max(max(obs));
Slider = uicontrol('Parent',hpf.par.pan,'Style','slider','units','pixels','Position',[50 332 130 18],'Min',low,'Max',high); %,'TooltipString',['The range is: ',num2str(low),' to ',num2str(high)]
thres = settings.thres;
TXTlow = uicontrol('Parent',hpf.par.pan,'Style','text','units','pixels','Position',[2 330 47 18],'String',num2str(low,2),'BackgroundColor',[0.8 0.8 0.8],'HorizontalAlignment','right');
TXThigh = uicontrol('Parent',hpf.par.pan,'Style','text','units','pixels','Position',[181 330 47 18],'String',num2str(high,2),'BackgroundColor',[0.8 0.8 0.8],'HorizontalAlignment','left');
hpf.par.thres.Curtext = uicontrol('Parent',hpf.par.pan,'Style','text','String',' Current value:','units','pixels','Position',[25 310 90 18],'FontSize',10,'HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8]);
% set(hpf.par.thres.text,'units','normalized')
% set(hpf.par.thres.Curtext,'units','normalized')
% set(TXTlow,'units','normalized')
% set(TXThigh,'units','normalized')
% set(Slider,'units','normalized')

TXTthres = uicontrol('Parent',hpf.par.pan,'Style','edit','String',num2str(thres),'units','pixels','Position',[115 309 80 20],'FontSize',10);
% set(TXTthres,'units','normalized')

filters = {'none';'average';'disk';'gaussian'};
filterText = {'';'Number of pixels:';'Radius (number of pixels):';[char(963),' (Number of pixels):']};

% Filter 1
hpf.par.filter1.text = uicontrol('Parent',hpf.par.pan,'Style','text','String','Filter 1:','units','pixels','Position',[5 272 50 18],'FontSize',10,'HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8]);
filter1 = settings.filter1.type;
val = find(strcmp(filters,filter1));
if isempty(val)
    val = 1;
end
hpf.par.filter1.type = uicontrol('Parent',hpf.par.pan,'Style','popupmenu','String',filters,'Value',val,'units','pixels','Position',[80 272 90 22],'FontSize',10);
hpf.par.filter1.valText = uicontrol('Parent',hpf.par.pan,'Style','Edit','String',filterText{val},'units','pixels','Position',[20 240 140 23],'FontSize',10,'Enable','inactive');
filter1val = settings.filter1.val;
if strcmp(filters{val},'none')
    string = '';
    state = 'inactive';
else
    string = num2str(filter1val);
    state = 'on';
end
hpf.par.filter1.val = uicontrol('Parent',hpf.par.pan,'Style','edit','String',string,'units','pixels','Position',[159 240 50 23],'FontSize',10,'Enable',state);
% set(hpf.par.filter1.text,'units','normalized')
% set(hpf.par.filter1.type,'units','normalized')
% set(hpf.par.filter1.valText,'units','normalized')
% set(hpf.par.filter1.val,'units','normalized')

% Filter 2
hpf.par.filter2.text = uicontrol('Parent',hpf.par.pan,'Style','text','String','Filter 2:','units','pixels','Position',[5 192 50 18],'FontSize',10,'HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8]);
filter2 = settings.filter2.type;
val = find(strcmp(filters,filter2));
if isempty(val)
    val = 1;
end
hpf.par.filter2.type = uicontrol('Parent',hpf.par.pan,'Style','popupmenu','String',filters,'Value',val,'units','pixels','Position',[80 192 90 22],'FontSize',10);
hpf.par.filter2.valText = uicontrol('Parent',hpf.par.pan,'Style','Edit','String',filterText{val},'units','pixels','Position',[20 160 140 23],'FontSize',10,'Enable','inactive');
filter2val = settings.filter2.val;
if strcmp(filters{val},'none')
    string = '';
    state = 'inactive';
else
    string = num2str(filter2val);
    state = 'on';
end
hpf.par.filter2.val = uicontrol('Parent',hpf.par.pan,'Style','edit','String',string,'units','pixels','Position',[159 160 50 23],'FontSize',10,'Enable',state);

% Filter 3
hpf.par.filter3.text = uicontrol('Parent',hpf.par.pan,'Style','text','String','Filter 3:','units','pixels','Position',[5 112 50 18],'FontSize',10,'HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8]);
filter3 = settings.filter3.type;
val = find(strcmp(filters,filter3));
if isempty(val)
    val = 1;
end
hpf.par.filter3.type = uicontrol('Parent',hpf.par.pan,'Style','popupmenu','String',filters,'Value',val,'units','pixels','Position',[80 112 90 22],'FontSize',10);
hpf.par.filter3.valText = uicontrol('Parent',hpf.par.pan,'Style','Edit','String',filterText{val},'units','pixels','Position',[20 80 140 23],'FontSize',10,'Enable','inactive');
filter3val = settings.filter3.val;
if strcmp(filters{val},'none')
    string = '';
    state = 'inactive';
else
    string = num2str(filter1val);
    state = 'on';
end
hpf.par.filter3.val = uicontrol('Parent',hpf.par.pan,'Style','edit','String',string,'units','pixels','Position',[159 80 50 23],'FontSize',10,'Enable',state);

% Reset button
hpf.par.reset = uicontrol('Parent',hpf.par.pan,'Style','pushbutton','String','Reset values','units','pixels','Position',[10 34 102.5 22],'FontSize',10);
% store button
hpf.par.store = uicontrol('Parent',hpf.par.pan,'Style','pushbutton','String','Store values','units','pixels','Position',[112.5 34 102.5 22],'FontSize',10);
% Test peak finder button
hpf.par.findPeaks = uicontrol('Parent',hpf.par.pan,'Style','pushbutton','String','Test peak finder','units','pixels','Position',[10 10 205 22],'FontSize',10);

% Now show the image
s = size(obs);
if strcmp(filter1,'none')
    filt1 = ones(s(1),s(2));
elseif strcmp(filter1,'average')
    if filter1val~=round(filter1val)
        filter1val = round(filter1val);
    end
    filt1 = zeros(s(1),s(2));
    filt1(ceil(s(1)/2)-filter1val+2:ceil(s(1)/2)+filter1val,ceil(s(2)/2)-filter1val+2:ceil(s(2)/2)+filter1val) = 1/filter1val^2;
    filt1 = fftshift(fft2(ifftshift(filt1)));
elseif strcmp(filter1,'disk')
    [x,y] = meshgrid(-ceil(s(2)/2):ceil(s(2)/2)-1 , -ceil(s(1)/2):ceil(s(1)/2)-1);
    R = sqrt(x.^2+y.^2)+1;
    filt1 = (R<=filter1val)/max( sum(sum(R<=filter1val)), 1);
    filt1 = fftshift(fft2(ifftshift( filt1 )));
else
    filt1 = fftshift(fft2(ifftshift(fspecial(filter1,[s(1) s(2)],filter1val))));
end
if strcmp(filter2,'none')
    filt2 = ones(s(1),s(2));
elseif strcmp(filter2,'average')
    if filter2val~=round(filter2val)
        filter2val = round(filter2val);
    end
    filt2 = zeros(s(1),s(2));
    filt2(ceil(s(1)/2)-filter2val+2:ceil(s(1)/2)+filter2val,ceil(s(2)/2)-filter2val+2:ceil(s(2)/2)+filter2val) = 1/filter2val^2;
    filt2 = fftshift(fft2(ifftshift(filt2)));
elseif strcmp(filter2,'disk')
    [x,y] = meshgrid(-ceil(s(2)/2):ceil(s(2)/2)-1 , -ceil(s(1)/2):ceil(s(1)/2)-1);
    R = sqrt(x.^2+y.^2)+1;
    filt2 = (R<=filter2val)/max( sum(sum(R<=filter2val)), 1);
    filt2 = fftshift(fft2(ifftshift( filt2/sum(sum(filt2)) )));
else
    filt2 = fftshift(fft2(ifftshift(fspecial(filter2,[s(1) s(2)],filter2val))));
end
if strcmp(filter3,'none')
    filt3 = ones(s(1),s(2));
elseif strcmp(filter3,'average')
    if filter3val~=round(filter3val)
        filter3val = round(filter3val);
    end
    filt3 = zeros(s(1),s(2));
    filt3(ceil(s(1)/2)-filter3val+2:ceil(s(1)/2)+filter3val,ceil(s(2)/2)-filter3val+2:ceil(s(2)/2)+filter3val) = 1/filter3val^2;
    filt3 = fftshift(fft2(ifftshift(filt3)));
elseif strcmp(filter3,'disk')
    [x,y] = meshgrid(-ceil(s(2)/2):ceil(s(2)/2)-1 , -ceil(s(1)/2):ceil(s(1)/2)-1);
    R = sqrt(x.^2+y.^2)+1;
    filt3 = (R<=filter3val)/max( sum(sum(R<=filter3val)), 1);
    filt3 = fftshift(fft2(ifftshift( filt3/sum(sum(filt3)) )));
else
    filt3 = fftshift(fft2(ifftshift(fspecial(filter3,[s(1) s(2)],filter3val))));
end
obsF = fftshift(fft2(ifftshift(obs)));
obsFilt = real(fftshift(ifft2(ifftshift(obsF.*filt1.*filt2.*filt3))));
ax = hpf.image.ax;
axes(ax)
obsPlot = (obsFilt>thres).*obsFilt + (obsFilt<=thres).*thres;

imagesc(obsPlot);colormap gray;axis equal off

% Update threshold min and max
low = min(min(obsFilt));
high = max(max(obsFilt));
if thres<low
    thres = low;
elseif thres>high
    thres = high;
end
settings.thres = thres;
set(Slider,'Min',low,'Max',high,'Value',thres)
set(TXTthres,'String',num2str(thres))
set(TXTlow,'String',num2str(low,2))
set(TXThigh,'String',num2str(high,2))

% Close figure button
hpf.close = uicontrol('Parent',hpf.fig,'Style','pushbutton','String','Close','units','normalized','Position',[0.71 0.015 0.135 0.05],'FontSize',10);
hpf.storeClose = uicontrol('Parent',hpf.fig,'Style','pushbutton','String','Store and close','units','normalized','Position',[0.855 0.015 0.135 0.05],'FontSize',10);

% Callbacks
set(TXTthres,'Callback',{@upThres,Slider})
set(Slider,'Callback',{@slideThres,TXTthres})
set(hpf.par.filter1.type,'Callback',{@upFilt1,hpf.par.filter1.valText,hpf.par.filter1.val})
set(hpf.par.filter1.val,'Callback',@upFilt1Val)
set(hpf.par.filter2.type,'Callback',{@upFilt2,hpf.par.filter2.valText,hpf.par.filter2.val})
set(hpf.par.filter2.val,'Callback',@upFilt2Val)
set(hpf.par.filter3.type,'Callback',{@upFilt3,hpf.par.filter3.valText,hpf.par.filter3.val})
set(hpf.par.filter3.val,'Callback',@upFilt3Val)
set(hpf.par.reset,'Callback',{@resetPar,hpf})
set(hpf.par.store,'Callback',@storePar)
set(hpf.close,'Callback',{@closeFig,hpf.fig})
set(hpf.storeClose,'Callback',{@closeStoreFig,hpf.fig})
set(hpf.par.findPeaks,'Callback',{@findPeaks,obs})

uiwait(hpf.fig)

    function resetPar(~,~,hpf)
        thres = settings.thres;
        filter1 = settings.filter1.type;
        filter1val = settings.filter1.val;
        filter2 = settings.filter2.type;
        filter2val = settings.filter2.val;
        filter3 = settings.filter3.type;
        filter3val = settings.filter3.val;
        
        % Update GUI
        set(TXTthres,'String',num2str(thres))
        value = find(strcmp(filters,filter1));
        set(hpf.par.filter1.type,'Value',value)
        set(hpf.par.filter1.valText,'String',filterText{value});
        if strcmp(filter1,'none')
            set(hpf.par.filter1.val,'String','','Enable','inactive')
        else
            set(hpf.par.filter1.val,'String',num2str(filter1val),'Enable','on')
        end
        value = find(strcmp(filters,filter2));
        set(hpf.par.filter2.type,'Value',value)
        set(hpf.par.filter2.valText,'String',filterText{value});
        if strcmp(filter2,'none')
            set(hpf.par.filter2.val,'String','','Enable','inactive')
        else
            set(hpf.par.filter2.val,'String',num2str(filter2val),'Enable','on')
        end
        value = find(strcmp(filters,filter3));
        set(hpf.par.filter3.type,'Value',value)
        set(hpf.par.filter3.valText,'String',filterText{value});
        if strcmp(filter3,'none')
            set(hpf.par.filter3.val,'String','','Enable','inactive')
        else
            set(hpf.par.filter3.val,'String',num2str(filter3val),'Enable','on')
        end
        
        % Update filters
        crFilt1()
        crFilt2()
        crFilt3()
        filtImg()
    end

    function storePar(~,~)
        settings.thres = thres;
        settings.filter1.type =  filter1;
        settings.filter1.val = filter1val;
        settings.filter2.type = filter2;
        settings.filter2.val = filter2val;
        settings.filter3.type = filter3;
        settings.filter3.val = filter3val;
        settings.store = 1;
    end

    function slideThres(hObject,~,h_valThres)
        thres = get(hObject,'Value');
        set(h_valThres,'String',num2str(thres))
        upImg()
    end

    function upThres(hObject,~,h_slidThres)
        thres = str2double(get(hObject,'String'));
        if isnan(thres) || thres<low
            thres = low;
            set(hObject,'String',num2str(thres))
        elseif thres>high
            thres = high;
            set(hObject,'String',num2str(thres))
        end
        set(h_slidThres,'Value',thres)
        upImg()
    end

    function upFilt1(hObject,~,valText,val)
        value = get(hObject,'Value');
        filter1 = filters{value};
        set(valText,'String',filterText{value})
        if value==1
            set(val,'String','','Enable','inactive')
        else
            set(val,'String',num2str(filter1val),'Enable','on')
        end
        crFilt1()
        filtImg()
    end

    function upFilt1Val(hObject,~)
        filter1val = str2double(get(hObject,'String'));
        if isnan(filter1val) || filter1val==0
            filt1 = zeros(s(1),s(2));
            filtImg()
        else
            crFilt1()
            filtImg()
        end
    end

    function crFilt1()
        if strcmp(filter1,'none')
            filt1 = ones(s(1),s(2));
        elseif strcmp(filter1,'average')
            if filter1val~=round(filter1val)
                filter1val = round(filter1val);
            end
            filt1 = zeros(s(1),s(2));
            filt1(ceil(s(1)/2)-filter1val+2:ceil(s(1)/2)+filter1val,ceil(s(2)/2)-filter1val+2:ceil(s(2)/2)+filter1val) = 1/filter1val^2;
            filt1 = fftshift(fft2(ifftshift(filt1)));
        elseif strcmp(filter1,'disk')
            [x,y] = meshgrid(-ceil(s(2)/2):ceil(s(2)/2)-1 , -ceil(s(1)/2):ceil(s(1)/2)-1);
            R = sqrt(x.^2+y.^2)+1;
            filt1 = (R<=filter1val)/max( sum(sum(R<=filter1val)), 1);
            filt1 = fftshift(fft2(ifftshift( filt1 )));
        else
            filt1 = fftshift(fft2(ifftshift(fspecial(filter1,[s(1) s(2)],filter1val))));
        end
    end

    function upFilt2(hObject,~,valText,val)
        value = get(hObject,'Value');
        filter2 = filters{value};
        set(valText,'String',filterText{value})
        if value==1
            set(val,'String','','Enable','inactive')
        else
            set(val,'String',num2str(filter2val),'Enable','on')
        end
        crFilt2()
        filtImg()
    end

    function upFilt2Val(hObject,~)
        filter2val = str2double(get(hObject,'String'));
        if isnan(filter2val) || filter2val==0
            filt2 = zeros(s(1),s(2));
            filtImg()
        else
            crFilt2()
            filtImg()
        end
    end

    function crFilt2()
        if strcmp(filter2,'none')
            filt2 = ones(s(1),s(2));
        elseif strcmp(filter2,'average')
            if filter2val~=round(filter2val)
                filter2val = round(filter2val);
            end
            filt2 = zeros(s(1),s(2));
            filt2(ceil(s(1)/2)-filter2val+2:ceil(s(1)/2)+filter2val,ceil(s(2)/2)-filter2val+2:ceil(s(2)/2)+filter2val) = 1/filter2val^2;
            filt2 = fftshift(fft2(ifftshift(filt2)));
        elseif strcmp(filter2,'disk')
            [x,y] = meshgrid(-ceil(s(2)/2):ceil(s(2)/2)-1 , -ceil(s(1)/2):ceil(s(1)/2)-1);
            R = sqrt(x.^2+y.^2)+1;
            filt2 = (R<=filter2val)/max( sum(sum(R<=filter2val)), 1);
            filt2 = fftshift(fft2(ifftshift( filt2 )));
        else
            filt2 = fftshift(fft2(ifftshift(fspecial(filter2,[s(1) s(2)],filter2val))));
        end
    end

    function upFilt3(hObject,~,valText,val)
        value = get(hObject,'Value');
        filter3 = filters{value};
        set(valText,'String',filterText{value})
        if value==1
            set(val,'String','','Enable','inactive')
        else
            set(val,'String',num2str(filter3val),'Enable','on')
        end
        crFilt3()
        filtImg()
    end

    function upFilt3Val(hObject,~)
        filter3val = str2double(get(hObject,'String'));
        if isnan(filter3val) || filter3val==0
            filt3 = zeros(s(1),s(2));
            filtImg()
        else
            crFilt3()
            filtImg()
        end
    end

    function crFilt3()
        if strcmp(filter3,'none')
            filt3 = ones(s(1),s(2));
        elseif strcmp(filter3,'average')
            if filter3val~=round(filter3val)
                filter3val = round(filter3val);
            end
            filt3 = zeros(s(1),s(2));
            filt3(ceil(s(1)/2)-filter3val+2:ceil(s(1)/2)+filter3val,ceil(s(2)/2)-filter3val+2:ceil(s(2)/2)+filter3val) = 1/filter3val^2;
            filt3 = fftshift(fft2(ifftshift(filt3)));
        elseif strcmp(filter3,'disk')
            [x,y] = meshgrid(-ceil(s(2)/2):ceil(s(2)/2)-1 , -ceil(s(1)/2):ceil(s(1)/2)-1);
            R = sqrt(x.^2+y.^2)+1;
            filt3 = (R<=filter3val)/max( sum(sum(R<=filter3val)), 1);
            filt3 = fftshift(fft2(ifftshift( filt3 )));
        else
            filt3 = fftshift(fft2(ifftshift(fspecial(filter3,[s(1) s(2)],filter3val))));
        end
    end

    function filtImg()
        obs2 = fftshift(ifft2(ifftshift(obsF)));
        % For averaging filter
        if size(filt1)~=size(obsF)
            obs2 = conv2(obs2,filt1,'same');
            f1 = ones(s(1),s(2));
        else
            f1 = filt1;
        end
        if size(filt2)~=size(obsF)
            obs2 = conv2(obs2,filt2,'same');
            f2 = ones(s(1),s(2));
        else
            f2 = filt2;
        end
        if size(filt3)~=size(obsF)
            obs2 = conv2(obs2,filt3,'same');
            f3 = ones(s(1),s(2));
        else
            f3 = filt3;
        end
        obs2 = fftshift(fft2(ifftshift(obs2)));
        obsFilt = real(fftshift(ifft2(ifftshift(obs2.*f1.*f2.*f3))));
        low = min(min(obsFilt));
        high = max(max(obsFilt));
        set(TXTlow,'String',num2str(low,2))
        set(TXThigh,'String',num2str(high,2))
        if thres<low
            thres = low;
            set(TXTthres,'String',num2str(thres))
        elseif thres>high
            thres = high;
            set(TXTthres,'String',num2str(thres))
        end
        set(Slider,'Min',low,'Max',high,'Value',thres)
        upImg()
    end

    function upImg()
        % Now update shown image
        axes(ax)
        obser = (obsFilt>thres).*obsFilt + (obsFilt<=thres).*thres;
        imagesc(obser);colormap gray;axis equal off
        drawnow
    end

    function findPeaks(~,~,obs)
        st.thres = thres;
        st.filter1.type =  filter1;
        st.filter1.val = filter1val;
        st.filter2.type = filter2;
        st.filter2.val = filter2val;
        st.filter3.type = filter3;
        st.filter3.val = filter3val;
        xy = peakFinder(obs,st);
        axes(ax)
        obs = (obsFilt>thres).*obsFilt + (obsFilt<=thres).*thres;
        imagesc(obs);colormap gray;axis equal off
        hold on
        plot(xy(:,1),xy(:,2),'r+')
        hold off
        drawnow
    end

    function closeFig(~,~,fig)
        close(fig)
    end

    function closeStoreFig(~,~,fig)
        storePar([],[])
        close(fig)
    end
        
    function deleteFigure(hObject,~)
        uiresume(hObject)
        delete(hObject)
    end
end
