function [flg_trls, flg_chans] = flagged_trls_chans(subjID, day)


if subjID               == 1
    if day              == 1
        flg_trls         = [];
        flg_chans        = {};
    elseif day          == 2
        flg_trls         = [5, 388];
        flg_chans        = {};
    elseif day          == 3
        flg_trls         = [282, 299, 336];
        flg_chans        = {};
    end
elseif subjID           == 3
    if day              == 1 % For this dataset T7, P2 was additionally removed
        flg_trls         = [81, 88, 127, 141, 144, 145, 327, 328, 339, 340];
        flg_chans        = {};
    elseif day          == 2 % For this dataset CP6 was additionally removed
        flg_trls         = [1, 17, 250, 251, 361];
        flg_chans        = {};
    elseif day          == 3
        flg_trls         = [201, 205, 206, 281, 362, 363];
        flg_chans        = {};
    end
elseif subjID           == 5
    if day              == 1
        flg_trls         = [13, 201, 252, 265, 281, 301];
        flg_chans        = {};
    elseif day          == 2
        flg_trls         = [260, 321];
        flg_chans        = {};
    elseif day          == 3
        flg_trls         = [];
        flg_chans        = {};
    end
elseif subjID           == 6
    if day              == 1
        flg_trls         = [83];
        flg_chans        = {};
    elseif day          == 2
        flg_trls         = [128, 164, 210, 249];
        flg_chans        = {};
    elseif day          == 3
        flg_trls         = [60, 114, 187, 361];
        flg_chans        = {};
    end
elseif subjID           == 7
    if day              == 1
        flg_trls         = [28, 41, 81, 82, 121, 228];
        flg_chans        = {};
    elseif day          == 2
        flg_trls         = [41, 45, 47, 212, 248, 249];
        flg_chans        = {};
    elseif day          == 3
        flg_trls         = [76, 81, 118, 120, 189, 348, 359, 360];
        flg_chans        = {};
    end
elseif subjID           == 8
    if day              == 1
        flg_trls         = [];
        flg_chans        = {};
    elseif day          == 2
        flg_trls         = [];
        flg_chans        = {};
    elseif day          == 3
        flg_trls         = [];
        flg_chans        = {};
    end
elseif subjID           == 10
    if day              == 1
        flg_trls         = [];
        flg_chans        = {};
    elseif day          == 2
        flg_trls         = [];
        flg_chans        = {};
    elseif day          == 3
        flg_trls         = [];
        flg_chans        = {};
    end
elseif subjID           == 11
    if day              == 1
        flg_trls         = [];
        flg_chans        = {};
    elseif day          == 2
        flg_trls         = [];
        flg_chans        = {};
    elseif day          == 3
        flg_trls         = [];
        flg_chans        = {};
    end
elseif subjID           == 12
    if day              == 1
        flg_trls         = [22, 57, 69, 369, 370];
        flg_chans        = {};
    elseif day          == 2
        flg_trls         = [22, 194, 252, 345];
        flg_chans        = {};
    elseif day          == 3
        flg_trls         = [34 322];
        flg_chans        = {};
    end
elseif subjID           == 13
    if day              == 1
        flg_trls         = [];
        flg_chans        = {};
    elseif day          == 2
        flg_trls         = [];
        flg_chans        = {};
    elseif day          == 3
        flg_trls         = [];
        flg_chans        = {};
    end
elseif subjID           == 14
    if day              == 1
        flg_trls         = [320];
        flg_chans        = {};
    elseif day          == 2
        flg_trls         = [158, 197, 269, 274, 339, 354, 386, 394, 399];
        flg_chans        = {};
    elseif day          == 3
        flg_trls         = [107, 237, 242, 344];
        flg_chans        = {};
    end
elseif subjID           == 15
    if day              == 1
        flg_trls         = [122, 147, 321, 338, 339, 355, 379];
        flg_chans        = {};
    elseif day          == 2
        flg_trls         = [28, 31, 82, 118, 171, 241, 299];
        flg_chans        = {};
    elseif day          == 3
        flg_trls         = [33, 41, 192, 211, 239, 241, 269, 270, 361, 364];
        flg_chans        = {};
    end
elseif subjID           == 16
    if day              == 1
        flg_trls         = [1, 3];
        flg_chans        = {};
    elseif day          == 2
        flg_trls         = [230, 231];
        flg_chans        = {};
    elseif day          == 3
        flg_trls         = [41, 68, 124, 189, 190, 259, 260, 261];
        flg_chans        = {};
    end
elseif subjID           == 17
    if day              == 1
        flg_trls         = [168, 201, 206];
        flg_chans        = {};
    elseif day          == 2
        flg_trls         = [322];
        flg_chans        = {};
    elseif day          == 3
        flg_trls         = [164, 212, 361, 388, 389, 396];
        flg_chans        = {};
    end
elseif subjID           == 18
    if day              == 1
        flg_trls         = [];
        flg_chans        = {};
    elseif day          == 2
        flg_trls         = [];
        flg_chans        = {};
    elseif day          == 3
        flg_trls         = [];
        flg_chans        = {};
    end
elseif subjID           == 22
    if day              == 1
        flg_trls         = [36, 275];
        flg_chans        = {};
    elseif day          == 2
        flg_trls         = [10, 183, 300, 321];
        flg_chans        = {};
    elseif day          == 3
        flg_trls         = [31, 32, 358, 376];
        flg_chans        = {};
    end
elseif subjID           == 23
    if day              == 1
        flg_trls         = [1, 35, 128, 201, 302];
        flg_chans        = {};
    elseif day          == 2
        flg_trls         = [6, 7, 9, 10, 18, 27, 28, 42, 89, 121, 216, 217, 219, 221, 281, 282, 330];
        flg_chans        = {};
    elseif day          == 3
        flg_trls         = [161, 179, 208, 210, 211, 233, 241, 281];
        flg_chans        = {};
    end
elseif subjID           == 24
    if day              == 1
        flg_trls         = [4, 5, 216, 217];
        flg_chans        = {};
    elseif day          == 2
        flg_trls         = [169, 187, 188, 189, 191, 193, 201, 213, 234, 279, 348, 356, 361];
        flg_chans        = {};
    elseif day          == 3
        flg_trls         = [85, 105, 187, 282, 283, 297, 320, 321, 322];
        flg_chans        = {};
    end
elseif subjID           == 25
    if day              == 1
        flg_trls         = [];
        flg_chans        = {};
    elseif day          == 2
        flg_trls         = [];
        flg_chans        = {};
    elseif day          == 3
        flg_trls         = [];
        flg_chans        = {};
    end
elseif subjID           == 26
    if day              == 1
        flg_trls         = [];
        flg_chans        = {};
    elseif day          == 2
        flg_trls         = [63, 66];
        flg_chans        = {};
    elseif day          == 3
        flg_trls         = [25, 217, 241];
        flg_chans        = {};
    end
elseif subjID           == 27
    if day              == 1
        flg_trls         = [198];
        flg_chans        = {};
    elseif day          == 2
        flg_trls         = [];
        flg_chans        = {};
    elseif day          == 3
        flg_trls         = [];
        flg_chans        = {};
    end

end
