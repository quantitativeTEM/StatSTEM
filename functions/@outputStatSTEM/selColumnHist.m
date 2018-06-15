function obj = selColumnHist(obj,state)
% selColumnHist - Select specific columns for analysis
%
% This function enables the user to select specific column in the StatSTEM
% interface which will only be used for the atomcounting routine. Columns
% are selected from the histogram of scattering cross-sections
%
%   syntax: obj = selColumnHist(obj,state)
%       obj   - outputStatSTEM file
%       state - logical indicating to add or remove a selected region (optional)
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if nargin<2
    state = 1;
end

if state
    if obj.GUI==0
        figure;
        showHistogramSCS(obj);  
    end
    
    %% Select axis
    ax = gca;
    axis(ax);
    hold on;
    
    %% Select interval
    % Let user select a minimum
    title(ax,'Select lower boundary, press ESC to exit')

    % Get minimum
    [minVol,y] = ginput_AxInFig();
    if ~isempty(minVol)
        % Continue
        hold(ax,'on')
        h_min = plot(ax,minVol,y,'b+');
        
        title(ax,'Select upper boundary, press ESC to exit')
        
        % Get maximum
        [maxVol,~] = ginput_AxInFig();
        delete(h_min)
    else
        maxVol = [];
    end
    
    title(ax,'')
    
    % If user cancelled proces, delete minimum
    if ~isempty(maxVol)
        obj.rangeVol = [minVol,maxVol];
    end
    
else
    obj.rangeVol = [];
end