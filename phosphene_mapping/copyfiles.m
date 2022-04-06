function data_dir = copyfiles(subjID, session)
    git_dir = ['Results/sub' subjID];
    git_data = [git_dir '/tmsRtnTpy_sub' subjID '_sess' session '.mat'];
    
    data_dir = ['/d/DATA/hyper/experiments/Mrugank/TMS/Phosphene_data/sub' subjID];
    if ~exist(data_dir, 'dir')
        mkdir(data_dir)
    end
    copyfile(git_data, data_dir);
end