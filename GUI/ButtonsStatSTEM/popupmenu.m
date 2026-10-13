classdef popupmenu < StatSTEMbutton

    properties
        selWhen     = {};
        optN        = 1;
        name         = ''; % Initial option list (string or cell)
        func         = ''; % Function linked to menu
        enable       = 1;  % Active or inactive
        options      = {}; % Cell array of option strings (alias for name)
        keepName     = 0;  % Whether to keep existing options alongside new ones
        selOptInput  = ''; % Variable name for selected option
        equalTo      = ''; % Variable whose value populates the option list
        selected     = 1;  % Index of selected option (1-based)
    end

    methods
        function obj = popupmenu(name, value, varargin)
            if nargin > 0
                varargin = [{name},{value}, varargin];
            end
            obj@StatSTEMbutton;
            obj.button = uicontrol('Style','popupmenu', ...
                'Visible','off', ...
                'Enable','on', ...
                'String',{' '}, ...
                'BackgroundColor',[1 1 1]);
            obj.height  = 18;
            obj.bgcolor = [1,1,1];
            obj.Focusable = false;
            N = length(varargin);
            for n = 1:N/2
                obj.(varargin{2*n-1}) = varargin{2*n};
            end
        end

        function obj = set.name(obj, value)
            if ischar(value)
                obj.name    = value;
                obj.options = {value};
            elseif iscell(value)
                obj.name    = value;
                obj.options = value;
            else
                error('StatSTEMbutton: name should be a string or cell array of strings')
            end
            if ~isempty(obj.button) && ishandle(obj.button) && ~isempty(obj.options)
                set(obj.button, 'String', obj.options, 'Value', 1);
            end
        end

        function obj = set.func(obj, value)
            if ischar(value), obj.func = value; end
        end

        function obj = set.enable(obj, value)
            if value==1 || value==0
                obj.enable = value==true;
            else
                error('StatSTEMbutton: Enable should be a logical value')
            end
            if ~isempty(obj.button) && ishandle(obj.button)
                set(obj.button, 'Enable', popupmenu.onoff(value));
            end
        end

        function obj = set.options(obj, value)
            if ischar(value)
                obj.options = {value};
            elseif iscell(value)
                obj.options = value;
            else
                error('StatSTEMbutton: options should be a cell array of strings')
            end
            if ~isempty(obj.button) && ishandle(obj.button) && ~isempty(obj.options)
                set(obj.button, 'String', obj.options, 'Value', 1);
            end
        end

        function obj = set.equalTo(obj, value)
            if ischar(value)
                obj.equalTo = value;
            elseif iscell(value)
                obj.equalTo = value;
            else
                error('StatSTEMbutton: equalTo should be a string or cell of strings')
            end
        end




        function obj = set.selected(obj, value)
            if isnumeric(value) && value >= 1
                obj.selected = round(value);
            else
                error('StatSTEMbutton: selected should be a positive integer index')
            end
            if ~isempty(obj.button) && ishandle(obj.button)
                nOpts = numel(get(obj.button,'String'));
                if obj.selected <= nOpts
                    set(obj.button, 'Value', obj.selected);
                end
            end
        end

    end

    methods (Static, Access = private)
        function str = onoff(val)
            if val, str = 'on'; else, str = 'off'; end
        end
    end
end
