classdef textfield < StatSTEMbutton
    
    properties
        name = '';
        alignment = 'leading'; %options: leading = leading, l = left, c = center, r = right
        border = 'none'; % options; none, or color triplet [R,G,B] (relative)
    end
    
    properties (Constant)
        func = '';
    end
    
    methods
        function obj = textfield(name,value,varargin)
            if nargin>0
                varargin = [{name},{value},varargin];
            end
            obj.button = javax.swing.JTextField;
            obj.button.setEnabled(true);
            obj.Focusable = false;
            obj.height = 20;
            obj.margin = [0,0,0,0];
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
        
        function obj = set.border(obj,value)
            % Make sure the name is a string or double
            if isa(value,'char') && strcmp(value,'none')
                obj.border = value;
            elseif isa(value,'double') && max(value)<=1 && min(value)>=0 && (all(size(value)==[1 3]) || all(size(value)==[3 1]))
                obj.border = value;
            else
                error('StatSTEMbutton: border should be a 3x1 vector with relative colors (between 0 and 1)')
            end
            updateBorder(obj)
        end
        
        function updateBorder(obj)
            % Make sure the name is a string
            if isa(obj.border,'char') && strcmp(obj.border,'none')
                bgc = obj.button.getBackground;
            else
                bgc = java.awt.Color(value(1),value(2),value(3));
            end
            set(obj.button,'Border',javax.swing.border.LineBorder(bgc,1,false))
        end
        
        function updateBGColor(obj)
            updateBGColor@StatSTEMbutton(obj)
            updateBorder(obj)
        end
    end
end
    