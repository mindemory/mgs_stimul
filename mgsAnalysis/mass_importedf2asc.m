subs = [1, 3, 6, 8, 12, 13, 14, 15, 16];
%subs = [13];
days = [1, 2, 3];
parfor ss = 1:length(subs)
    this_sub = subs(ss);
    %A01_GetTimeReport(this_sub);
    for dd = days
        A02_EyeAnalysis(this_sub, dd);
    end
end