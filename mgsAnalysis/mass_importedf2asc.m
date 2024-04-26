subs = [1, 3, 5, 6, 7, 8, 10, 11, 12, 13, 14, 15, 16, 17, 18, 22, 23, 24, 25, 26, 27];
%days = [1, 2, 3];
for ss = 1:length(subs)
    this_sub = subs(ss);
    disp(['We are running subject' num2str(this_sub, '%02d')])
    
    %N01_CreateDayFour(this_sub);
    A01_GetTimeReport(this_sub, 'calib');
    A01_GetTimeReport(this_sub, 'nocalib');
%     for dd = days
%         A03_PreprocEEG_TMS(this_sub, dd);
%     end
    clearvars -except subs days ss
end


subs = [1, 3, 5, 6, 7, 10, 12, 14, 15, 16, 17, 22, 23, 24, 25, 26, 27];
days = [1, 2, 3];
for ss = 1:length(subs)
    disp(['We are running subject' num2str(ss, '%02d')])
    this_sub = subs(ss);
    %A01_GetTimeReport(this_sub);
    for dd = days
        A03_NewPipelineEEG_TMS(this_sub, dd);
    end
    clearvars -except subs days ss
end

subs = [1, 3, 5, 6, 7];
days = [1, 2, 3];
parfor ss = 1:length(subs)
    disp(['We are running subject' num2str(ss, '%02d')])
    this_sub = subs(ss);
    %A01_GetTimeReport(this_sub);
    for dd = days
        A03_NativePipelineEEG_TMS(this_sub, dd);
    end
    clearvars -except subs days ss
end

subs = [1, 3, 5, 6, 7, 8, 11, 12, 13, 14, 15, 16, 17, 18, 22, 23, 24, 25, 26, 27];
%days = [1, 2, 3];
for ss = 1:length(subs)
    disp(['We are running subject' num2str(ss, '%02d')])
    this_sub = subs(ss);
    %N01_CreateDayFour(this_sub);
    %A01_GetTimeReport(this_sub);
    for dd = days
        A02_EyeAnalysis(this_sub, dd);
    end
    clearvars -except subs days ss
end