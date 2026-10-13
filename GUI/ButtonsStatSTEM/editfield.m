classdef editfield < StatSTEMbutton

    properties
        name        = ''; % Text shown in field
        func        = ''; % Function coupled to field
        enable      = 1;  % Active or inactive
        equalTo     = {''}; % Variable to keep in sync
        alignment   = 'leading'; % 'leading'|'l'|'c'|'r'
        selected    = 1;
        selWhen     = {};
        keepName    = 0;
        selOptInput = '';
        optN        = 1;
    end

    methods
        function obj = editfield(name, value, varargin)
            if nargin > 0
                varargin = [{name},{value}, varargin];
            end
            obj@StatSTEMbutton;
            obj.button = uicontrol('Style','edit', ...
                'Visible','off', ...
                'Enable','on', ...
                'BackgroundColor',[1 1 1]);
            obj.height  = 18;
            obj.bgcolor = [1,1,1];
            N = length(varargin);
            for n = 1:N/2
                obj.(varargin{2*n-1}) = varargin{2*n};
            end
        end

        function obj = set.name(obj, value)
            if ischar(value), obj.name = value;
            else, error('StatSTEMbutton: Name should be a string'); end
            if ~isempty(obj.button) && ishandle(obj.button)
                set(obj.button, 'String', value);
            end
        end
        function obj = set.func(obj, value)
            if ischar(value), obj.func = value; end
        end
        function obj = set.enable(obj, value)
            if value==1 || value==0, obj.enable = value==true;
            else, error('StatSTEMbutton: Enable should be a logical value'); end
            if ~isempty(obj.button) && ishandle(obj.button)
                set(obj.button, 'Enable', editfield.onoff(value));
            end
        end
        function obj = set.equalTo(obj, value)
            if ischar(value), obj.equalTo = {value};
            elseif iscell(value), obj.equalTo = value;
            else, error('StatSTEMbutton: equalTo should be a string or cell'); end
        end
        function obj = set.alignment(obj, value)
            options = {'leading','l','c','r'};
            if ischar(value) && any(strcmp(options,value)), obj.alignment = value;
            else, error('StatSTEMbutton: alignment should be leading, l, c, or r'); end
            if ~isempty(obj.button) && ishandle(obj.button)
                switch value
                    case {'leading','l'}, set(obj.button,'HorizontalAlignment','left');
                    case 'c',            set(obj.button,'HorizontalAlignment','center');
                    case 'r',            set(obj.button,'HorizontalAlignment','right');
                end
            end
        end
    end

    methods (Hidden)
        function delete(obj)
            delete@StatSTEMbutton(obj);
            if ~isempty(obj.button) && ishandle(obj.button)
                try
                    set(obj.button, 'Callback', [], 'KeyReleaseFcn', []);
                catch
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
