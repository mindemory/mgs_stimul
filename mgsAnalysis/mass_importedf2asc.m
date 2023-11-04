subs = [1];
days = [1, 2, 3];
for ss = 1:length(subs)
    disp(['We are running subject' num2str(ss, '%02d')])
    this_sub = subs(ss);
    %A01_GetTimeReport(this_sub);
    for dd = days
        A03_PreprocEEG_TMS(this_sub, dd);
    end
    clearvars -except subs days ss
end