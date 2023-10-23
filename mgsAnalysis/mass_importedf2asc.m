subs = [1 3 5 6 7 8 12 13 14 15 16 17 18 22 23 24];%, 8, 18, 22, 23, 24];
days = [1, 2, 3];
for ss = 1:length(subs)
    disp(['We are running subject' num2str(ss, '%02d')])
    this_sub = subs(ss);
    %A01_GetTimeReport(this_sub);
    for dd = days
        A02_EyeAnalysis(this_sub, dd);
    end
    clearvars -except subs days ss
end

subs = [1, 3, 5, 6, 7, 8, 12, 13, 14, 15, 16, 17, 18];
days = [1, 2, 3];
for ss = 1:length(subs)
    disp(['We are running subject' num2str(ss, '%02d')])
    this_sub = subs(ss);
    %A01_GetTimeReport(this_sub);
    for dd = days
        A02_EyeAnalysis(this_sub, dd);
    end
    clearvars -except subs days ss
end

subs = [1 3 5 6 7 8 12 13 14 15 16 17 18 22 23 24];
days = [1, 2, 3];
for ss = 1:length(subs)
    disp(['We are running subject' num2str(ss, '%02d')])
    this_sub = subs(ss);
    %A01_GetTimeReport(this_sub);
    for dd = dayssubs = [18];
    end
end
days = [1, 2, 3];
for ss = 1:length(subs)
    disp(['We are running subject' num2str(ss, '%02d')])
    this_sub = subs(ss);
    %A01_GetTimeReport(this_sub);
    for dd = days
        A02_EyeAnalysis(this_sub, dd);
    end
    clearvars -except subs days ss
end
        A02_EyeAnalysis(this_sub, dd);
    end
    clearvars -except subs days ss
end


subs = [1  5  6 7 8];
%subs = [13];
days = [1, 2, 3];
for ss = 1:length(subs)
    this_sub = subs(ss);
    parfor dd = days
    
    A03_PreprocEEG_TMS_temp(this_sub, dd);
    end
%     for dd = days
%         A02_EyeAnalysis(this_sub, dd);
%     end
end

%subs = [1 3 5 6 7 8 12 13 14 15 16 17 22 24];
subs = [1 3 5 6 7 8];
days = [1, 2, 3];
parfor ss = 1:length(subs)
    this_sub = subs(ss);
    for dd = days
    A03_PreprocEEG_TMS(this_sub, dd);
    end
end