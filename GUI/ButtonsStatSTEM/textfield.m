classdef textfield < StatSTEMbutton
% textfield - Static label widget. Despite being read-only it accepts the
%   same property set as other button types so panel definition files can
%   pass any key without error.

    properties
        name        = ''; % Text shown in label
        alignment   = 'leading'; % 'leading'|'l'|'c'|'r'
        func        = ''; % Not used for textfields; kept for API parity
        enable      = 1;  % Not used; kept for API parity
        equalTo     = {''}; % Variable to keep in sync (read-only display)
        selected    = 1;
        selWhen     = {};
        keepName    = 0;
        selOptInput = '';
        optN        = 1;
    end

    methods
        function obj = textfield(name, value, varargin)
            if nargin > 0
                varargin = [{name},{value}, varargin];
            end
            obj@StatSTEMbutton;
            obj.button = uicontrol('Style','text', ...
                'Visible','off', ...
                'Enable','inactive', ...
                'BackgroundColor', [0.94 0.94 0.94]);
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
            % textfields are always inactive; absorb silently
            if value==1 || value==0, obj.enable = value==true; end
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
end

