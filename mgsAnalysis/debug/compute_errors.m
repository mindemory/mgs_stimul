function [real, iEye] = compute_errors(scatter_x, scatter_y, target_x, target_y, p)
    % Compute errors for saccade simulated points
    scatter_r = sqrt((scatter_x - p.xcenter).^2 + (scatter_y - p.ycenter).^2);
    scatter_theta = atan2d(scatter_y - p.ycenter, scatter_x - p.xcenter);
    scatter_va = scatter_r/p.ppd;%atan2d(scatter_r, p.viewDistance);
       
    % Compute errors for the target
    target_r = sqrt((target_x - p.xcenter).^2 + (target_y - p.ycenter).^2);
    target_theta = atan2d(target_y - p.ycenter, target_x - p.xcenter);
    target_va = target_r/p.ppd;%atan2d(target_r, p.viewDistance);
    
    % Errors computed
    real.euclidean = sqrt((scatter_x - target_x).^2 + (scatter_y - target_y).^2); % in pixels
    real.dva = scatter_va - target_va; % in dva
    real.r = scatter_r - target_r; % in pixels
    real.theta = scatter_theta - target_theta; % in degrees
    
    % Errors as computed by iEye
    iEye_scatter_x = %(scatter_x - p.xcenter)/p.ppd;%atan2d(scatter_x - p.xcenter, p.viewDistance);
    iEye_scatter_y = %(scatter_y - p.ycenter)/p.ppd;%atan2d(scatter_y - p.ycenter, p.viewDistance);
    iEye_target_x = %(target_x - p.xcenter)/p.ppd;%atan2d(target_x - p.xcenter, p.viewDistance);
    iEye_target_y = %(target_y - p.ycenter)/p.ppd;%atan2d(target_y - p.ycenter, p.viewDistance);
    iEye_scatter_x = atan2d(scatter_x - p.xcenter, p.viewDistance);
    iEye_scatter_y = atan2d(scatter_y - p.ycenter, p.viewDistance);
    iEye_target_x = atan2d(target_x - p.xcenter, p.viewDistance);
    iEye_target_y = atan2d(target_y - p.ycenter, p.viewDistance);
    iEye.euclidean = sqrt((iEye_scatter_x - iEye_target_x).^2 + (iEye_scatter_y - iEye_target_y).^2);

end
