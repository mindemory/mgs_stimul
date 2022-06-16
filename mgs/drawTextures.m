function drawTextures(texture_name, color)
% Created by mrugank (02/17/2022):
% Currently in temporary state. Has not yet been implemented in the code.
% It is produced by merging the individual showxxxx functions to avoid
% redundancy. Further testing is needed before implementing in the main
% code.


global screen parameters;

% global fixCrossData;
% global taskMap;
% global exitProgram;
% white = screen.white;

switch texture_name
    case 'FixationCross'
        if nargin < 2
            fixcolor = screen.white;
        else
            fixcolor = color;
        end
        [r_pix_width, r_pix_height] = va2pixel(parameters.fixationCrossSizeDeg);
        [inner_width, inner_height] = va2pixel(parameters.fixationCrossSizeDeg/3);
        
        xCoords = [-r_pix_width r_pix_width 0 0];
        yCoords = [0 0 -r_pix_height r_pix_height];
        allCoords = [xCoords; yCoords];
        
        baseRect_outer = [0 0 r_pix_width*2 r_pix_height*2];
        maxDiameter_outer = ceil(max(baseRect_outer) * 1.1);
        centeredRect_outer = CenterRectOnPointd(baseRect_outer, screen.xCenter, screen.yCenter);
        
        baseRect_inner = [0 0 inner_width*2 inner_height*2];
        maxDiameter_inner = ceil(max(baseRect_inner) * 1.1);
        centeredRect_inner = CenterRectOnPointd(baseRect_inner, screen.xCenter, screen.yCenter);
        
        Screen('FillOval', screen.win, screen.black, centeredRect_outer, maxDiameter_outer);
        Screen('DrawLines', screen.win, allCoords, round(inner_width*1.5), ...
            fixcolor, [screen.xCenter screen.yCenter], 1); % 2 is for smoothing
        Screen('FillOval', screen.win, screen.black, centeredRect_inner, maxDiameter_inner);
        Screen('Flip', screen.win);
    case 'Stimulus'
        if nargin < 2
            stimcolor = screen.white;
        else
            stimcolor = color;
        end
        baseRect = [0 0 inner_width*2 inner_height*2];
        maxDiameter = ceil(max(baseRect) * 1.1);
        centeredRect = CenterRectOnPointd(baseRect, screen.xCenter, screen.yCenter);
        Screen('FillOval', screen.win, stimcolor, centeredRect, maxDiameter);
        Screen('Flip', screen.win);
end