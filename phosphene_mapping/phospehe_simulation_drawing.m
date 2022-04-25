screen.screenXpixels = 1920;
screen.screenYpixels = 1080;
power = 3;
noisee = wgn(screen.screenYpixels, screen.screenXpixels, power);
%noiseMask = imread(noisee);
%figure();
%imshow(noisee)
mask_location = zeros(screen.screenYpixels, screen.screenXpixels);

xpixs = 1:screen.screenXpixels;  % plotting range from -5 to 5
ypixs = 1:screen.screenXpixels;
[x, y] = meshgrid(xpixs, ypixs);  % Get 2-D mesh for x and y based on r
alpha = 4.2;
a = 17;
b = 3;
delx = screen.xCenter;
dely = screen.yCenter + 700;
x = x - delx; y = y-dely;
ellipse_phosph = (((x.*cos(alpha) + y.*sin(alpha)).^2)./a) + ...
    (((x.*sin(alpha) - y.*cos(alpha)).^2)./b) - 150.*x < 0;



output_phosph = ones(length(xpixs), length(ypixs)); % Initialize to 1

output_phosph(~ellipse_phosph) = 0;

col_diff = screen.screenXpixels - screen.screenYpixels;
output_phosph(:,1:col_diff/2-1) = [];
output_phosph(:,end-col_diff/2:end) = [];

ellipse_bound = [];
[outputx, outputy] = size(output_phosph);
for xx = 1:outputx
    if sum(output_phosph(xx, :) > 0)
        yy_f = find(output_phosph(xx, :), 1, 'first');
        ellipse_bound = [ellipse_bound; [xx, yy_f]];
        yy_l = find(output_phosph(xx, :), 1, 'last');
        ellipse_bound = [ellipse_bound; [xx, yy_l]];
    end
end

for yy = 1:outputy
    if sum(output_phosph(:, yy) > 0)
        yy;
        xx_f = find(output_phosph(:, yy), 1, 'first');
        ellipse_bound = [ellipse_bound; [xx_f, yy]];
        xx_l = find(output_phosph(:, yy), 1, 'last');
        ellipse_bound = [ellipse_bound; [xx_l, yy]];
    end
end
noiseMask = noisee .* output_phosph';
%figure();
