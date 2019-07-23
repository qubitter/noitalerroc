Info = {'Number','Initials','Handedness [L = Left, R = Right]';'Age';'Ethnicity'};

dlg_title = 'Subject Information';

num_lines = 1;

subject_info = inputdlg(Info,dlg_title,num_lines);

%shoutout to ojus 