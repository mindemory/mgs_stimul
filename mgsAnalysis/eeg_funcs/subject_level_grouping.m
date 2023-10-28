function TFRout = subject_level_grouping(TFRin, newinput, is_all)
    if nargin < 3
        is_all = 0;
    end
    TFRout = TFRin;
    if is_all
        TFRout.powspctrm = cat(4, TFRin.powspctrm, newinput.powspctrm);
    else
        TFRout.powspctrm = cat(1, TFRin.powspctrm, newinput.powspctrm);
    end
end