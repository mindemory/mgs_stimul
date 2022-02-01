%created by israr ul haq, israruh@gmail.com. 4th April, 2016
%function that tracks the eye in a given time period. 
%gaze position and pupil size is gathered every 10 ms(consider making an
%option?) and a counter is used to keep track of each such instance and
%allows the pupil size to prevent blinks from being marked as breaks in
%fixation.
%TODO: add vargin method to check for the inputs and turn to defaults
%incase all inputs are not specified. make variable names more general as
%the function will most likely be used for all tracking cases.

function breakOfFixation = etFixBreakCheckModified(dummymode, breakOfFixation, el, eye_used, avgGazeCenter, avgPupilSize, fixationBoundary, currentTime,trialLength) 

    %
    minPupil = 0.4*avgPupilSize;
    %define a fixation boundary in case its not part of the input arguments
    %fixationBoundary = 66;%pixels

    %initialize required variables
    gazeCheckCounter = 0;
    fixBreak = 0;
    thisFixBreakCount = 0;
    fixationBreakInstance = 0;
    gazeDisFromCenter = 0;
    blinkTimeLowerBound = 0;
    blinkTimeUpperBound = 0;

    %while (GetSecs < delayT + delayStartT)
          %if mod(round((GetSecs - delayStartT),4)*1000,10) == 0 %check gaze every 10ms.
            if dummymode == 0 && Eyelink( 'NewFloatSampleAvailable') > 0
               % get the sample in the form of an event structure
               evt = Eyelink( 'NewestFloatSample');
               if eye_used ~= -1 % do we know which eye to use yet?
                  gazeCheckCounter = gazeCheckCounter + 1; %use the counter to tag the fixation checks
                  %get eye position
                  gazePosX = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
                  gazePosY = evt.gy(eye_used+1);
                  %get pupil size
                  pupilSize = evt.pa(eye_used+1);
                  %once pupil size is available, check against the threshold
                  %for blink, and if it crosses threshold, create a range
                  %around the current instance of fixation break. use this
                  %range to mark all breaks of fixations in this time period as
                  %part of the blink
                  if pupilSize < minPupil
                    blinkTimeUpperBound = gazeCheckCounter + 5;
                    blinkTimeLowerBound = gazeCheckCounter - 5;
                  end
                  % do we have valid data and is the pupil visible?
                  if gazePosX~=el.MISSING_DATA && gazePosY~=el.MISSING_DATA && evt.pa(eye_used+1)>0
                      gazePosRelativeX = gazePosX-avgGazeCenter(1,1);
                      gazePosRelativeY = gazePosY-avgGazeCenter(1,2);
                      gazeDisFromCenter = (gazePosRelativeX^2 + gazePosRelativeY^2)^0.5;

                      %check whether gaze position hasnt gone out of
                      %a circle of set radius.
                      if gazeDisFromCenter > fixationBoundary %in pixels
                        fixBreak = fixBreak + 1;
                        %disp(gazeDisFromCenter)
                        fixationBreakInstance = gazeCheckCounter; 
                        %have a counter here that gives information on how many +1s have already happened 
                        thisFixBreakCount = thisFixBreakCount + 1;
                      end
                    end
                    if fixationBreakInstance > blinkTimeLowerBound && fixationBreakInstance < blinkTimeUpperBound 
                       fixBreak = fixBreak - thisFixBreakCount; %this resets fixBreak back to zero in case of a blink
                       thisFixBreakCount = 0;
                       fixationBreakInstance = 0;
                    end

                    if gazeDisFromCenter < fixationBoundary   %reset thisFixBreakCount when the eye fixates again eg. after a blink
                       thisFixBreakCount = 0;
                    end

               end
            else %if dummymode == 1
                %for testing purposes we randomly generate 1s and 0s to assign to
                %the breakOfFixation variable:
                dummyFixBreakTimerSeed = round((trialLength-1).*rand(1,1) + 2);
                if abs(currentTime - dummyFixBreakTimerSeed)<0.05
                    breakOfFixation = round(rand(1,1));
                end
            end%end of if checking dummymode
          %end%end of checking gaze every 10 ms
          %fprintf('inside the for loop time now %f \n', round((GetSecs - delayStartT),4)*1000);
    %end%end of while loop

     %if gaze position goes out of a circle around centre of a set radius in pixels, count it as a break in 
     %fixation
    if fixBreak > 0
       breakOfFixation = 1;  
    end
end