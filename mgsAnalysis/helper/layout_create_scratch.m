clear; close all; clc;
load('easycapM11.mat')
lay.pos = [[-0.126383386381155,0.438431721551068];
    [-0.00178659736053717,0.234405273014758];
    [-0.163872215151574,0.239618861066237];
    [-0.325452142998134,0.274013889884452];
    [-0.475498169471911,0.189524916301703]; 
    [-0.283688409542449,0.132074434037128];
    [-0.0918786496129868,0.118550379397816];
    [-0.202150337299248,-1.14213280356283e-05];
    [-0.401017860598115,-1.14213280356283e-05];
    [-0.459183673469388,-0.206386403217550];
    [-0.283688409542449,-0.132087658732749];
    [-0.0918755216339488,-0.118553986132985];
    [-0.00178659736053717,-0.231030022383399];
    [-0.163861788554780,-0.239629681271744];
    [-0.325452142998134,-0.274024710089959];
    [-0.126381301061796,-0.438436530531294];
    [-0.00194195365275776,-0.459183673469388];
    [0.122796637084249,-0.438429317060955];
    [0.160279209896592,-0.239629681271744];
    [0.321860180402831,-0.274024710089959];
    [0.459183673469388,-0.190083960252924];
    [0.280104788224582,-0.132085254242636];
    [0.0882960709547985,-0.118549177152759];
    [-0.00178659736053717,-1.14213280356283e-05];
    [0.198567758641059,-1.14213280356283e-05];
    [0.397435281939927,-1.14213280356283e-05];
    [0.459028317177167,0.189524916301703];
    [0.280104788224582,0.132072029547016];
    [0.0883002415935158,0.118545570417590];
    [0.160288593833706,0.239618861066237];
    [0.321860180402831,0.274013889884452];
    [0.122797679743928,0.438425710325786];
    [-0.233971268052812,0.375711799204344];
    [-0.120921934980808,0.335348825926217];
    [-0.00194195365275776,0.328538656439854];%here
    [-0.0778580049049956,0.234341005268692];
    [-0.244409334102615,0.244405273014758];
    [-0.379636038554033,0.151904263997198];
    [-0.189225527914236,0.124965559018704];
    [-0.102716054319974,-1.14213280356283e-05];
    [-0.300594093583155,-1.14213280356283e-05];
    [-0.377030432015380,-0.152959835156707];
    [-0.189225527914236,-0.124976379224212];
    [-0.0778580049049956,-0.234355432209369];
    [-0.244409334102615,-0.254419699955434];
    [-0.233971268052812,-0.375725023899964];
    [-0.120900039127542,-0.335371668582288];
    [-0.00178659736053717,-0.348549476645361];
    [0.117317460469354,-0.335371668582288];
    [0.230387646734945,-0.375722619409851];
    [0.240826755444427,-0.254424508935660];
    [0.0742743835871280,-0.234360241189594];
    [-0.00178659736053717,-0.116376720335866];
    [0.185642949256047,-0.124976379224212];
    [0.373453066655588,-0.152962239646820];
    [0.297001088328173,-1.14213280356283e-05];
    [0.0991334756617859,-1.14213280356283e-05];
    [0.185642949256047,0.124965559018704];
    [0.373470791870137,0.152791520848813];
    [0.240826755444427,0.254410081994983];
    [0.230387646734945,0.375709394714231];
    [0.117339356322620,0.335348825926217];
    [0.0742743835871280,0.234345814248918];
    [-0.00178659736053717,0.116365900130358]];
    
lay.width = ones(64, 1) * 0.0615;
lay.height = ones(64, 1) * 0.0356;
lay.label = {'Fp1','Fz','F3','F7','FT9','FC5','FC1','C3','T7','TP9', ...
    'CP5','CP1','Pz','P3','P7','O1','Oz','O2','P4','P8','TP10','CP6','CP2','Cz','C4', ...
    'T8','FT10','FC6','FC2','F4','F8','Fp2','AF7','AF3','AFz','F1','F5','FT7',...
    'FC3','C1','C5','TP7','CP3','P1','P5','PO7','PO3','POz','PO4','PO8','P6','P2','CPz',...
    'CP4','TP8','C6','C2','FC4','FT8','F6','AF8','AF4','F2', 'FCz'};
lay.label = lay.label';
%lay.outline = lay.outline;
%lay.mask = lay.mask;
savefname = 'acticap-64_md.mat';
save(savefname, 'lay')
cfg = []; cfg.layout = 'acticap-64_md.mat'; ft_layoutplot(cfg)