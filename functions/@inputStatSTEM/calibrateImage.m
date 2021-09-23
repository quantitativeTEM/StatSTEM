function obj = calibrateImage(obj)
    % calibrateImage - Normalize image with respect to the incident beam
    %
    % syntax: obj = calibrateImage(obj)
    %       obj - inputStatSTEM file
    %
    
    %--------------------------------------------------------------------------
    % This file is part of StatSTEM
    %
    % Copyright: 2020, EMAT, University of Antwerp
    % Author: K.H.W. van den Bos, J. Fatermans, Th. Friedrich
    % License: Open Source under GPLv3
    % Contact: sandra.vanaert@uantwerpen.be
    %--------------------------------------------------------------------------
        
        % Starting values
        Ivac = 0;
        Idet = 1;
        exNorm = 0;
        convToEC = 0;
        dx = obj.dx;
        DT = 1; % Pixel dwell time (micro seconds)
        BC = 1; % Beam current (picoampere)
        e = 1.60217622*10^-19; % Electron charge (C)
    
        %% Make GUI
        if isempty(obj.GUI)
            pos = get( 0, 'Screensize' );
        else
            pos = get( gcf, 'Position' );
        end
        cent = [pos(1)+pos(3)/2 pos(2)+pos(4)/2];
        s = [300,480];
        hf = figure('units','pixels','outerposition',[cent(1)-s(1)/2 cent(2)-s(2)/2 s(1) s(2)],'Name','Fill in calibration values',...
            'NumberTitle','off','MenuBar','none','Resize','on','Visible','on','Color',[0.94,0.94,0.94]);
    
        br = 0.01;      % Relative border size (Padding around objects)
        n_rows = 10;    % Establish scalable grid-layout
        n_cols = 2;
        tx_height = (1/n_rows)-(br);
        grid_v = linspace(1-br*2,br,n_rows+1)-tx_height;
        grid_h = linspace(br,1-br*2,n_cols+1);
    
        uicontrol('Parent',hf,'Style','Text','String','Intensity vacuum:','units','normalized','Position',[grid_h(1) grid_v(1) grid_h(2) tx_height],'HorizontalAlignment','left','BackgroundColor',[0.94,0.94,0.94]);
        uicontrol('Parent',hf,'Style','Text','String','Intensity detector:','units','normalized','Position',[grid_h(1) grid_v(2) grid_h(2) tx_height],'HorizontalAlignment','left', 'BackgroundColor',[0.94,0.94,0.94]);
    
        eVac = uicontrol('Parent',hf,'Style','Edit','String',num2str(Ivac),'units','normalized','Position',[grid_h(2) grid_v(1) grid_h(2) tx_height],'Callback',{@setIvac});
        eDet = uicontrol('Parent',hf,'Style','Edit','String',num2str(Idet),'units','normalized','Position',[grid_h(2) grid_v(2) grid_h(2) tx_height],'Callback',{@setIdet});
    
        uicontrol('Parent',hf,'Style','pushbutton','String','Load values from detector map','units','normalized','Position',[grid_h(1) grid_v(3) grid_h(3) tx_height],'Callback',@loadDet);
        
        % SUBPANEL
        % Grid for sub-panel
        n_rows = 8;
        n_cols = 2;
        tx_height2 = (1/n_rows)-(br);
        grid_v2 = linspace(1-br*2,br,n_rows+1)-tx_height2;
        grid_h2 = linspace(br,1-br*2,n_cols+1);
        
        pPix_Pos_active = [grid_h(1) grid_v(9) grid_h(3) tx_height*6.3];
        pPix_Pos_inactive = [grid_h(1) grid_v(4) grid_h(3) tx_height];
        pPix = uipanel('Parent',hf,'units','normalized','Position',pPix_Pos_inactive,'Title','Use electron counts','BackgroundColor',[0.8 0.8 0.8]);
        
        %Checkbox
        cPix = uicontrol('Parent',pPix,'Style','checkbox','String','Convert image to electron counts','units','normalized','Position',[br br 1-br 1-br],'BackgroundColor',[0.8 0.8 0.8],'Callback',{@showECopt});
    
        % Dwell Time
        tDw = uicontrol('Parent',pPix,'Visible','off','Style','Text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],...
            'units','normalized','Position',[grid_h2(1) grid_v2(2) grid_h2(3) tx_height2/2],'String','Dwell time:');
        eDw = uicontrol('Parent',pPix,'Visible','off','Style','Edit','units','normalized','Position',[grid_h2(1) grid_v2(3) grid_h2(2) tx_height2],'String',num2str(DT));
        eDwU = uicontrol('Parent',pPix,'Visible','off','Style','Edit','units','normalized','Position',[grid_h2(2) grid_v2(3) grid_h2(2) tx_height2],'Enable','Inactive','String',[char(181),'s'],'BackgroundColor',[0.9 0.9 0.9]);
    
        % Beam current
        tBC = uicontrol('Parent',pPix,'Visible','off','Style','Text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],...
            'units','normalized','Position',[grid_h2(1) grid_v2(4) grid_h2(3) tx_height2/2],'String','Beam current:');
        eBC = uicontrol('Parent',pPix,'Visible','off','Style','Edit','units','normalized','Position',[grid_h2(1) grid_v2(5) grid_h2(2) tx_height2],'String',num2str(BC));
        eBCU = uicontrol('Parent',pPix,'Visible','off','Style','Edit','units','normalized','Position',[grid_h2(2) grid_v2(5) grid_h2(2) tx_height2], 'Enable','Inactive','String','pA','BackgroundColor',[0.9 0.9 0.9]);
    
        % Dose
        tD = uicontrol('Parent',pPix,'Visible','off','Style','Text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],...
            'units','normalized','Position',[grid_h2(1) grid_v2(6) grid_h2(3) tx_height2/2],'String','Dose:');
        eD = uicontrol('Parent',pPix,'Visible','off','Style','Edit','units','normalized','Position',[grid_h2(1) grid_v2(7) grid_h2(2) tx_height2],'String','');
        eDU = uicontrol('Parent',pPix,'Visible','off','Style','Edit','units','normalized','Position',[grid_h2(2) grid_v2(7) grid_h2(2) tx_height2],'Enable','inactive','String',sprintf('e�/pixel'),'BackgroundColor',[0.9 0.9 0.9]);
        eDA = uicontrol('Parent',pPix,'Visible','off','Style','Edit','units','normalized','Position',[grid_h2(1) grid_v2(8) grid_h2(2) tx_height2],'String','');
        eDAU = uicontrol('Parent',pPix,'Visible','off','Style','Edit','units','normalized','Position',[grid_h2(2) grid_v2(8) grid_h2(2) tx_height2],'Enable','inactive','String',sprintf('e�/�'),'BackgroundColor',[0.9 0.9 0.9]);
    
        set(cPix,'Callback',{@showECopt})
        set(eDw,'Callback',{@editDw,eD,eDA})
        set(eBC,'Callback',{@editBC,eD,eDA})
        set(eD,'Callback',{@editDose,eDw,eDA})
        set(eDA,'Callback',{@editDoseA,eDw,eD})
    
        uicontrol('Parent',hf,'Style','pushbutton','String','OK','units','normalized','Position',[grid_h(1) br grid_h(2) tx_height],'Callback',{@storeVal,hf});
        uicontrol('Parent',hf,'Style','pushbutton','String','Cancel','units','normalized','Position',[grid_h(2) br grid_h(2) tx_height],'Callback',{@cancel,hf});
    
        waitfor(hf)
    
        % Normalise image
        if exNorm
            obj.obs = (obj.obs-Ivac)/(Idet-Ivac);
            if convToEC
                d = DT*10^-18*BC/e;
                obj.obs = obj.obs*d;
                obj.zetamax = max(max(obj.obs));
                obj.etamax = obj.zetamax;
            end
        end

        function setIvac(hObject,~)
            val = str2double(get(hObject,'String'));
            if isnan(val)
                set(hObject,'String',num2str(Ivac))
            else
                Ivac = val;
            end
        end

        function setIdet(hObject,~)
            val = str2double(get(hObject,'String'));
            if isnan(val)
                set(hObject,'String',num2str(Idet))
            else
                Idet = val;
            end
        end

        function storeVal(~,~,hf)
            exNorm = true;
            close(hf)
        end

        function loadDet(~,~)
            % Load the detector image
            file = loadStatSTEMfile();
            Detector = file.input.obs;

            Nlow = 20000;
            % Number of values to estimate highest value
            Nhigh = 1000;

            % Reshape detector
            Nx = size(Detector,2);
            Ny = size(Detector,1);
            Det_res = reshape(Detector,Nx*Ny,1);
            Det_res_sort = sort(Det_res,'ascend');

            % Find a threshold value
            t = 0.1;
            Ivac = mean(Det_res_sort(1:Nlow));
            Imax = mean(Det_res_sort(Nx*Ny-Nhigh:Nx*Ny));
            Ithres = Ivac + t*(Imax-Ivac);

            % Idet
            det_area = Detector>=Ithres;
            Idetector = Detector.*det_area;
            Idet = sum(sum(Idetector.*det_area))/sum(sum(det_area));

            % Update GUI
            set(eVac,'String',num2str(Ivac))
            set(eDet,'String',num2str(Idet))
        end

        function cancel(~,~,hf)
            close(hf)
        end

        function showECopt(hObject,~) 
            val = get(hObject,'Value');
            if val
                convToEC = true;
            else
                convToEC = false;
            end
            buttons = [tDw;eDw;eDwU;tBC;eBC;eBCU;tD;eD;eDU;eDA;eDAU];

            if val 
                pPix.Position = pPix_Pos_active;
                cPix.Position = [grid_h2(1) grid_v2(1) grid_h2(3) tx_height2];
                set(buttons, 'Visible', 'on');
                updateDose(eD,eDA)
                set(eDw,'Callback',{@editDw,eD,eDA})
                set(eBC,'Callback',{@editBC,eD,eDA})
                set(eD,'Callback',{@editDose,eDw,eDA})
                set(eDA,'Callback',{@editDoseA,eDw,eD})
            else
                set(buttons, 'Visible', 'off');
                pPix.Position = pPix_Pos_inactive;
                cPix.Position = [br br 1-br 1-br];
            end
        end

        function editDw(hObject,~,eD,eDA)
            val = str2double(get(hObject,'String'));
            if isnan(val)
                set(hObject,'String',num2str(DT))
            else
                DT = val;
            end
            updateDose(eD,eDA)
        end

        function editBC(hObject,~,eD,eDA)
            val = str2double(get(hObject,'String'));
            if isnan(val)
                set(hObject,'String',num2str(BC))
            else
                BC = val;
            end
            updateDose(eD,eDA)
        end

        function updateDose(eD,eDA)
            dose = DT*10^-18*BC/e;
            doseA = dose/dx^2;
            set(eD,'String',num2str(dose))
            set(eDA,'String',num2str(doseA))
        end

        function editDose(hObject,~,eDw,eDA)
            dose = str2double(get(hObject,'String'));
            if isnan(dose)
                updateDose(hObject,eDA)
                return
            end
            DT = dose*e*10^18/BC;
            doseA = dose/dx^2;
            set(eDw,'String',num2str(DT))
            set(eDA,'String',num2str(doseA))
        end

        function editDoseA(hObject,~,eDw,eD)
            doseA = str2double(get(hObject,'String'));
            if isnan(doseA)
                updateDose(eD,hObject)
                return
            end
            dose = doseA*dx^2;
            DT = dose*e*10^18/BC;
            set(eDw,'String',num2str(DT))
            set(eD,'String',num2str(dose))
        end
    end
    