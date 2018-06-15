classdef togglebutton < StatSTEMbutton
    
    properties
        name = '';
        func = '';
        enable = 1;
        state = 1;
        equalTo = {''};
    end
    
    methods
        function obj = togglebutton(name,value,varargin)
            if nargin>0
                varargin = [{name},{value},varargin];
            end
            obj.button = javax.swing.JButton;
            obj.margin = [0,0,0,0];
            obj.Focusable = false;
            obj.button.setFont(obj.font);
            N = length(varargin);
            for n=1:N/2
                obj.(varargin{2*n-1}) = varargin{2*n};
            end
        end
        
        function obj = set.name(obj,value)
            % Make sure the name is a string
            if isa(value,'char')
                obj.name = value;
            else
                error('StatSTEMbutton: Name should be a string')
            end
            set(obj.button,'Text',value)
        end
        
        function obj = set.func(obj,value)
            % Make sure the name is a string
            if isa(value,'char')
                obj.func = value;
            end
        end
        
        function obj = set.enable(obj,value)
            % Make sure the value is a logical
            if value==1 || value==0
                obj.enable = value==true;
            else
                error('StatSTEMbutton: Enable should be a logical value')
            end
            obj.setEnabled(value);
        end
        
        function obj = set.state(obj,value)
            % Make sure the value is a logical
            if value==1 || value==0
                obj.state = value==true;
            else
                error('StatSTEMbutton: Enable should be a logical value')
            end
            if value==1
                obj.button.setForeground(javax.swing.plaf.ColorUIResource(0,0,0))
            else
                obj.button.setForeground(java.awt.Color(1,0,0))
            end
        end
        
        function val = get.state(obj)
            fg = get(obj.button,'Foreground');
            v = version('-release');
            v = str2double(v(1:4));
            if v<2015
                r = fg(1);
                g = fg(2);
                b = fg(3);
            else
                r = fg.getRed;
                g = fg.getGreen;
                b = fg.getBlue;
            end
            if r==0 && g==0 && b==0
                val = 1;
            else
                val = 0;
            end
        end
        
        function obj = set.equalTo(obj,value)
            % Make sure the name is a string
            if isa(value,'char')
                obj.equalTo = {value};
            elseif isa(value,'cell')
                obj.equalTo = value;
            else
                error('StatSTEMbutton: equalTo should be a string or a cell structure with strings')
            end
        end
    end
end
    