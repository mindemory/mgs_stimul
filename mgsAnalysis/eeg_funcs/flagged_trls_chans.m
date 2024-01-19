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
        flg_trls         = [];
        flg_chans        = {};
    end
elseif subjID           == 15
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
elseif subjID           == 16
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
elseif subjID           == 17
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
        flg_trls         = [];
        flg_chans        = {};
    elseif day          == 2
        flg_trls         = [];
        flg_chans        = {};
    elseif day          == 3
        flg_trls         = [];
        flg_chans        = {};
    end
elseif subjID           == 23
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
elseif subjID           == 24
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
        flg_trls         = [];
        flg_chans        = {};
    elseif day          == 3
        flg_trls         = [];
        flg_chans        = {};
    end
elseif subjID           == 27
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

end
