clear all; clc;

subjID = '01'; session = '01';
temp_tmsRtnTpy = load('Results/sub27/tmsRtnTpy_sub27_sess03.mat');
%temp_tmsRtnTpy = load('Results/backup/sub01/tmsRtnTpy_sub01_sess01.mat');

loadDIR = ['Results/backup/sub' subjID];

saveDIR = ['Results/sub' subjID];
data = [loadDIR '/tmsRtnTpy_sub' subjID '_sess' session];
load(data);
xx_old = 800; yy_old = 600;

tmsRtnTpy.Params.screen = temp_tmsRtnTpy.tmsRtnTpy.Params.screen;
xx_new = tmsRtnTpy.Params.screen.screenXpixels
yy_new = tmsRtnTpy.Params.screen.screenYpixels

cc = temp_tmsRtnTpy.tmsRtnTpy.Response.Drawing.coords;
for ii = 1:length(cc)
    if ~isnan(cc{1, ii})
        cc_x = xx_new - xx_old - cc{1, ii}(:, 1);
        cc_y = yy_new + yy_old - cc{1, ii}(:, 2);
        
        cc{1, ii} = [cc_x, cc_y];
    end
end
saveName = [saveDIR '/tmsRtnTpy_sub' subjID '_sess' session];
save(saveName,'tmsRtnTpy')

calcPhospheneArea(subjID, session, 1);
calcStimLocations(subjID,session)
