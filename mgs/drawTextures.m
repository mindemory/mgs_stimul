function drawTextures(texture_name, color, eccentricity)
% created by Mrugank (06/15/2022):
% drawTexture can be called with texture_name to draw either a fixation
% cross or a stimulus at periphery. color argument is optional. Default
% color for either stimulus is white.
global screen parameters;

switch texture_name
    % Drawing Fixation Cross
    case 'FixationCross'
        if nargin < 2
            fixcolor = screen.white;
        else
            fixcolor = color;
        end
        % Get pixel width and height for inner and outer circle based of VA
        [r_pix_width, r_pix_height] = va2pixel(parameters.fixationSizeDeg, 'fixation');
        [inner_width, inner_height] = va2pixel(parameters.fixationSizeDeg/3, 'fixation');
        
        % Coordinates for fixation cross
        xCoords = [-r_pix_width r_pix_width 0 0];
        yCoords = [0 0 -r_pix_height r_pix_height];
        allCoords = [xCoords; yCoords];
        
        % Coordinates for outer circle
        baseRect_outer = [0 0 r_pix_width*2 r_pix_height*2];
        maxDiameter_outer = ceil(max(baseRect_outer) * 1.1);
        centeredRect_outer = CenterRectOnPointd(baseRect_outer, screen.xCenter, screen.yCenter);
        
        % Coordinates for inner circle
        baseRect_inner = [0 0 inner_width*2 inner_height*2];
        maxDiameter_inner = ceil(max(baseRect_inner) * 1.1);
        centeredRect_inner = CenterRectOnPointd(baseRect_inner, screen.xCenter, screen.yCenter);
        
        % Draw Fixation cross
        Screen('FillOval', screen.win, screen.black, centeredRect_outer, maxDiameter_outer);
        Screen('DrawLines', screen.win, allCoords, round(inner_width*1.5), ...
            fixcolor, [screen.xCenter screen.yCenter], 1); % 2 is for smoothing
        Screen('FillOval', screen.win, screen.black, centeredRect_inner, maxDiameter_inner);
        Screen('Flip', screen.win);
    
    % Drawing Stimulus
    case 'Stimulus'
        if nargin < 2
            stimcolor = screen.white;
        else
            stimcolor = color;
        end
        [ecc1, ecc2] = va2pixel(eccentricity, 'fixation', parameters.stimulusSizeDeg);
        baseRect = [0 0 inner_width*2 inner_height*2];
        maxDiameter = ceil(max(baseRect) * 1.1);
        centeredRect = CenterRectOnPointd(baseRect, screen.xCenter, screen.yCenter);
        Screen('FillOval', screen.win, stimcolor, centeredRect, maxDiameter);
        Screen('Flip', screen.win);
end