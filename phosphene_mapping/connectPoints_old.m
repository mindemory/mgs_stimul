function XY = connectPoints_old(XY1,XY2)

% Mrugank (description): The code was adapated from Masih. As of this
% working, the code only attempts to join the points along the x-axis.
% Though this does not appear to be hampering the shape or the area of the
% phosphene drawing constructed by the subject, it can probably be
% imrpovised.

nx = abs(XY2(1) - XY1(1));
ny = abs(XY2(2) - XY1(2));

sgnX = sign(XY2(1) - XY1(1));
sgnY = sign(XY2(2) - XY1(2));

XY = [];
x = XY1(1);
y = XY1(2);

while nx>1  
    if nx > 1
       x = x + sgnX;
       nx = nx - 1;
       
    end
%     if ny > 0
%        y = y + sgnY;
%        ny = ny - 1;
%     end
    XY = [XY;[x y]];
end
