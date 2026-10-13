classdef pushbutton < StatSTEMbutton

    properties
        name     = ''; % Text shown on button
        func     = ''; % Function coupled to button
        enable   = 1;  % Make button active or inactive
        keepName = 0;  % Whether to preserve existing label alongside new value
        optN     = 1;  % Value token (used by some panel configurations)
        selOptInput = ''; % Variable name for selected option
        selWhen  = {}; % {value, 'field'} to auto-select
        selected = 1;  % Selection state
        equalTo  = {''}; % Variable to keep in sync
    end

    methods
        function obj = pushbutton(name, value, varargin)
            if nargin > 0
                varargin = [{name},{value}, varargin];
            end
            obj@StatSTEMbutton;
            obj.button = uicontrol('Style','pushbutton', ...
                'Visible','off', ...
                'Enable','on');
            obj.margin    = [0,0,0,0];
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
                set(obj.button, 'Enable', pushbutton.onoff(value));
            end
        end
        function obj = set.equalTo(obj, value)
            if ischar(value), obj.equalTo = {value};
            elseif iscell(value), obj.equalTo = value;
            else, error('StatSTEMbutton: equalTo should be a string or cell'); end
        end
    end

    methods (Static, Access = private)
        function str = onoff(val)
            if val, str = 'on'; else, str = 'off'; end
        end
    end
end
