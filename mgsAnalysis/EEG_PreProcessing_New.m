%% Part 1
clear all; close all; clc
Dataloc='C:\Users\omnia\OneDrive\Desktop\EEG Vigilance Data\Raw Data\';
%Savein='No Audio\\';
Savein='Pure Tone\\';
% Savein='Bineural Beats\\';
filename='AbdlaalV';
%%Load dataset
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab; %open GUI
EEG = pop_loadset('filename', [filename '.set'],'filepath', [Dataloc Savein filename]); 
%%
%%Remove M1 M2 HEOG VEOG
EEG = pop_select( EEG,'channel',{'Fp1' 'Fpz' 'Fp2' 'F7' 'F3' 'Fz' 'F4' 'F8' 'FC5' 'FC1' 'FC2' 'FC6' 'T7' 'C3' 'Cz'... 
    'C4' 'T8' 'CP5' 'CP1' 'CP2' 'CP6' 'P7' 'P3' 'Pz' 'P4' 'P8' 'POz' 'O1' 'Oz' 'O2' 'AF7' 'AF3' 'AF4' 'AF8' 'F5' ... 
    'F1' 'F2' 'F6' 'FC3' 'FCz' 'FC4' 'C5' 'C1' 'C2' 'C6' 'CP3' 'CPz' 'CP4' 'P5' 'P1' 'P2' 'P6' 'PO5' 'PO3' 'PO4'... 
    'PO6' 'FT7' 'FT8' 'TP7' 'TP8' 'PO7' 'PO8'});

%%Load channel loc 
EEG=pop_chanedit(EEG, 'load',...
    {'C:\Users\omnia\OneDrive\Desktop\Thesis\Preprocessed  Vigilance Data\\NeuroASA64_NOm.loc' ...
    'filetype' 'autodetect'});

%%Bandpass filter 
% EEG = pop_eegfiltnew(EEG, 0.5,40,3300,0,[],0);
EEG = pop_eegfiltnew(EEG, 'locutoff',0.5,'hicutoff',40,'plotfreqz',1);

%%Rereference to average
EEG = pop_reref( EEG, []);

%%name,save and update data on GUI 
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG,0, 'setname',[filename '_P'], 'gui','off'); 
eeglab redraw;
EEG = pop_saveset( EEG, 'filename',[filename '_P.set'],'filepath',[Dataloc Savein filename]);
eeglab redraw;
%chech that everything is fine and check the length of the data to decide
%the limits of each window
%% Part 2
%Extract task data only and save
EEG = pop_rmdat( EEG, {'111'},[-4000 0] ,0); %0 for keep
EEG = pop_rmdat( EEG, {'111'},[0 120] ,1);
EEG = pop_rmdat( EEG, {'1, frequent'},[-150 0] ,1);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'setname',[filename '_P_TaskOnly'],'gui','off'); 
EEG = pop_saveset( EEG, 'filename',[filename '_P_TaskOnly.set'],'filepath',[Dataloc Savein filename]);
eeglab redraw;

% %% divide data into windows
% %after each window, remove flashing then save then extract epoches then
% %save again
% if (floor(length(EEG.times)/500))==3600
%     %Window1
%     EEG = pop_select( EEG,'time',[0 1200] );
%     [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'setname',[filename '_Window1'],'gui','off'); 
%     EEG = pop_saveset( EEG, 'filename',[filename 'Window1.set'],'filepath',[Dataloc Savein filename]);
%     eeglab redraw;
%     %Window2
%     [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'retrieve',2,'study',0); 
%     EEG = pop_select( EEG,'time',[1201 2400] );
%     [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'setname',[filename '_Window2'],'gui','off'); 
%     EEG = pop_saveset( EEG, 'filename',[filename 'Window2.set'],'filepath',[Dataloc Savein filename]);
%     eeglab redraw;
%     %Window3
%     [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'retrieve',2,'study',0);
%     EEG = pop_select( EEG,'time',[2401 3600] );
%     [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'setname',[filename '_Window3'],'gui','off'); 
%     EEG = pop_saveset( EEG, 'filename',[filename 'Window3.set'],'filepath',[Dataloc Savein filename]);
%     eeglab redraw;
% end 


% EEG = eeg_checkset( EEG );
% EEG = pop_select( EEG,'time',[0 1200] );
% [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'retrieve',2,'study',0); 
% EEG = eeg_checkset( EEG );
% EEG = pop_select( EEG,'time',[1201 2400] );
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'setname','AhFKV_NA_Window2','gui','off'); 
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'retrieve',2,'study',0); 
% EEG = eeg_checkset( EEG );
% EEG = pop_select( EEG,'time',[2401 3600] );
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'setname','AhFKV_NA_Window3','gui','off'); 
% %% Extract Epochs & Run ICA
% EEG = pop_epoch( EEG, {  '10'  }, [-0.2           1], 'newname',[filename '_P_TaskOnly_Epochs'], 'epochinfo', 'yes');
% EEG = eeg_checkset( EEG );
% EEG = pop_rmbase( EEG, [-200 0] ,[]);
% EEG = eeg_checkset( EEG );
% % EEG = pop_saveset( EEG, 'filename',[filename '_P_TaskOnly_Clean_NoFlashing_Epochs.set'],'filepath',[Dataloc Savein filename]);
% % eeglab redraw;
% EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on');
% EEG = eeg_checkset( EEG );
% EEG = pop_saveset( EEG, 'filename',[filename '_P_TaskOnly_Clean_NoFlashing_Epochs.set'],'filepath',[Dataloc Savein filename]);
% eeglab redraw;
% EEG = eeg_checkset( EEG );
% %% Save Data
% cd(['C:\Users\omnia\OneDrive\Desktop\All Vigilance Data\', Savein, filename ])
% Data=EEG.data;
% Markers=EEG.event;
% save('EEG_NoICA', 'Data', 'Markers')

