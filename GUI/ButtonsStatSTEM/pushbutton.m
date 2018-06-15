classdef pushbutton < StatSTEMbutton
    
    properties
        name = '';
        func = '';
        enable = 1;
    end
    
    methods
        function obj = pushbutton(name,value,varargin)
            if nargin>0
                varargin = [{name},{value},varargin];
            end
            obj@StatSTEMbutton;
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
    end
end
    