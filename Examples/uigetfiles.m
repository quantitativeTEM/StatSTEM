function [pathname] = uigetfiles(FilterSpec,DialogTitle,varargin)
% Pick multiple directories and/or files

import javax.swing.JFileChooser;
% First check inputs
start_path = '';
multi = 1;
dialog_title = [];

if isempty(start_path) % Allow a null argument.
    start_path = pwd;
end

jchooser = javaObjectEDT('javax.swing.JFileChooser', start_path);

jchooser.setFileSelectionMode(JFileChooser.FILES_AND_DIRECTORIES);
if ~isempty(dialog_title)
    jchooser.setDialogTitle(dialog_title);
end

if multi==0
    jchooser.setMultiSelectionEnabled(false);
elseif multi==1
    jchooser.setMultiSelectionEnabled(true);
end

status = jchooser.showOpenDialog([]);

if status == JFileChooser.APPROVE_OPTION
    jFile = jchooser.getSelectedFiles();
	pathname{size(jFile, 1)}=[];
    for i=1:size(jFile, 1)
		pathname{i} = char(jFile(i).getAbsolutePath);
	end
	
elseif status == JFileChooser.CANCEL_OPTION
    pathname = [];
else
    error('Error occured while picking file.');
end
