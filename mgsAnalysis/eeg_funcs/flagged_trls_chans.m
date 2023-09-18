function [flg_trls, flg_chans] = flagged_trls_chans(subjID, day)

if subjID               == 1
    if day              == 1
        flg_trls         = [39, 240, 297, 306, 307, 309, 366, 385, 389];
        flg_chans        = {'Fp1', 'Fp2', 'AF7', 'AF3', 'AFz', 'POz', 'AF8', 'AF4'};
    elseif day          == 2
        flg_trls         = [4, 5, 23, 86, 121, 167, 181, 182, 201, 210, 217, ...
                            241, 281, 282, 366, 388];
        flg_chans        = {'Fp1', 'F7', 'Oz', 'O2', 'Fp2', 'AF7', 'AF3', 'AFz', ...
                            'POz', 'PO8', 'CPz', 'C2', 'F6', 'AF8', 'AF4'};
    elseif day          == 3
        flg_trls         = [120, 140, 144, 145, 208, 209, 280, 297, 332, 333, 369, 370, 382];
        flg_chans        = {'Fp1', 'F7', 'TP9', 'Oz', 'F8', 'Fp2', 'AF7', 'AF3', ...
                            'AFz', 'F5', 'C1', 'POz', 'CPz', 'C2', 'F6', 'AF8', 'AF4'};
    end
elseif subjID           == 3 % Trial rejection not done well
    if day              == 1
        flg_trls         = [41, 87, 124, 125, 138, 139, 141, 142, 144, 161, 328, 340, 342];
        flg_chans        = {'Fp1', 'Fz', 'F7', 'FT9', 'T7', 'CP1', 'Pz', 'CP2', ...
                            'FT10', 'FC2', 'Fp2', 'AF7', 'AF3', 'AFz', 'F1', 'F5',...
                            'POz', 'P2', 'CPz', 'C2', 'AF8', 'AF4', 'FCz'};
    elseif day          == 2
        flg_trls         = [17, 122, 250, 251, 356];
        flg_chans        = {'Fp1', 'FC1', 'O2', 'CP6', 'Fp2', 'AF7', ...
                            'AF3', 'AFz', 'C2', 'AF8', 'AF4', 'FCz'};
    elseif day          == 3
        flg_trls         = [16, 25, 144, 200, 204, 205, 280, 360, 361, 362];
        flg_chans        = {'Fp1', 'FT9', 'O2', 'FT10', 'Fp2', 'AF7', 'AF3', ...
                            'AFz', 'PO3', 'PO4', 'CPz', 'C2', 'AF8', 'AF4', 'FCz'};
    end
elseif subjID           == 5
    if day              == 1
        flg_trls         = [13, 198, 201, 252, 265, 278, 281, 394];
        flg_chans        = {'Fp1', 'F3', 'FT9', 'P3', 'O1', 'Oz', 'O2', 'F4', ...
                            'Fp2', 'AF7', 'AF3', 'AFz', 'F5', 'C1', 'P1', 'POz', ...
                            'PO4', 'F6', 'AF4', 'F2', 'FCz'};
    elseif day          == 2
        flg_trls         = [23, 50, 258, 299, 319];
        flg_chans        = {'Fp1', 'O1', 'Oz', 'C1', 'P1', 'PO3', 'PO4', 'PO8', ...
                            'P2', 'C2', 'FT8', 'AF8', 'FCz'};
    elseif day          == 3
        flg_trls         = [185, 201, 218, 263, 264, 379, 392, 393, 394];
        flg_chans        = {'Fp1', 'F3', 'O1', 'Oz', 'FC2', 'F4', 'Fp2', 'AF3', ...
                            'AFz', 'F1', 'C1', 'P1', 'PO3', 'C2', 'FC4', 'F6', ...
                            'AF8', 'AF4', 'FCz'};
    end
elseif subjID           == 6
    if day              == 1
        flg_trls         = [83, 368];
        flg_chans        = {'Fp1', 'FT9', 'T7', 'CP1', 'O2', 'FT10', 'Fp2', 'AF3',...
                            'F5', 'FC3', 'C1', 'PO7', 'CPz', 'C2', 'AF8', 'AF4', 'FCz'};
    elseif day          == 2
        flg_trls         = [75, 162];
        flg_chans        = {'Fp1', 'O1', 'Oz', 'F4', 'F8', 'Fp2', 'AF7', 'AF3', ...
                            'C1', 'PO7', 'PO3', 'POz', 'P2', 'CPz', 'TP8', 'C2', ...
                            'F6', 'AF8', 'AF4', 'FCz'};
    elseif day          == 3
        flg_trls         = [114, 187, 361];
        flg_chans        = {'Fp1', 'CP1', 'Pz', 'O1', 'Fp2', 'AF7', 'AF3', 'AFz', ...
                            'F5', 'C1', 'PO3', 'P2', 'CPz', 'C2', 'AF8', 'AF4', 'FCz'};
    end
elseif subjID           == 7
    if day              == 1
        flg_trls         = [12, 28, 66, 81, 82, 121];
        flg_chans        = {'Fp1', 'F7', 'FC1', 'Pz', 'P3', 'O1', 'O2', 'Fp2', ...
                            'AF7', 'AF3', 'P1', 'P5', 'PO3', 'POz', 'PO4', 'PO8', ...
                            'P2', 'C2', 'F6', 'AF4'};
    elseif day          == 2
        flg_trls         = [2, 3, 5, 41, 47, 48, 71, 79];
        flg_chans        = {'Fp1', 'Fz', 'O1', 'Oz', 'O2', 'P4', 'P8', 'F4', 'AF7',...
                            'F1', 'P1', 'P5', 'POz', 'PO4', 'PO8', 'P6', 'P2', 'CP4', 'FCz'};
    elseif day          == 3
        flg_trls         = [45, 76, 81, 82, 118, 120, 121, 189, 199, 240, 279, ...
                            309, 326, 330, 348, 359, 360, 387];
        flg_chans        = {'Fp1', 'FC1', 'Pz', 'Oz', 'O2', 'FT10', 'Fp2', 'AF7', ...
                            'C1', 'PO4', 'CPz', 'C2'};
    end
elseif subjID           == 8
    if day              == 1
        flg_trls         = [50, 218, 232];
        flg_chans        = {'Fp1', 'F3', 'TP10', 'F4', 'Fp2', 'AF7', 'AF3', 'AFz', ...
                            'C1', 'PO4', 'C2', 'FC4', 'F6', 'AF8', 'AF4', 'FCz'};
    elseif day          == 2
        flg_trls         = [1, 11, 12, 13, 14, 15, 46, 200, 309];
        flg_chans        = {'Fp1', 'F3', 'O2', 'CP2', 'Fp2', 'AF7', 'AF3', 'C1', ...
                            'CPz', 'C2', 'FC4', 'AF8', 'AF4', 'FCz'};
    elseif day          == 3
        flg_trls         = [85, 249, 251];
        flg_chans        = {'Fp1', 'F3', 'CP1', 'Oz', 'F4', 'Fp2', 'AF7', 'AF3', ...
                            'F5', 'C1', 'CPz', 'C6', 'C2', 'AF4', 'FCz'};
    end
elseif subjID           == 12
    if day              == 1
        flg_trls         = [22, 57, 98, 369, 370];
        flg_chans        = {'Fp1', 'FT9', 'TP9', 'Pz', 'Oz', 'O2', 'FT10', 'Fp2', ...
                            'C1', 'PO7', 'C2', 'FT8'};
    elseif day          == 2
        flg_trls         = [22, 194, 252, 253, 281, 317];
        flg_chans        = {'Fp1', 'O1', 'Oz', 'TP10', 'Fp2', 'C1', 'PO7', ...
                            'PO3', 'POz', 'PO4', 'C2'};
    elseif day          == 3
        flg_trls         = [1, 33, 280, 321, 343];
        flg_chans        = {'Fp1', 'F7', 'FT9', 'Pz', 'O1', 'Oz', 'O2', 'P8', ...
                            'CP2', 'F4', 'Fp2', 'TP7', 'POz', 'C2'};
    end
elseif subjID           == 13
    if day              == 1
        flg_trls         = [16, 31, 85, 229, 315, 337, 345, 364];
        flg_chans        = {'Fp1', 'T7', 'CP1', 'P3', 'P7', 'O1', 'CP2', 'F8', ...
                            'Fp2', 'AF7', 'AF3', 'AFz', 'C1', 'TP7', 'CP3', 'PO7', ...
                            'PO3', 'POz', 'CPz', 'TP8', 'C2', 'F6', 'AF8', 'AF4', 'FCz'};
    elseif day          == 2
        flg_trls         = [33, 75, 77, 114, 149, 263, 320];
        flg_chans        = {'Fp1', 'F3', 'FT9', 'FC5', 'O1', 'Oz', 'O2', 'C4', ...
                            'Fp2', 'AF3', 'F5', 'C1', 'PO3', 'POz', 'PO4', 'PO8', ...
                            'P2', 'CPz', 'TP8', 'C2', 'FC4', 'FCz'};
    elseif day          == 3
        flg_trls         = [13, 37, 66, 78, 85, 116, 158, 327, 336, 385];
        flg_chans        = {'Fp1', 'F3', 'FT9', 'FC5', 'FC1', 'T7', 'P3', 'O1', ...
                            'Oz', 'O2', 'P8', 'Fp2', 'AF7', 'AF3', 'FC3', 'C1', ...
                            'PO7', 'POz', 'PO4', 'PO8', 'CPz', 'C2', 'AF8', 'AF4', ...
                            'F2', 'FCz'};
    end
elseif subjID           == 14
    if day              == 1
        flg_trls         = [109, 292, 320];
        flg_chans        = {'Fp1', 'F3', 'T7', 'P7', 'O2', 'P4', 'Fp2', 'AF7', ...
                            'F5', 'C1', 'PO7', 'PO4', 'P2', 'CPz', 'TP8', 'C2', ...
                            'F6', 'AF8', 'AF4'};
    elseif day          == 2
        flg_trls         = [155, 190, 194, 197, 255, 256, 257, 259, 263, 266, ...
                            267, 271, 313, 355, 357, 383, 388, 389, 391, 396];
        flg_chans        = {'Fp1', 'FT9', 'Oz', 'P4', 'CP2', 'T8', 'FT10', 'FC6', ...
                            'Fp2', 'AF7', 'AF3', 'FT7', 'C2', 'FT8', 'F6', 'AF8', 'FCz'};
    elseif day          == 3
        flg_trls         = [107, 108, 216, 237, 242, 340, 344, 361];
        flg_chans        = {'Fp1', 'FT9', 'FT10', 'C1', 'PO4', 'CPz', 'CP4', ...
                            'C2', 'FT8', 'FCz'};
    end
elseif subjID           == 15
    if day              == 1
        flg_trls         = [129, 132, 145, 337];
        flg_chans        = {'Fp1', 'FC1', 'Pz', 'P7', 'O1', 'Oz', 'O2', 'Fp2',...
                            'C1', 'POz', 'PO4', 'CPz', 'C2', 'AF8', 'FCz'};
    elseif day          == 2
        flg_trls         = [27, 46, 81, 88, 240, 242, 283, 296, 297, 298];
        flg_chans        = {'Fp1', 'F3', 'F7', 'Pz', 'O1', 'Oz', 'P4', 'FC2',...
                            'Fp2', 'C1', 'P1', 'PO3', 'POz', 'P2', 'TP8', 'AF8'};
    elseif day          == 3
        flg_trls         = [12, 31, 39, 79, 209, 237, 239, 267, 268, 325, 332, 359, 362];
        flg_chans        = {'Fp1', 'Oz', 'O2', 'Fp2', 'FT7', 'C1', 'P1', 'PO3',...
                            'POz', 'PO4', 'P2', 'AF8', 'FCz'};
    end
elseif subjID           == 16
    if day              == 1
        flg_trls         = [1, 2, 3, 42, 174];
        flg_chans        = {'Fp1', 'F7', 'T7', 'Oz', 'F4', 'F8', 'Fp2', 'AF7',...
                            'F5', 'C1', 'TP7', 'POz', 'PO8', 'CPz', 'C2', 'FT8',...
                            'AF8', 'AF4', 'FCz'};
    elseif day          == 2
        flg_trls         = [19, 85, 229];
        flg_chans        = {'Fp1', 'F7', 'Pz', 'O1', 'Oz', 'F8', 'Fp2', 'AF7',...
                            'AFz', 'F5', 'C1', 'POz', 'CPz', 'TP8', 'C2', 'F6',...
                            'AF8', 'AF4', 'FCz'};
    elseif day          == 3
        flg_trls         = [41, 76, 124, 189, 258, 259, 260, 261];
        flg_chans        = {'Fp1', 'F7', 'CP1', 'Oz', 'CP2', 'Fp2', 'AF7', 'AF3',...
                            'F5', 'C1', 'CPz', 'C2', 'AF8', 'AF4', 'FCz'};
    end
elseif subjID           == 17
    if day              == 1
        flg_trls         = [4, 161, 162, 166, 168, 201, 203, 205, 206, 247, 271];
        flg_chans        = {'O1', 'Oz', 'F8', 'Fp2', 'PO3', 'POz', 'F6'};
    elseif day          == 2
        flg_trls         = [9, 28, 198, 322, 352, 361];
        flg_chans        = {'P3', 'O2', 'F8', 'Fp2', 'FT7', 'P1', 'PO3', 'POz', ...
                            'F6', 'AF8'};
    elseif day          == 3
        flg_trls         = [19, 27, 121, 165, 253, 272, 317, 361, 362, 391];
        flg_chans        = {'Fp1', 'FT9', 'O1', 'Oz', 'O2', 'Fp2', 'P1', 'P2'};
    end
elseif subjID           == 18
    if day              == 1
        flg_trls         = [228, 230, 231, 234, 235, 318, 384];
        flg_chans        = {'Fp1', 'F7', 'Pz', 'Oz', 'FT10', 'F8', 'Fp2', 'AF7', ...
                            'AF3', 'AFz', 'F5', 'C1', 'POz', 'PO4', 'C2', 'F6', ...
                            'AF8', 'AF4', 'FCz'};
    elseif day          == 2
        flg_trls         = [1, 2, 3, 78, 280];
        flg_chans        = {'Fp1', 'F3', 'Oz', 'O2', 'Fp2', 'AF7', 'AF3', 'AFz', ...
                            'F5', 'C1', 'PO4', 'PO8', 'CPz', 'C2', 'F6', 'AF8', 'AF4'};
    elseif day          == 3
        flg_trls         = [1, 2, 5, 73, 159, 162];
        flg_chans        = {'Fp1', 'F3', 'F7', 'Pz', 'Oz', 'O2', 'F8', 'Fp2', ...
                            'AF7', 'AF3', 'AFz', 'F1', 'F5', 'PO4', 'P2', 'F6', ...
                            'AF8', 'AF4'};
    end
elseif subjID           == 22 % Trial rejection not done well
    if day              == 1
        flg_trls         = [];
        flg_chans        = {'Fp1', 'Oz', 'Fp2', 'C1', 'PO3', 'POz', 'P2', 'AF8', 'AF4'};
    elseif day          == 2
        flg_trls         = [10, 25, 167, 176, 179, 181, 231, 247, 298];
        flg_chans        = {'Fp1', 'Oz', 'O2', 'TP10', 'Fp2', 'AF7', 'POz', 'PO4', 'P2', 'AF8', 'AF4'};
    elseif day          == 3
        flg_trls         = [31, 32, 69, 358, 376];
        flg_chans        = {'Fp1', 'Oz', 'O2', 'P4', 'Fp2', 'AF7', 'PO4', 'P2', 'AF8', 'AF4'};
    end
elseif subjID           == 23 % Trial rejection not done well
    if day              == 1 % blink artifact very strong, no activity seen except blinks, probably GND too close to eyes?
        flg_trls         = [1, 54, 101, 127, 200];
        flg_chans        = {'Fp1', 'FC5', 'Pz', 'O2', 'Fp2', 'AF7', 'AF3', 'AFz', ...
                            'F5', 'PO4', 'P2', 'CPz', 'C2', 'AF8', 'AF4'};
    elseif day          == 2
        flg_trls         = [5, 6, 7, 8, 9, 10, 18, 27, 28, 42, 89, 121, 122, ...
                            123, 124, 216, 217, 218, 221, 281, 283, 394];
        flg_chans        = {'Fp1', 'Pz', 'O2', 'CP2', 'Fp2', 'AF7', 'AF3', 'AFz', ...
                            'C1', 'PO3', 'PO4', 'P2', 'CPz', 'AF8', 'AF4'};
    elseif day          == 3
        flg_trls         = [97, 101, 137, 141, 161, 179, 208, 210, 211, 214, ...
                            241, 242, 249, 281];
        flg_chans        = {'Fp1', 'Pz', 'O2', 'CP2', 'F8', 'Fp2', 'AF7', 'AF3', ...
                            'AFz', 'C1', 'POz', 'PO4', 'PO8', 'P2', 'CPz', 'C2', 'AF8', 'AF4'};
    end
elseif subjID           == 24
    if day              == 1
        flg_trls         = [166, 247, 256, 274];
        flg_chans        = {'Fp1', 'F7', 'Oz', 'F8', 'Fp2', 'AF7', 'AF3', 'AFz', ...
                            'F5', 'C1', 'POz', 'FC4', 'F6', 'AF8', 'AF4', 'PO4'};
    elseif day          == 2
        flg_trls         = [48, 59, 68,98, 171, 184, 192, 210, 294, 298, 299, ...
                            312, 316, 352, 371, 372, 373, 374, 395];
        flg_chans        = {'Fp1', 'F3', 'F8', 'Fp2', 'AF7', 'AF3', 'AFz', 'F5', ...
                            'C1', 'PO7', 'AF8', 'AF4'};
    elseif day          == 3
        flg_trls         = [4, 5, 6, 34, 151, 194, 200, 201, 202, 211, 368, 373, 382];
        flg_chans        = {'Fp1', 'F7', 'P7', 'P8', 'TP10', 'CP2', 'Fp2', 'AF7', 'AF3', 'C1', 'POz', 'AF8'};
    end
end

end