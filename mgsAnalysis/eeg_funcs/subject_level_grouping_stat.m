function statmatout = subject_level_grouping_stat(statmatin, newstatmat)
    statmatout = statmatin;
%     [~, orig_indices] = ismember(TFRin.label, newinput.label);
%     newinput.powspctrm = newinput.powspctrm(orig_indices, :, :);
    statmatout.mask = cat(4, statmatin.mask, newstatmat.mask);
    statmatout.prob = cat(4, statmatin.prob, newstatmat.prob);
    statmatout.stat = cat(4, statmatin.stat, newstatmat.stat);
end