function [h,panels] = panelMaker(h,option,forCompiling)
% panelMaker - Create left panels using native MATLAB uicontrol components
%
%   Requires MATLAB R2019b or newer.
%
%   syntax: [h,panels] = panelMaker(h,option,forCompiling)

%--------------------------------------------------------------------------
% This file is part of StatSTEM
% Copyright: 2020, EMAT, University of Antwerp
% Author: K. H. W. van den Bos, J. Fatermans
% License: Open Source under GPLv3
%--------------------------------------------------------------------------

% -------------------------------------------------------------------------
% 1. Discover and order panel definition files
% -------------------------------------------------------------------------
pth = mfilename('fullpath');
pth = pth(1:end-10);
pan = dir([pth, filesep, option, filesep, '*.m']);

if forCompiling
    switch option
        case 'Preparation'
            optName = 'prep';
            pan(1).name = 'panelPFR.m';
            pan(2).name = 'panelAddRemove.m';
            pan(3).name = 'panelAssignTypes.m';
            pan(4).name = 'panelImgPar.m';
        case 'Fit Model'
            optName = 'fit';
            pan(1).name = 'panelFitMain.m';
            pan(2).name = 'panelFitModelSelection.m';
        case 'Analysis'
            optName = 'ana';
            pan(1).name = 'panelSelColumns.m';
            pan(2).name = 'panelIndexing.m';
            pan(3).name = 'panelAtomCountStat.m';
            pan(4).name = 'panelAtomCountSim.m';
            pan(5).name = 'panelAtomCountHMM.m';
            pan(6).name = 'panel3Dmodel.m';
            pan(7).name = 'panelStrainMap.m';
    end
else
    switch option
        case 'Preparation'
            optName = 'prep';
            pan = swapPanel(pan,'panelPFR.m',1);
            pan = swapPanel(pan,'panelAddRemove.m',2);
            pan = swapPanel(pan,'panelAssignTypes.m',3);
            pan = swapPanel(pan,'panelImgPar.m',4);
        case 'Fit Model'
            optName = 'fit';
        case 'Analysis'
            optName = 'ana';
            pan = swapPanel(pan,'panelSelColumns.m',1);
            pan = swapPanel(pan,'panelIndexing.m',2);
            pan = swapPanel(pan,'panelAtomCountStat.m',3);
            pan = swapPanel(pan,'panelAtomCountSim.m',4);
            pan = swapPanel(pan,'panelAtomCountHMM.m',5);
            pan = swapPanel(pan,'panel3Dmodel.m',6);
            pan = swapPanel(pan,'panelStrainMap.m',7);
    end
end

% -------------------------------------------------------------------------
% 2. Layout constants
% -------------------------------------------------------------------------
bgPanel  = [0.70 0.70 0.70];
bgDark   = [0.30 0.30 0.30];
bgLight  = [0.95 0.95 0.95];
C.rowH    = 22;
C.sepH    = 1;
C.headerH = 24;
C.advButH = 22;
C.panelW  = 170;

% -------------------------------------------------------------------------
% 3. Outer containers
% -------------------------------------------------------------------------
tabH = h.left.(optName).tab;

viewport = uipanel('Parent', tabH, ...
    'Units','normalized', 'Position',[0 0 1 1], ...
    'BorderType','none', ...
    'BackgroundColor', bgLight);

contentPanel = uipanel('Parent', viewport, ...
    'Units','pixels', ...
    'BorderType','none', ...
    'BackgroundColor', bgLight);

scrollbar = uicontrol('Parent', viewport, ...
    'Style','slider', ...
    'Units','normalized', 'Position',[0.92 0 0.08 1], ...
    'Min',0, 'Max',1, 'Value',1, ...
    'Visible','off');

% -------------------------------------------------------------------------
% 4. Build widgets for each panel
% -------------------------------------------------------------------------
opt    = h.left.(optName);
panels = cell(length(pan),1);

for n = 1:length(pan)
    funcName = pan(n).name(1:end-2);
    panInt   = feval(funcName);

    nRow   = 0;
    if isfield(panInt,'row'), nRow = length(panInt.row); end
    hasAdv = isfield(panInt,'advanced') && isfield(panInt.advanced,'panel');
    showAdv = hasAdv && isfield(panInt,'showAdv') && panInt.showAdv==1;

    % Header bar
    if ~isempty(panInt.name)
        hdrPanel = uipanel('Parent', contentPanel, ...
            'Units','pixels', ...
            'BorderType','line', 'HighlightColor', bgDark, ...
            'BackgroundColor', bgDark, ...
            'Tag', ['header_' optName '_' num2str(n)]);
        hdrBtn = uicontrol('Parent', hdrPanel, ...
            'Style','text', 'Units','pixels', ...
            'String', ['- ' panInt.name], ...
            'HorizontalAlignment','left', ...
            'ForegroundColor',[1 1 1], 'BackgroundColor', bgDark, ...
            'FontWeight','bold', 'Enable','inactive', ...
            'TooltipString','Click to collapse/expand');
        opt.(['panel',num2str(n)]).header     = hdrPanel;
        opt.(['panel',num2str(n)]).headerText = hdrBtn;
    end

    % Body panel
    bodyPanel = uipanel('Parent', contentPanel, ...
        'Units','pixels', ...
        'BorderType','line', 'HighlightColor', bgDark, ...
        'BackgroundColor', bgPanel, ...
        'Tag', ['body_' optName '_' num2str(n)]);

    for m = 1:nRow
        rowPanel = uipanel('Parent', bodyPanel, ...
            'Units','pixels', 'BorderType','none', ...
            'BackgroundColor', bgPanel);
        fNames = fieldnames(panInt.row(m));
        nOpt   = sum(strncmp(fNames,'option',6));
        for k = 1:nOpt
            optSel = panInt.row(m).(['option',num2str(k)]);
            if ~isempty(optSel)
                if isempty(optSel.bgcolor), optSel.bgcolor = bgPanel; end
                set(optSel.button, 'Parent', rowPanel, 'Units','pixels', ...
                    'BackgroundColor', optSel.bgcolor, 'Visible','on');
                if ~isempty(optSel.fgcolor)
                    set(optSel.button,'ForegroundColor',optSel.fgcolor);
                end
                if ~isempty(optSel.tooltip)
                    set(optSel.button,'TooltipString',optSel.tooltip);
                end
                opt.(['panel',num2str(n)]).(['row',num2str(m)]).(['option',num2str(k)]) = optSel;
            end
        end
        opt.(['panel',num2str(n)]).(['row',num2str(m)]).panel = rowPanel;
    end

    % "Show options" checkbox
    if hasAdv
        advRowPanel = uipanel('Parent', bodyPanel, ...
            'Units','pixels', 'BorderType','none', 'BackgroundColor', bgPanel);
        advChk = uicontrol('Parent', advRowPanel, ...
            'Style','checkbox', 'Units','pixels', ...
            'String','Show options', 'BackgroundColor', bgPanel, ...
            'Value', showAdv);
        opt.(['panel',num2str(n)]).advanced.main    = advRowPanel;
        opt.(['panel',num2str(n)]).advanced.mainBut = advChk;
    end
    opt.(['panel',num2str(n)]).panel = bodyPanel;

    % Advanced sub-panels
    if hasAdv
        nA = length(panInt.advanced);
        for p = 1:nA
            nRowAdv = length(panInt.advanced(p).panel.row);
            bgAdv   = 0.85 + 0.10*mod(p,2);
            bgAdvC  = [bgAdv bgAdv bgAdv];

            advPanel = uipanel('Parent', contentPanel, ...
                'Units','pixels', ...
                'BorderType','line', 'HighlightColor', bgDark, ...
                'BackgroundColor', bgAdvC, ...
                'Visible', onoff(showAdv), ...
                'Tag', ['adv_' optName '_' num2str(n) '_' num2str(p)]);

            if ~isempty(panInt.advanced(p).panel.name)
                advHdrBtn = uicontrol('Parent', advPanel, ...
                    'Style','text', 'Units','pixels', ...
                    'String', [' ' panInt.advanced(p).panel.name], ...
                    'HorizontalAlignment','left', ...
                    'ForegroundColor',[1 1 1], 'BackgroundColor',[0 0 0], ...
                    'Enable','inactive');
                opt.(['panel',num2str(n)]).advanced.(['panel',num2str(p)]).headerText = advHdrBtn;
            end

            for m = 1:nRowAdv
                advRowPan = uipanel('Parent', advPanel, ...
                    'Units','pixels', 'BorderType','none', ...
                    'BackgroundColor', bgAdvC);
                fNames = fieldnames(panInt.advanced(p).panel.row(m));
                nOpt   = sum(strncmp(fNames,'option',6));
                for k = 1:nOpt
                    optSel = panInt.advanced(p).panel.row(m).(['option',num2str(k)]);
                    if ~isempty(optSel)
                        if isempty(optSel.bgcolor), optSel.bgcolor = bgAdvC; end
                        set(optSel.button,'Parent',advRowPan,'Units','pixels',...
                            'BackgroundColor',optSel.bgcolor,'Visible','on');
                        if ~isempty(optSel.fgcolor)
                            set(optSel.button,'ForegroundColor',optSel.fgcolor);
                        end
                        if ~isempty(optSel.tooltip)
                            set(optSel.button,'TooltipString',optSel.tooltip);
                        end
                        opt.(['panel',num2str(n)]).advanced.(['panel',num2str(p)]).(['row',num2str(m)]).(['option',num2str(k)]) = optSel;
                    end
                end
                opt.(['panel',num2str(n)]).advanced.(['panel',num2str(p)]).(['row',num2str(m)]).panel = advRowPan;
            end
            opt.(['panel',num2str(n)]).advanced.(['panel',num2str(p)]).panel = advPanel;
        end
    end

    opt.(['inputPan',num2str(n)]) = panInt;
    h.left.(optName) = opt;
    panels{n,1} = panInt;
end

% -------------------------------------------------------------------------
% 5. Store layout state in contentPanel UserData so callbacks always have
%    fresh access to all handles and panel definitions.
% -------------------------------------------------------------------------
ud.opt      = opt;
ud.pan      = pan;
ud.panels   = panels;
ud.C        = C;
ud.scrollbar = scrollbar;
ud.viewport  = viewport;
set(contentPanel, 'UserData', ud);

% Wire callbacks — they all just call doLayout via the UserData
for n = 1:length(pan)
    panInt = panels{n};
    if isempty(panInt), continue; end

    if ~isempty(panInt.name)
        hdrBtn   = opt.(['panel',num2str(n)]).headerText;
        hdrPanel = opt.(['panel',num2str(n)]).header;
        set(hdrBtn,   'ButtonDownFcn', {@cbToggleBody, n, contentPanel});
        set(hdrPanel, 'ButtonDownFcn', {@cbToggleBody, n, contentPanel});
    end

    hasAdv = isfield(panInt,'advanced') && isfield(panInt.advanced,'panel');
    if hasAdv
        advChk = opt.(['panel',num2str(n)]).advanced.mainBut;
        set(advChk, 'Callback', {@cbToggleAdv, n, contentPanel});
    end
end

% -------------------------------------------------------------------------
% 6. Initial layout
% -------------------------------------------------------------------------
% drawnow ensures the figure is fully rendered at its actual size before
% we compute pixel positions from the normalized viewport.
drawnow;
doLayout(contentPanel);

% Re-run layout whenever the viewport is resized (window resize / maximize)
set(viewport, 'SizeChangedFcn', {@cbResize, contentPanel});

h.left.(optName).main  = viewport;
h.left.(optName).jmain = viewport;


% =========================================================================
% CALLBACKS  (thin wrappers — all work via contentPanel UserData)
% =========================================================================

function cbToggleBody(~, ~, n, contentPanel)
ud  = get(contentPanel, 'UserData');
opt = ud.opt;

bodyPanel = opt.(['panel',num2str(n)]).panel;
isVis = strcmp(get(bodyPanel,'Visible'),'on');

% Flip body
set(bodyPanel, 'Visible', onoff(~isVis));

% When collapsing: also hide advanced sub-panels and uncheck checkbox
if isVis && isfield(opt.(['panel',num2str(n)]),'advanced')
    adv = opt.(['panel',num2str(n)]).advanced;
    fN  = fieldnames(adv);
    for k = 1:length(fN)
        if strncmp(fN{k},'panel',5)
            set(adv.(fN{k}).panel, 'Visible','off');
        end
    end
    if isfield(adv,'mainBut')
        set(adv.mainBut, 'Value', 0);
    end
end

% Update header +/-
hdrBtn = opt.(['panel',num2str(n)]).headerText;
txt = get(hdrBtn,'String');
if isVis, txt(1) = '+'; else, txt(1) = '-'; end
set(hdrBtn,'String',txt);

doLayout(contentPanel);


function cbToggleAdv(hObject, ~, n, contentPanel)
ud  = get(contentPanel, 'UserData');
opt = ud.opt;

val = get(hObject,'Value');

if isfield(opt.(['panel',num2str(n)]),'advanced')
    adv = opt.(['panel',num2str(n)]).advanced;
    fN  = fieldnames(adv);
    for k = 1:length(fN)
        if strncmp(fN{k},'panel',5)
            set(adv.(fN{k}).panel, 'Visible', onoff(val));
        end
    end
end

doLayout(contentPanel);


% =========================================================================
% LAYOUT ENGINE
% =========================================================================

function doLayout(contentPanel)
% Read all state from UserData, compute heights, place everything.

ud       = get(contentPanel, 'UserData');
opt      = ud.opt;
panels   = ud.panels;
C        = ud.C;
scrollbar = ud.scrollbar;
viewport  = ud.viewport;

nPan = length(panels);

% ------------------------------------------------------------------
% Pass 1: total required height
% ------------------------------------------------------------------
totalH = C.sepH;   % top margin
for n = 1:nPan
    panInt = panels{n};
    if isempty(panInt), continue; end

    nRow   = 0;
    if isfield(panInt,'row'), nRow = length(panInt.row); end
    hasAdv = isfield(panInt,'advanced') && isfield(panInt.advanced,'panel');

    % Header always visible
    if ~isempty(panInt.name)
        totalH = totalH + C.headerH + C.sepH;
    end

    bodyPanel = opt.(['panel',num2str(n)]).panel;
    bodyVis   = strcmp(get(bodyPanel,'Visible'),'on');

    if bodyVis
        bodyH = C.sepH + nRow*(C.rowH+C.sepH);
        if hasAdv, bodyH = bodyH + C.advButH + C.sepH; end
        totalH = totalH + bodyH + C.sepH;

        if hasAdv
            adv = opt.(['panel',num2str(n)]).advanced;
            fN  = fieldnames(adv);
            for k = 1:length(fN)
                if strncmp(fN{k},'panel',5)
                    advP = adv.(fN{k}).panel;
                    if strcmp(get(advP,'Visible'),'on')
                        idx       = str2double(fN{k}(6:end));
                        panIntAdv = panInt.advanced(idx).panel;
                        nRowAdv   = length(panIntAdv.row);
                        hasHdr    = ~isempty(panIntAdv.name);
                        totalH    = totalH + C.sepH + nRowAdv*(C.rowH+C.sepH) + hasHdr*(C.rowH+C.sepH);
                    end
                end
            end
        end
    end
    % small gap between panels
    totalH = totalH + C.sepH;
end

% ------------------------------------------------------------------
% Size contentPanel: at least as tall as viewport, top-aligned
% ------------------------------------------------------------------
vpPos = getpixelposition(viewport);
vpW   = vpPos(3);
vpH   = vpPos(4);
contentH = max(totalH, vpH);
% Place content panel so its top is flush with the viewport top
set(contentPanel, 'Position', [0, vpH - contentH, vpW, contentH]);

% ------------------------------------------------------------------
% Pass 2: place every widget — work top-to-bottom
% yPos is measured from the BOTTOM of contentPanel (MATLAB convention)
% Start just below the top of contentPanel.
% ------------------------------------------------------------------
yPos = contentH - C.sepH;

for n = 1:nPan
    panInt = panels{n};
    if isempty(panInt), continue; end

    nRow   = 0;
    if isfield(panInt,'row'), nRow = length(panInt.row); end
    hasAdv = isfield(panInt,'advanced') && isfield(panInt.advanced,'panel');

    % ---- Header ----
    if ~isempty(panInt.name)
        hdrPanel = opt.(['panel',num2str(n)]).header;
        hdrBtn   = opt.(['panel',num2str(n)]).headerText;
        set(hdrPanel, 'Position', [0, yPos-C.headerH, C.panelW+2, C.headerH]);
        set(hdrBtn,   'Position', [2, 2, C.panelW-2, C.headerH-4]);
        yPos = yPos - C.headerH - C.sepH;
    end

    bodyPanel = opt.(['panel',num2str(n)]).panel;
    bodyVis   = strcmp(get(bodyPanel,'Visible'),'on');

    if bodyVis
        % ---- Body ----
        bodyH = C.sepH + nRow*(C.rowH+C.sepH);
        if hasAdv, bodyH = bodyH + C.advButH + C.sepH; end
        set(bodyPanel, 'Position', [0, yPos-bodyH, C.panelW+2, bodyH]);

        % rows inside body (local y, bottom-up)
        yRow = bodyH - C.sepH;
        for m = 1:nRow
            rowPanel = opt.(['panel',num2str(n)]).(['row',num2str(m)]).panel;
            set(rowPanel, 'Position', [1, yRow-C.rowH, C.panelW, C.rowH]);
            placeOptions(opt.(['panel',num2str(n)]).(['row',num2str(m)]), C);
            yRow = yRow - C.rowH - C.sepH;
        end
        if hasAdv
            advRowPanel = opt.(['panel',num2str(n)]).advanced.main;
            advChk      = opt.(['panel',num2str(n)]).advanced.mainBut;
            set(advRowPanel,'Position',[1, yRow-C.advButH, C.panelW, C.advButH]);
            set(advChk,     'Position',[4, 2, C.panelW-8, C.advButH-4]);
        end

        yPos = yPos - bodyH - C.sepH;

        % ---- Advanced sub-panels ----
        if hasAdv
            adv = opt.(['panel',num2str(n)]).advanced;
            fN  = fieldnames(adv);
            advNames = fN(strncmp(fN,'panel',5));
            % Sort so panel1 < panel2 < ...
            advNames = sort(advNames);
            for ki = 1:length(advNames)
                fname     = advNames{ki};
                advP      = adv.(fname).panel;
                idx       = str2double(fname(6:end));
                panIntAdv = panInt.advanced(idx).panel;
                nRowAdv   = length(panIntAdv.row);
                hasHdr    = ~isempty(panIntAdv.name);
                advH      = C.sepH + nRowAdv*(C.rowH+C.sepH) + hasHdr*(C.rowH+C.sepH);

                % Position always (whether visible or not)
                set(advP, 'Position', [0, yPos-advH, C.panelW+2, advH]);

                % Internal layout
                yAdvRow = advH - C.sepH;
                if hasHdr
                    advHdrBtn = adv.(fname).headerText;
                    set(advHdrBtn,'Position',[2, yAdvRow-C.rowH, C.panelW-2, C.rowH]);
                    yAdvRow = yAdvRow - C.rowH - C.sepH;
                end
                for m = 1:nRowAdv
                    advRowPan = adv.(fname).(['row',num2str(m)]).panel;
                    set(advRowPan,'Position',[1, yAdvRow-C.rowH, C.panelW, C.rowH]);
                    placeOptions(adv.(fname).(['row',num2str(m)]), C);
                    yAdvRow = yAdvRow - C.rowH - C.sepH;
                end

                % Only consume vertical space when visible
                if strcmp(get(advP,'Visible'),'on')
                    yPos = yPos - advH;
                end
            end
        end

    end  % bodyVis

    yPos = yPos - C.sepH;  % gap between panel groups
end

% ------------------------------------------------------------------
% Scrollbar and final contentPanel position
% ------------------------------------------------------------------
if contentH <= vpH
    % Everything fits: anchor content to top of viewport, hide scrollbar
    set(scrollbar, 'Visible','off');
    set(contentPanel, 'Position', [0, vpH - contentH, vpW, contentH]);
else
    overflow = contentH - vpH;
    % Restore previous scroll position (0 = scrolled to bottom, overflow = top)
    % On first call scrollbar Value may equal its old Max; clamp it.
    try
        curVal = get(scrollbar,'Value');
        curVal = max(0, min(curVal, overflow));
    catch
        curVal = overflow;   % default: show top
    end
    set(scrollbar, ...
        'Visible','on', ...
        'Min',0, 'Max',overflow, ...
        'Value', curVal, ...
        'SliderStep',[min(1,C.rowH/overflow), min(1,vpH/overflow)], ...
        'Callback', {@cbScroll, contentPanel});
    % Apply scroll offset: curVal=overflow means top, curVal=0 means bottom
    set(contentPanel, 'Position', ...
        [0, vpH - contentH + (overflow - curVal), vpW, contentH]);
end


function cbResize(~, ~, contentPanel)
% Re-run the full layout when the viewport is resized.
doLayout(contentPanel);


function cbScroll(src, ~, contentPanel)
ud       = get(contentPanel, 'UserData');
viewport = ud.viewport;
vpPos    = getpixelposition(viewport);
vpH      = vpPos(4);
vpW      = vpPos(3);
cPos     = get(contentPanel,'Position');
contentH = cPos(4);
overflow = contentH - vpH;
val      = get(src,'Value');
set(contentPanel,'Position',[0, vpH - contentH + (overflow - val), vpW, contentH]);


% =========================================================================
% HELPERS
% =========================================================================

function placeOptions(rowStruct, C)
fNames = fieldnames(rowStruct);
nOpt   = sum(strncmp(fNames,'option',6));
if nOpt == 0, return; end
wArr = zeros(1,nOpt);
for k = 1:nOpt
    optSel = rowStruct.(['option',num2str(k)]);
    if ~isempty(optSel), wArr(k) = optSel.width; end
end
totalW = sum(wArr(wArr>0));
availW = C.panelW - 4;
if totalW > 0 && abs(totalW - availW) > 2
    scale = availW / totalW;
    wArr(wArr>0) = round(wArr(wArr>0) * scale);
end
xOff = 2;
for k = 1:nOpt
    optSel = rowStruct.(['option',num2str(k)]);
    if ~isempty(optSel) && wArr(k) > 0
        btnH = min(optSel.height, C.rowH-2);
        yBtn = max(1, round((C.rowH - btnH)/2));
        set(optSel.button,'Position',[xOff, yBtn, wArr(k), btnH]);
        xOff = xOff + wArr(k);
    end
end


function str = onoff(val)
if val, str = 'on'; else, str = 'off'; end


function pan = swapPanel(pan, name, N)
ind = find(strcmp({pan.name}, name), 1);
if ~isempty(ind) && ind ~= N
    tmp    = pan(N);
    pan(N) = pan(ind);
    pan(ind) = tmp;
end
