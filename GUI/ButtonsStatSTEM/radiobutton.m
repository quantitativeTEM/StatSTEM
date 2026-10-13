classdef radiobutton < StatSTEMbutton

    properties
        name        = ''; % Text shown next to button
        func        = ''; % Function linked to button
        enable      = 1;  % Active or inactive
        equalTo     = {''}; % Variable to keep in sync
        optN        = 1;  % Value when this radio is selected
        selected    = 1;  % Is button selected
        selWhen     = {};
        keepName    = 0;
        selOptInput = '';
    end

    methods
        function obj = radiobutton(name, value, varargin)
            if nargin > 0
                varargin = [{name},{value}, varargin];
            end
            obj@StatSTEMbutton;
            obj.button = uicontrol('Style','radiobutton', ...
                'Visible','off', ...
                'Enable','on');
            obj.height    = 18;
            obj.Focusable = false;
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
                set(obj.button, 'Enable', radiobutton.onoff(value));
            end
        end
        function obj = set.equalTo(obj, value)
            if ischar(value), obj.equalTo = {value};
            elseif iscell(value), obj.equalTo = value;
            else, error('StatSTEMbutton: equalTo should be a string or cell'); end
        end
        function obj = set.selected(obj, value)
            if value==1 || value==0, obj.selected = value==true;
            else, error('StatSTEMbutton: selected should be a logical value'); end
            if ~isempty(obj.button) && ishandle(obj.button)
                set(obj.button, 'Value', double(value==1));
            end
        end
    end

    methods (Static, Access = private)
        function str = onoff(val)
            if val, str = 'on'; else, str = 'off'; end
        end
    end
end
