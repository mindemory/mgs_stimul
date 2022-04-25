function drwng_connected = connect_missing_points(drwng_connected)
    x_size = size(drwng_connected, 1);
    ii = 1;
    while ii < x_size
        if abs(drwng_connected(ii, 1) - drwng_connected(ii+1, 1)) <= 1
            ii = ii + 1;
        elseif drwng_connected(ii, 1) < drwng_connected(ii+1, 1)
            X = drwng_connected(ii, 1):drwng_connected(ii+1, 1);
            lenX = length(X);
            Y = drwng_connected(ii, 2) * ones(1, lenX);
            XY = [X; Y]';
            x_size = x_size + lenX;
            drwng_connected = [drwng_connected(1:ii, :); XY; drwng_connected(ii+1:end, :)];
            ii = ii + lenX - 1;
        elseif drwng_connected(ii, 1) > drwng_connected(ii+1, 1)
            X = drwng_connected(ii, 1):-1:drwng_connected(ii+1, 1);
            lenX = length(X);
            Y = drwng_connected(ii, 2) * ones(1, lenX);
            XY = [X; Y]';
            x_size = x_size + lenX;
            drwng_connected = [drwng_connected(1:ii, :); XY; drwng_connected(ii+1:end, :)];
            ii = ii + lenX - 1;
        end
    end
    
    
end
% ii = 1
% while ii < x_size
%     if ii == 47
%         drwng_connected(ii, 1)
%         drwng_connected(ii+1, 1)
%     end
%     if -1 <= drwng_connected(ii, 1) - drwng_connected(ii+1, 1) <= 1
%         ii = ii + 1;
%     else
%         ii
%         ii = ii +1;
%     end
% end