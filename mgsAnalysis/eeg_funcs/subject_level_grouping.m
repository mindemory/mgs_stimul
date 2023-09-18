function TFRout = subject_level_grouping(TFRin, newinput)
    TFRout = TFRin;
    [~, orig_indices] = ismember(TFRin.label, newinput.label);
    newinput.powspctrm = newinput.powspctrm(orig_indices, :, :);
    TFRout.powspctrm = cat(4, TFRin.powspctrm, newinput.powspctrm);
end