function [real, iEye] = compute_errors(scatter_x, scatter_y, target_x, target_y, p)
    % Compute errors for saccade simulated points
    scatter_r = sqrt((scatter_x - p.xcenter).^2 + (scatter_y - p.ycenter).^2);
    scatter_theta = atan2d(scatter_y - p.ycenter, scatter_x - p.xcenter);
    scatter_va = atan2d(scatter_r, p.viewDistance);
       
    % Compute errors for the target
    target_r = sqrt((target_x - p.xcenter).^2 + (target_y - p.ycenter).^2);
    target_theta = atan2d(target_y - p.ycenter, target_x - p.xcenter);
    target_va = atan2d(target_r, p.viewDistance);
    
    % Errors computed
    real.euclidean = sqrt((scatter_x - target_x).^2 + (scatter_y - target_y).^2);
    real.dva = scatter_va - target_va;
    real.r = scatter_r - target_r;
    real.theta = scatter_theta - target_theta;
    
    % Errors as computed by iEye
    iEye_scatter_x = atan2d(scatter_x - p.xcenter, p.viewDistance);
    iEye_scatter_y = atan2d(scatter_y - p.ycenter, p.viewDistance);
    iEye_target_x = atan2d(target_x - p.xcenter, p.viewDistance);
    iEye_target_y = atan2d(target_y - p.ycenter, p.viewDistance);
    iEye.euclidean = sqrt((iEye_scatter_x - iEye_target_x).^2 + (iEye_scatter_y - iEye_target_y).^2);

end
