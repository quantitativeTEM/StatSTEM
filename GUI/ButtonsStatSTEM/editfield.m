classdef editfield < StatSTEMbutton
    
    properties
        name = '';
        func = '';
        enable = 1; 
        equalTo = {''};
        alignment = 'leading'; %options: leading = leading, l = left, c = center, r = right
    end
    
    methods
        function obj = editfield(name,value,varargin)
            if nargin>0
                varargin = [{name},{value},varargin];
            end
            obj.button = javax.swing.JTextField;
            obj.height = 18;
            obj.bgcolor = [1,1,1];
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
            obj.button.setEnabled(value);
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
        
        function obj = set.alignment(obj,value)
            % Make sure the name is a string
            if isa(value,'char')
                options = {'leading','l','c','r'};
                if any(strcmp(options,value))
                    obj.alignment = value;
                else
                    error('StatSTEMbutton: alignment should be a leading, l (left), c (center) or r (right')
                end
            else
                error('StatSTEMbutton: alignment should be a string')
            end
            switch value
                case 'leading'
                    obj.button.setHorizontalAlignment(javax.swing.JTextField.LEADING);
                case 'l'
                    obj.button.setHorizontalAlignment(javax.swing.JTextField.LEFT);
                case 'c'
                    obj.button.setHorizontalAlignment(javax.swing.JTextField.CENTER);
                case 'r'
                    obj.button.setHorizontalAlignment(javax.swing.JTextField.RIGHT);
            end
        end
    end
    
    methods (Hidden)
        function delete(obj)
            delete@StatSTEMbutton(obj)
            set(obj.button,'KeyReleasedCallback',[])
            set(obj.button,'FocusLostCallback',[])
        end
    end
end
    