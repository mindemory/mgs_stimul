clear; clc;
cd '/d/DATD/datd/MD_TMS_EEG/EEGfiles/';
dir_list = dir("sub*");
day_list = [1, 2, 3];
for ii=1:length(dir_list)
    ss = dir_list(ii).name;
    for dd=day_list
        fname = [ss '/day' num2str(dd,'%02d'), '/' ss '_day' num2str(dd,'%02d'), '_TFR_evoked.mat'];
        delete(fname);
        fname = [ss '/day' num2str(dd,'%02d'), '/' ss '_day' num2str(dd,'%02d'), '_TFR_induced.mat'];
        delete(fname);
%         if exist(fname, 'file')
%             disp([ss num2str(dd,'%02d')])
%         end
    end
end