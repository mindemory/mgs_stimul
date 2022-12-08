% clear; close all; clc; delete(gcp('nocreate'))
% pool_val = 1:4;
% %t_array = [];
% for p = pool_val
%     disp(['Running for p = ' num2str(p)])
%     parpool(p);
%     a = MyCode(1000);
%     delete(gcp('nocreate'))
% end
clear; close all; clc;
disp('We are here!')
%save local.mat t_array
function a = MyCode(A)
    tic
    parfor i = 1:200
        a(i) = max(abs(eig(rand(A))));
    end
    toc
end