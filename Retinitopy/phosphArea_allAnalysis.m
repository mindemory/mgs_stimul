function phosphArea_allAnalysis()

clear all

subjID = int2strz(input(sprintf('\nsubject: ')),2);
session = int2strz(input(sprintf('\nsession: ')),2);
%% set parameters
display(sprintf('\n\t%s','setting parameters...'));
parameters = loadParameters(subjID,session);

% run main phosphene recording script
display(sprintf('\n\t%s','initiating phosphene locaton recording ...'));
saveData = recordPhosphene(subjID,session,parameters);
if strcmp(saveData,'n')
    return
end
display(sprintf('\n----------------------------------------------------------------'));

%% preprocess recorded data
display(sprintf('\n\t%s','calculating perceived phosphene areas ...'));
tic;
calcPhospheneArea(subjID,session,parameters.overlapThreshold);
strT = toc;
display(sprintf('\n\tperceived phosphene areas calculated (%.2f seconds)',strT));
display(sprintf('\n----------------------------------------------------------------'));

%% calculate coordinates that cover phosphened areas
display(sprintf('\n\t%s','calculating sampling coordinates sets ...'));
tic;
calcStimLocations(subjID,session);
strT = toc;
display(sprintf('\n\tsampling coordinates sets calculated (%.2f seconds)',strT));
