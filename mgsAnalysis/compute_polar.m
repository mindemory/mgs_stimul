function ii_sess = compute_polar(ii_sess)
    
    % Compute angular errors (in radians)
    theta_isacc = atan2(ii_sess.i_sacc_raw(:, 2), ii_sess.i_sacc_raw(:, 1));
    theta_fsacc = atan2(ii_sess.f_sacc_raw(:, 2), ii_sess.f_sacc_raw(:, 1));
    theta_targ = atan2(ii_sess.targ(:, 2), ii_sess.targ(:, 1));
    ii_sess.isacc_theta_err = theta_isacc - theta_targ;
    ii_sess.fsacc_theta_err = theta_fsacc - theta_targ;
    ii_sess.corrected_theta_err = theta_fsacc - theta_isacc;
    
    % Compute radial errors (in dva)
    radius_isacc = hypot(ii_sess.i_sacc_raw(:, 1), ii_sess.i_sacc_raw(:, 2));
    radius_fsacc = hypot(ii_sess.f_sacc_raw(:, 1), ii_sess.f_sacc_raw(:, 2));
    radius_targ = hypot(ii_sess.targ(:, 1), ii_sess.targ(:, 2));
    ii_sess.isacc_radius_err = radius_isacc - radius_targ;
    ii_sess.fsacc_radius_err = radius_fsacc - radius_targ;
    ii_sess.corrected_radius_err = radius_fsacc - radius_isacc;
    
    % Compute euclidean errors (in dva)
    ii_sess.isacc_euc_err = hypot(ii_sess.i_sacc_raw(:, 1)-ii_sess.targ(:, 1), ...
                                    ii_sess.i_sacc_raw(:, 2)-ii_sess.targ(:, 2));
    ii_sess.fsacc_euc_err = hypot(ii_sess.f_sacc_raw(:, 1)-ii_sess.targ(:, 1), ...
                                    ii_sess.f_sacc_raw(:, 2)-ii_sess.targ(:, 2));
    ii_sess.corrected_euc_err = hypot(ii_sess.f_sacc_raw(:, 1)-ii_sess.i_sacc_raw(:, 1), ...
                                        ii_sess.f_sacc_raw(:, 2)-ii_sess.i_sacc_raw(:, 2));                   

end
% 
% 
% figure();
% pro_indices = ii_sess.ispro == 1;
% anti_indices = ii_sess.ispro == 0;
% 
% subplot(2, 2, 1)
% histogram(ii_sess.f_sacc_err(pro_indices), 50, 'FaceColor', 'blue', 'FaceAlpha', 0.7); hold on;
% histogram(ii_sess.f_sacc_err(anti_indices), 50, 'FaceColor', 'red', 'FaceAlpha', 0.7);
% title('MGS error')
% 
% subplot(2, 2, 2)
% histogram(ii_sess.fsacc_theta_err(pro_indices), 1000, 'FaceColor', 'blue', 'FaceAlpha', 0.7); hold on;
% histogram(ii_sess.fsacc_theta_err(anti_indices), 1000, 'FaceColor', 'red', 'FaceAlpha', 0.7);
% xlim([-pi/4, pi/4])
% title('Angular error (in radians)')
% 
% subplot(2, 2, 3)
% histogram(ii_sess.fsacc_radius_err(pro_indices), 50, 'FaceColor', 'blue', 'FaceAlpha', 0.7); hold on;
% histogram(ii_sess.fsacc_radius_err(anti_indices), 50, 'FaceColor', 'red', 'FaceAlpha', 0.7);
% title('Radial error (in dva)')
% 
% subplot(2, 2, 4)
% histogram(ii_sess.fsacc_euc_err(pro_indices), 50, 'FaceColor', 'blue', 'FaceAlpha', 0.7); hold on;
% histogram(ii_sess.fsacc_euc_err(anti_indices), 50, 'FaceColor', 'red', 'FaceAlpha', 0.7);
% title('MGS error (check)')

