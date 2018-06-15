function panel = insertOption(panel,row,optN,option)
% insertOption - insert panel options
%
%   syntax: panel = insertOption(panel,row,optN,option)
%       panel  - structure containing the necessary information to create a panel with buttons in StatSTEM
%       row    - row number
%       optN   - option number
%       option - structure containing the settings of an option/button
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K. H. W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
names = fieldnames(option);
for k=1:length(names);
    panel.row(row).option(optN).(names{k}) = option.(names{k});
end
