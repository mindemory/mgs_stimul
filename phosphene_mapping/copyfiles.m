function copyfiles(subjID, session, data_dir)
    % Copies files from github to data server, and returns new data path
    git_dir = ['Results/sub' subjID];
    git_data = [git_dir '/tmsRtnTpy_sub' subjID '_sess' session '.mat'];
    
    if ~exist(data_dir, 'dir')
        mkdir(data_dir)
    end
    copyfile(git_data, data_dir);
end