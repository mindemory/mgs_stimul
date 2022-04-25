%% Mrugank
% The function has been added to remove trials wherein the subject detects
% phosphenes but accidently closes drawing phosphenes too early.

function tmsRtnTpy = remove_invalid_trials(tmsRtnTpy)
    total_trials = size(tmsRtnTpy.Response.Detection, 2);
    invalid_trials = [];
    
    % Invalid trials are the ones that do not have NaN in the drawing
    % coords but have fewer data points. Here less than 100 data points is
    % considered as an invalid trial.
    for tt = 1:total_trials
        if ~sum(isnan(tmsRtnTpy.Response.Drawing.coords{tt}), 'all') && ...
                size(tmsRtnTpy.Response.Drawing.coords{tt}, 1) < 100
            invalid_trials = [invalid_trials, tt];
        end
    end
    
    % Replacing invalid trials by undetected trials
    for trial = invalid_trials
        tmsRtnTpy.Duration.drawing(trial) = NaN;
        tmsRtnTpy.Response.Detection(trial) = 0;
        tmsRtnTpy.Response.Drawing.coords{trial} = NaN;
        tmsRtnTpy.StrtTime.drawing(trial) = 0;
    end
    
    for coilLocInd = unique(tmsRtnTpy.Response.CoilLocation)
        detections = tmsRtnTpy.Response.Detection(tmsRtnTpy.Response.CoilLocation == coilLocInd);
        
        %if sum
    end
end