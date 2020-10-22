function obj = tfm_PeakFinder2(obj)
    % tfm_PeakFinder2 - Interactive interface to  for the peak finding routine
    %
    %   syntax: obj = tfm_PeakFinder2(obj)
    %   Input:
    %       obj      - StatSTEM structure
    %   Output:
    %       obj      - StatSTEM structure
    
    %--------------------------------------------------------------------------
    % This file is part of StatSTEM
    %
    % Copyright: 2019, EMAT, University of Antwerp
    % Author: Thomas Friedrich
    % License: Open Source under GPLv3
    % Contact: sandra.vanaert@uantwerpen.be
    %--------------------------------------------------------------------------
    global thr d_min sigma xy hpf gr_cm cdat_0 ver
    % Determine Matlab version for compatibility
    ver = version('-release');
    ver = str2double(ver(1:4));

    obs = obj.obs;
    [ny,nx] = size(obs);
    
    thr = 0;
    sigma = 10;
    d_min = 0;
    
    %%%%%%%%%%%%%%%%%%
    %  Figure Window %
    %%%%%%%%%%%%%%%%%%

    % Create a new figure with given size and minimum size
    screensize = get(0, 'Screensize');
    s = round(screensize(3:4)*0.8);
    hpf.fig = figure('units','pixels','outerposition',[screensize(3)/2-s(1)/2 screensize(4)/2-s(2)/2 s(1) s(2)],'Name','Peak Finder','NumberTitle','off','Visible','on','Resize','on','DeleteFCN',@deleteFigure,'MenuBar','none','ToolBar','figure');
    figRSfun = @(~,~) set(hpf.fig, 'position', max([0 0 900 550], hpf.fig.Position));
    hpf.fig.SizeChangedFcn = figRSfun;

    % Normalized vertical panel split position and border width
    v_sec = 0.22;
    br = 0.01;
    
    % Create two sub-panels
    % Image Panel & Axis
    hpf.image.pan = uipanel('Parent',hpf.fig,'units','normalized','Position',[br v_sec 1-br*2 1-br*2-v_sec],'ShadowColor',[0 0 0],'ForegroundColor',[0 0 0],'HighlightColor',[0.95 0.95 0.95],'BackgroundColor',[0.8 0.8 0.8]);
    hpf.image.ax1 = subplot(1,2,1,'Parent',hpf.image.pan);
    hpf.image.ax2 = subplot(1,2,2,'Parent',hpf.image.pan);
   
    % Parameter Panel
    hpf.par.pan = uipanel('Parent',hpf.fig,'units','normalized','Position',[br br*2 1-br*2 v_sec-br],'ShadowColor',[0 0 0],'ForegroundColor',[0 0 0],'HighlightColor',[0.95 0.95 0.95],'BackgroundColor',[0.8 0.8 0.8]);
    hpf.par.wb = axes('Parent',hpf.par.pan,'Position',[1-0.38 br*6 .38-br .15]);
        % Makeshift Waitbar
        gr_cm = [linspace(0,0.1,64)' linspace(0,0.5,64)' linspace(0,1,64)' ];
        cdat_0 = zeros(1,128);
        cdat = cdat_0;
        cdat(1:32) = sin(linspace(0,pi,32));
        imagesc(hpf.par.wb,cdat); axis off; colormap(gr_cm); caxis([0 1]);
        if ver >= 2019
            hpf.par.wb.Toolbar = [];
        end

        % Info panel
        hpf.help.pan = uipanel('Parent',hpf.par.pan,'units','normalized','Position',[0.62 0.3 0.38-br 0.6],'ShadowColor',[0 0 0],'ForegroundColor',[0 0 0],'HighlightColor',[0.95 0.95 0.95],'BackgroundColor',[0.8 0.8 0.8]);
        str = 'To help the peak finder program to detect the correct local maxima, set the approximate radius and minimum distance of the atomic columns in pixel units. Further, you can filter the peaks by a threshold value (normalized). The radius value alters the noise filter and is the most critical parameter. Rerun the Peak finder manually after changing this value!';
        hpf.help.text = uicontrol('Parent',hpf.help.pan,'Style','text','String',str,'units','normalized','Position',[0 0 1 1],'FontSize',10,'BackgroundColor',[0.8 0.8 0.8],'horizontalAlignment', 'left');

    %%%%%%%%%%%%%%%%%%%%%%%%
    % Interactive Elements %
    %%%%%%%%%%%%%%%%%%%%%%%%

    
    % Slider & Label %
    %%%%%%%%%%%%%%%%%%
        %Sigma
        est_lim_s = mean(nx,ny)*0.1;
        SliderSi = uicontrol('Parent',hpf.par.pan,'Style','slider','units','normalized','Position',[br 0.38 0.2 0.15],'Min',3,'Max',est_lim_s);
        uicontrol('Parent',hpf.par.pan,'Style','text','String','Estimated Radius (px):','units','normalized','Position',[br 0.8 0.2 0.15],'FontSize',10,'HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8]);

        %Threshold
        SliderTh = uicontrol('Parent',hpf.par.pan,'Style','slider','units','normalized','Position',[br+0.2 0.38 0.2 0.15],'Min',0,'Max',1);
        uicontrol('Parent',hpf.par.pan,'Style','text','String','Threshold value:','units','normalized','Position',[br+0.2 0.8 0.2 0.15],'FontSize',10,'HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8]);

        %Peak Distance
        est_lim_d = mean(nx,ny)*0.2;
        SliderDm = uicontrol('Parent',hpf.par.pan,'Style','slider','units','normalized','Position',[br+0.4 0.38 0.2 0.15],'Min',0,'Max',est_lim_d);
        uicontrol('Parent',hpf.par.pan,'Style','text','String','Minimum Distance (px):','units','normalized','Position',[br+0.4 0.8 0.2 0.15],'FontSize',10,'HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8]);
    
    %    Textboxes   %
    %%%%%%%%%%%%%%%%%%
        txt_sig = uicontrol('Parent',hpf.par.pan,'Style','edit','String',num2str(thr),'units','normalized','Position',[br 0.6 0.2 0.15],'FontSize',10);
        txt_th = uicontrol('Parent',hpf.par.pan,'Style','edit','String',num2str(sigma),'units','normalized','Position',[0.2+br 0.6 0.2 0.15],'FontSize',10); 
        txt_d_min = uicontrol('Parent',hpf.par.pan,'Style','edit','String',num2str(d_min),'units','normalized','Position',[0.4+br 0.6 0.2 0.15],'FontSize',10);

    %    Buttons     %
    %%%%%%%%%%%%%%%%%%
        btn_width = 1/(5+br*7);
        hpf.par.findPeaks = uicontrol('Parent',hpf.par.pan,'Style','pushbutton','String','Run peak finder','units','normalized','Position',[br br*6 btn_width 0.2],'FontSize',10);
        hpf.close = uicontrol('Parent',hpf.par.pan,'Style','pushbutton','String','Cancel','units','normalized','Position',[br+btn_width br*6 btn_width 0.2],'FontSize',10);
        hpf.storeClose = uicontrol('Parent',hpf.par.pan,'Style','pushbutton','String','Confirm values','units','normalized','Position',[br+btn_width*2 br*6 btn_width 0.2],'FontSize',10);

        
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %      Set & Draw      %
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    % Textbox & Slider Values
    set(SliderTh,'Value',thr)
    set(txt_th,'String',num2str(thr))
    set(SliderSi,'Value',sigma)
    set(txt_sig,'String',num2str(sigma))
    set(SliderDm,'Value',d_min)
    set(txt_d_min,'String',num2str(d_min))
    
    % Callbacks
    set(txt_th,'Callback',{@upTXTbox,SliderTh,1,hpf})
    set(SliderTh,'Callback',{@slideThres,txt_th,1,hpf})
    set(txt_sig,'Callback',{@upTXTbox,SliderSi,2,hpf})
    set(SliderSi,'Callback',{@slideThres,txt_sig,2,hpf})
    set(txt_d_min,'Callback',{@upTXTbox,SliderDm,3,hpf})
    set(SliderDm,'Callback',{@slideThres,txt_d_min,3,hpf})
    
    set(hpf.close,'Callback',{@closeFig,hpf.fig})
    set(hpf.storeClose,'Callback',{@closeStoreFig,hpf.fig})
    set(hpf.par.findPeaks,'Callback',{@findPeaks,obs,hpf})
    
    % Draw
    drawnow();

    % Show the images, initial peak finding
    findPeaks([],[],obs,hpf)
    uiwait(hpf.fig)
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %      Functions       %
    %%%%%%%%%%%%%%%%%%%%%%%%
    

    function slideThres(hObject,~,h_valThres,prm,hpf)        
        switch prm
            case 1
                thr = get(hObject,'Value');
                set(h_valThres,'String',num2str(thr))
                findPeaks([],[],obs, hpf)
            case 2
                tim = run_waitbar(hpf.par.wb,cdat);
                sigma = get(hObject,'Value');
                set(h_valThres,'String',num2str(sigma))
                obs_fil = tfm_find_peaks_2d(obs, sigma, thr, d_min);
                xy = [];
                updatePlot(hpf,obs_fil)
                stop(tim);
                delete(tim);
                waitbar_out
            case 3
                d_min = get(hObject,'Value');
                set(h_valThres,'String',num2str(d_min))
                findPeaks([],[],obs, hpf)
        end
    end

    function upTXTbox(hObject,~,h_slidThres,prm, hpf)
        switch prm
            case 1
                thr = str2double(get(hObject,'String'));
                set(h_slidThres,'Value',thr)
                findPeaks([],[],obs, hpf)
            case 2
                tim = run_waitbar(hpf.par.wb,cdat);
                sigma = str2double(get(hObject,'String'));
                set(h_slidThres,'Value',sigma)
                obs_fil = tfm_find_peaks_2d(obs, sigma, thr, d_min);
                xy = [];
                updatePlot(hpf,obs_fil)
                stop(tim);
                delete(tim);
                waitbar_out
            case 3
                d_min = str2double(get(hObject,'String'));
                set(h_slidThres,'Value',d_min)
                findPeaks([],[],obs, hpf)
        end
        
        updatePlot(hpf,obs_fil)
    end
    
    function updatePlot(hpf,obs_fil)
        
        subplot(hpf.image.ax1);
        imagesc(obs);colormap gray;axis equal off;

        subplot(hpf.image.ax2);
        imagesc(obs_fil);colormap gray;axis equal off;

        if ~isempty(xy)
            hold on;
            plot(xy(:,1),xy(:,2),'.r')
            hold off;
        end
        
        waitbar_out;
        
    end
   
    function findPeaks(~,~,obs,hpf)
        
        tim = run_waitbar(hpf.par.wb,cdat);
        
        [obs_fil, xy] = tfm_find_peaks_2d(obs, sigma, thr, d_min);
       
        updatePlot(hpf,obs_fil)
        
        stop(tim);
        delete(tim);
        
        waitbar_out;
    end

    function closeStoreFig(~,~,fig)
        obj.coordinates = [xy*obj.dx,ones(length(xy),1)];
        close(fig)
    end
    
    function closeFig(~,~,fig)
        close(fig)
    end

    function deleteFigure(hObject,~)
        uiresume(hObject)
        delete(hObject)
    end


    function waitbar_out()
        hpf.par.wb.Children.CData = cdat_0;
        set(hpf.par.wb,'visible','off')
        if ver >= 2019
            hpf.par.wb.Colormap = gr_cm;
        end
        drawnow;
    end

    function timerObject = run_waitbar(wb_axis,cdat)

        timerDat.axes = wb_axis;
        timerDat.im_dat = cdat;
        timerDat.n_tick = 1;
        timerObject = timer('TimerFcn',@tick,...
                            'ExecutionMode','fixedRate',...
                            'Period',0.05,...
                            'UserData', timerDat);
        start(timerObject);

        function tick(timerObj,event)
             timerData = get(timerObj, 'UserData');
             im = timerData.im_dat;
             im = circshift(im,timerData.n_tick*5,2);
             timerData.axes.Children.CData = im; 
             if ver >= 2019
                timerData.axes.Colormap = gr_cm;
             end
             timerData.n_tick = timerData.n_tick + 1;
             set(timerObj, 'UserData', timerData);
             drawnow
        end
    end
end