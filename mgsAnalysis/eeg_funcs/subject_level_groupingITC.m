function ITCout = subject_level_groupingITC(ITCin, newinput, is_all)
    if nargin < 3
        is_all = 0;
    end
    ITCout = ITCin;
    if is_all
        ITCout.itcspctrm = cat(4, ITCin.itcspctrm, newinput.itcspctrm);
    else
        ITCout.itcspctrm = cat(1, ITCin.itcspctrm, newinput.itcspctrm);
    end
end