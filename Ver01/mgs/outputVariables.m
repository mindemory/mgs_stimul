function outputVariables(tc,runTaskMap,userResp)
    disp('')
    disp('*****************************************************************')
    disp('')
    disp(sprintf('%-35s%-5d%-10s%-5d','variables for trial #', tc, 'run # ',runTaskMap(:,tc).run));
    disp('-----------------------------------------------------------------')
%     disp(sprintf('%-35s%-5d','condition', runTaskMap(:,tc).condition));
    disp(sprintf('%-35s%-5d','user responce', userResp));
%     disp(sprintf('%-35s%-5.2f','reactionTime', reactionTime));
    disp(sprintf('%-35s%-5.2f','stimulus gabor''s quadrant', runTaskMap(:,tc).quadrantStimulus));
    disp(sprintf('%-35s%-5.2f','stimulus gabor''s orientation', runTaskMap(:,tc).stimulusOrient));
    disp(sprintf('%-35s%-5.2f','probe gabor''s quadrant', runTaskMap(:,tc).quadrantProbe));
    disp(sprintf('%-35s%-5.2f','probe gabor''s orientation', runTaskMap(:,tc).probeOrient));

    disp('*****************************************************************')
    disp('')   
end