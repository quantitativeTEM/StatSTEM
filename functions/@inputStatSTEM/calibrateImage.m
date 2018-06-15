function obj = calibrateImage(obj)
% calibrateImage - Normalize image with respect to the incident beam
%
% syntax: obj = calibrateImage(obj)
%       obj - inputStatSTEM file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Starting values
Ivac = 0;
Idet = 1;
exNorm = 0;
convToEC = 0;
dx = obj.dx;
DT = 1; % Dwell time (micro seconds)
BC = 1; % Beam current (Ampere)
e = 1.60217622*10^-19; % Electron charge (C)

%% Make GUI
if isempty(obj.GUI)
    pos = get( 0, 'Screensize' );
else
    pos = get( gcf, 'Position' );
end
cent = [pos(1)+pos(3)/2 pos(2)+pos(4)/2];
s = [215,250];
hf = figure('units','pixels','outerposition',[cent(1)-s(1)/2 cent(2)-s(2)/2 s(1) s(2)],'Name','Fill in calibration values',...
    'NumberTitle','off','MenuBar','none','Resize','off','Visible','on','Color',[0.94,0.94,0.94]);

tIvac = uicontrol('Parent',hf,'Style','Text','String','Intensity vacuum:','Position',[10 170 95 22],'BackgroundColor',[0.94,0.94,0.94]);
tIdet = uicontrol('Parent',hf,'Style','Text','String','Intensity maximum:','Position',[10 140 100 22],'BackgroundColor',[0.94,0.94,0.94]);

eVac = uicontrol('Parent',hf,'Style','Edit','String',num2str(Ivac),'Position',[110 173 80 22],'Callback',{@setIvac});
eDet = uicontrol('Parent',hf,'Style','Edit','String',num2str(Idet),'Position',[110 143 80 22],'Callback',{@setIdet});

pDet = uicontrol('Parent',hf,'Style','pushbutton','String','Load values from detector map','Position',[10 110 180 22],'Callback',@loadDet);

pPix = uipanel('Parent',hf,'units','pixels','Position',[1 45 199 55],'Title','Use electron counts','BackgroundColor',[0.8 0.8 0.8]);

cPix = uicontrol('Parent',pPix,'Style','checkbox','String','Convert calibrated map','Position',[10 10 180 22],'BackgroundColor',[0.8 0.8 0.8],'Callback',{@showECopt,hf});

uicontrol('Parent',hf,'Style','pushbutton','String','OK','Position',[65 10 60 22],'Callback',{@storeVal,hf});
uicontrol('Parent',hf,'Style','pushbutton','String','Cancel','Position',[130 10 60 22],'Callback',{@cancel,hf});

waitfor(hf)

% Normalise image
if exNorm
    obj.obs = (obj.obs-Ivac)/(Idet-Ivac);
    if convToEC
        d = DT*10^-18*BC/e;
        obj.obs = obj.obs*d;
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

    function showECopt(hObject,~,hf,but)
        if nargin<4
            but = {};
        end
        val = get(hObject,'Value');
        pS = get(hf,'outerposition');
        if val
            shift = 100;
            convToEC = true;
        else
            shift = 0;
            convToEC = false;
        end
        sF = [215,250+shift];
        pS = [pS(1)+pS(3)/2-sF(1)/2,pS(2)+pS(4)-sF(2),sF(1),sF(2)];
        set(hf,'outerposition',pS)
        set(tIvac,'Position',[10 170+shift 95 22])
        set(tIdet,'Position',[10 140+shift 100 22])
        set(eVac,'Position',[110 173+shift 80 22])
        set(eDet,'Position',[110 143+shift 80 22])
        set(pDet,'Position',[10 110+shift 180 22])
        set(pPix,'Position',[1 45 199 55+shift])
        set(cPix,'Position',[10 10+shift 180 22])
        
        % Insert new buttons if needed
        if val
            % Dwell Time
            tDw = uicontrol('Parent',pPix,'Style','Text','BackgroundColor',[0.8 0.8 0.8],...
                'Position',[40 80 55 22],'String','Dwell time:');
            eDw = uicontrol('Parent',pPix,'Style','Edit','Position',[110 83 60 22],'String',num2str(DT));
            eDwU = uicontrol('Parent',pPix,'Style','Edit','Position',[170 83 20 22],'Enable','Inactive','String',[char(181),'s'],'BackgroundColor',[0.9 0.9 0.9]);
            
            % Beam current
            tBC = uicontrol('Parent',pPix,'Style','Text','BackgroundColor',[0.8 0.8 0.8],...
                'Position',[40 58 70 22],'String','Beam current:');
            eBC = uicontrol('Parent',pPix,'Style','Edit','Position',[110 61 60 22],'String',num2str(BC));
            eBCU = uicontrol('Parent',pPix,'Style','Edit','Position',[170 61 20 22],'Enable','Inactive','String','pA','BackgroundColor',[0.9 0.9 0.9]);
            
            % Dose
            tD = uicontrol('Parent',pPix,'Style','Text','BackgroundColor',[0.8 0.8 0.8],...
                'Position',[10 28 35 22],'String','Dose:');
            eD = uicontrol('Parent',pPix,'Style','Edit','Position',[50 31 90 22],'String','');
            eDU = uicontrol('Parent',pPix,'Style','Edit','Position',[140 31 50 22],'Enable','inactive','String',sprintf('e¯/pixel'),'BackgroundColor',[0.9 0.9 0.9]);
            eDA = uicontrol('Parent',pPix,'Style','Edit','Position',[50 9 90 22],'String','');
            eDAU = uicontrol('Parent',pPix,'Style','Edit','Position',[140 9 50 22],'Enable','inactive','String',sprintf('e¯/Å'),'BackgroundColor',[0.9 0.9 0.9]);
            updateDose(eD,eDA)
            buttons = {tDw;eDw;eDwU;tBC;eBC;eBCU;tD;eD;eDU;eDA;eDAU};
            set(hObject,'Callback',{@showECopt,hf,buttons})
            set(eDw,'Callback',{@editDw,eD,eDA})
            set(eBC,'Callback',{@editBC,eD,eDA})
            set(eD,'Callback',{@editDose,eDw,eDA})
            set(eDA,'Callback',{@editDoseA,eDw,eD})
        else
            N = length(but);
            for i=1:N
                delete(but{i})
            end
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