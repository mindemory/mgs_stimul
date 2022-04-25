function [XY] = connectPoints(XY1,XY2)

% Mrugank (description): The code was adapated from Masih. As of this
% working, the code only attempts to join the points along the x-axis.
% Though this does not appear to be hampering the shape or the area of the
% phosphene drawing constructed by the subject, it can probably be
% imrpovised.

x1 = XY1(1); x2 = XY2(1);
y1 = XY1(2); y2 = XY2(2);

if x1 == x2
    Y = y1:y2;
    X = x1 * ones(1, length(Y));
elseif x1 < x2
    slope = (y2-y1)/(x2-x1);
    X = x1:x2;
    Y = round(slope*(X - x1) + y1);
elseif x1 > x2
    slope = (y2-y1)/(x2-x1);
    X = x1:-1:x2;
    Y = round(slope*(X - x1) + y1);
end

XY = [X; Y]';

end
