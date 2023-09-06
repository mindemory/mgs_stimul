subs = [1, 3, 5, 6, 7, 8, 12, 13, 14, 15, 16, 17, 18, 22, 23, 24];
%subs = [1];
days = [1, 2, 3];
for ss = 1:length(subs)
    disp(['We are running subject' num2str(ss, '%02d')])
    this_sub = subs(ss);
    A01_GetTimeReport(this_sub);
    for dd = days
        A02_EyeAnalysis(this_sub, dd, 10, 0, 1);
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

subs = [18];
days = [1, 2, 3];
for ss = 1:length(subs)
    disp(['We are running subject' num2str(ss, '%02d')])
    this_sub = subs(ss);
    %A01_GetTimeReport(this_sub);
    for dd = dayssubs = [18];
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


subs = [ 3, 6, 8, 12, 13, 14, 15, 16];
%subs = [13];
%days = [1, 2, 3];
parfor ss = 1:length(subs)
    this_sub = subs(ss);
    A03_PreprocEEG(this_sub);
%     for dd = days
%         A02_EyeAnalysis(this_sub, dd);
%     end
end