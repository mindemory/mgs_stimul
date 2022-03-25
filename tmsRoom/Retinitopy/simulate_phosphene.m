x_size = 1000;
y_size = 500;
power = 100;
noisee = wgn(x_size, y_size, power);
figure();
imshow(noisee)