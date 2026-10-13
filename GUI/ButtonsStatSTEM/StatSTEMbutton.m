classdef StatSTEMbutton
% StatSTEMbutton - Abstract base class for native MATLAB buttons in StatSTEM GUI
%
%   Replaces the previous Java/Swing-based implementation.
%   obj.button now holds a native MATLAB uicontrol handle (R2019b+).
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2020, EMAT, University of Antwerp
% Author: K. H. W. van den Bos, J. Fatermans
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

    properties
        width    = 50;   % Width of button in pixels
        tooltip  = '';   % Tooltip string
        input    = {''};  % Required input fields in StatSTEM file
        optInput = {''};  % Optional input fields
        output   = {''};  % Output fields produced by this button
        actWhen  = {};   % {value, 'field'} to conditionally enable button
        fgcolor  = '';   % Foreground colour [R G B]
        bgcolor  = '';   % Background colour [R G B]
        margin   = [2,2,2,2]; % Unused (kept for API compatibility)
        fitting  = 0;    % Whether this button runs a fit (can be aborted)
        figStart    = '';     % Figure to show before callback runs
        figOptStart = {''};   % Figure options for figStart
        figEnd      = '';     % Figure to show after callback runs
        figOptEnd   = {''};   % Figure options for figEnd
        reshowFigEnd = false; % Remake figure after callback
    end

    properties (Hidden)
        button  = [];    % Native MATLAB uicontrol handle
        height  = 20;    % Height of button in pixels
        Focusable = true; % Kept for API compatibility (no-op for uicontrol)
        font    = '';    % Unused (kept for API compatibility)
    end

    properties (Access = 'private', Hidden)
        cleanup
    end

    methods
        function obj = StatSTEMbutton
            obj.cleanup = onCleanup(@()delete(obj));
        end

        function obj = set.width(obj, value)
            if isa(value,'double') && value > 0
                obj.width = value;
            else
                error('StatSTEMbutton: Width should be a positive number')
            end
            if ~isempty(obj.button) && ishandle(obj.button)
                % Position is managed by panelMaker; width stored for reference
            end
        end

        function obj = set.height(obj, value)
            if isa(value,'double') && value > 0
                obj.height = value;
            else
                error('StatSTEMbutton: Height should be a positive number')
            end
        end

        function obj = set.tooltip(obj, value)
            if isa(value,'char')
                obj.tooltip = value;
            else
                error('StatSTEMbutton: Tooltip should be a string')
            end
            if ~isempty(obj.button) && ishandle(obj.button)
                set(obj.button, 'TooltipString', value);
            end
        end

        function obj = set.fgcolor(obj, value)
            if isempty(value)
                obj.fgcolor = value;
            elseif isa(value,'double') && max(value)<=1 && min(value)>=0 && ...
                    (all(size(value)==[1 3]) || all(size(value)==[3 1]))
                obj.fgcolor = value;
            else
                error('StatSTEMbutton: fgcolor should be a 1x3 vector with values between 0 and 1')
            end
            if ~isempty(obj.button) && ishandle(obj.button)
                if ~isempty(obj.fgcolor)
                    set(obj.button, 'ForegroundColor', obj.fgcolor);
                end
            end
        end

        function obj = set.bgcolor(obj, value)
            if isempty(value)
                obj.bgcolor = value;
            elseif isa(value,'double') && max(value)<=1 && min(value)>=0 && ...
                    (all(size(value)==[1 3]) || all(size(value)==[3 1]))
                obj.bgcolor = value;
            else
                error('StatSTEMbutton: bgcolor should be a 1x3 vector with values between 0 and 1')
            end
            if ~isempty(obj.button) && ishandle(obj.button)
                if ~isempty(obj.bgcolor)
                    try
                        set(obj.button, 'BackgroundColor', obj.bgcolor);
                    catch
                        % Some styles ignore BackgroundColor; ignore silently
                    end
                end
            end
        end

        function obj = set.figStart(obj, value)
            if isa(value,'char')
                obj.figStart = value;
            else
                error('StatSTEMbutton: figStart should be a string')
            end
        end

        function obj = set.figOptStart(obj, value)
            if isa(value,'char')
                obj.figOptStart = {value};
            elseif isa(value,'cell')
                obj.figOptStart = value;
            else
                error('StatSTEMbutton: figOptStart should be a cell containing strings')
            end
        end

        function obj = set.figEnd(obj, value)
            if isa(value,'char')
                obj.figEnd = value;
            else
                error('StatSTEMbutton: figEnd should be a string')
            end
        end

        function obj = set.figOptEnd(obj, value)
            if isa(value,'char')
                obj.figOptEnd = {value};
            elseif isa(value,'cell')
                obj.figOptEnd = value;
            else
                error('StatSTEMbutton: figOptEnd should be a cell containing strings')
            end
        end

        function obj = set.reshowFigEnd(obj, value)
            if isa(value,'logical')
                obj.reshowFigEnd = value;
            elseif isa(value,'double') && (value==0 || value==1)
                obj.reshowFigEnd = value==1;
            else
                error('StatSTEMbutton: reshowFigEnd should be a logical')
            end
        end

        function obj = set.margin(obj, value)
            % Kept for API compatibility; has no effect on native controls
            if isa(value,'double') && (all(size(value)==[1 4]) || all(size(value)==[4 1]))
                obj.margin = value;
            else
                error('StatSTEMbutton: margin should be a 1x4 vector')
            end
        end

        function font = get.font(~)
            % Kept for API compatibility; returns empty
            font = '';
        end
    end

    methods (Hidden)
        function delete(obj)
            % Remove callback on the native control to avoid dangling refs
            if ~isempty(obj.button) && ishandle(obj.button)
                try
                    set(obj.button, 'Callback', []);
                catch
                end
            end
        end
    end
end

