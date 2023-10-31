function [flg_trls, flg_chans] = flagged_trls_chans(subjID, day)


if subjID               == 1
    if day              == 1
        flg_trls         = [37 56 57 66 69 239 240 308 309 366];
        flg_chans        = {};
    elseif day          == 2
        flg_trls         = [3 4 21 79 92 119 149 179 199 224 232 239 249 ...
                            250 262 337];
        flg_chans        = {'Fp1', 'Oz', 'Fp2', 'AF7', 'F6', 'AF8', 'AF4'};
    elseif day          == 3
        flg_trls         = [1 34 42 80 81 118 129 144 145 208 217 222 227 ...
                            280 295 297 313 333];
        flg_chans        = {'Oz', 'POz'};
    end
elseif subjID           == 3 % Trial rejection not done well
    if day              == 1
        flg_trls         = [41 138 139 141 142 161 228 241 321 340 397];
        flg_chans        = {'Pz', 'F1', 'CP1', 'FC2', 'Fz', 'CPz', 'T7', 'P2', ...
                            'AFz', 'FT10', 'Fp1', 'Fp2', 'POz', 'PO4'};
    elseif day          == 2
        flg_trls         = [116 250 251 252];
        flg_chans        = {'FC1', 'CP6', 'Fp1', 'Fp2', 'AFz', 'AF4', 'O2'};
    elseif day          == 3
        flg_trls         = [25 143 144 200 202 204 205 280 320 360 361 362];
        flg_chans        = {'PO4'};
    end
elseif subjID           == 5
    if day              == 1
        flg_trls         = [13 117 118 121 140 141 195 201 252 281 301];
        flg_chans        = {'O1', 'P3', 'P1', 'PO4'};
    elseif day          == 2
        flg_trls         = [12 27 81 85 256 257 258 290 319];
        flg_chans        = {'P1'};
    elseif day          == 3
        flg_trls         = [18 185 201 218 263 264 379 380];
        flg_chans        = {'PO3', 'O1', 'P1'};
    end
elseif subjID           == 6
    if day              == 1
        flg_trls         = [1 81 82 83 120 121 173 230];
        flg_chans        = {'PO7', 'PO4', 'P2', 'O2'};
    elseif day          == 2
        flg_trls         = [75 119 126 127 128 129 162 199 200 201 208 209 ...
                            210 211 239 240 241 279 316];
        flg_chans        = {'O1'};
    elseif day          == 3
        flg_trls         = [40 43 50 67 114 115 116 117 121 122 123 124 125 ...
                            126 127 128 129 130 131 132 241 242 261 262 263 264 ...
                            314 315 316 352 353 354 355 356 357 358 359 360 361 ...
                            362 363];
        flg_chans        = {};
    end
elseif subjID           == 7
    if day              == 1
        flg_trls         = [1 41 63 66 69 81 82 112 228 240 417];
        flg_chans        = {'FC1', 'P2', 'P3', 'P1'};
    elseif day          == 2
        flg_trls         = [2 3 4 5 41 208 209 210 211 212 248 249];
        flg_chans        = {'O1', 'P4', 'P8', 'P6', 'P2', 'P1', 'P5', 'PO4', 'PO8'};
    elseif day          == 3
        flg_trls         = [1 2 44 76 80 81 82 83 118 119 120 121 160 161 162 163 ...
                            189 199 222 240 241 263 268 279 290 308 309 326 348 ...
                            359 360 387];
        flg_chans        = {'FC1', 'CPz', 'Fp1', 'Fp2', 'AF7', 'AF4'};
    end
elseif subjID           == 8
    if day              == 1
        flg_trls         = [1 201 218 232 286];
        flg_chans        = {'Fp1', 'Fp2', 'F3', 'AF8', 'PO4'};
    elseif day          == 2
        flg_trls         = [1 10 11 12 13 14 15 20 46 200 235 291 292 ...
                            307 343];
        flg_chans        = {'Fp1', 'Fp2', 'F3', 'FC5', 'O2', 'PO4'};
    elseif day          == 3
        flg_trls         = [1 31 80 85 108 109 141 142 143 167 206 223 230 231 ...
                            249 250 251 252 314 318 325 356 384 388 394];
        flg_chans        = {'CP1'};
    end
elseif subjID           == 10
    if day              == 1
        flg_trls         = [2 80 112 159 280 281 326 327];
        flg_chans        = {'Fp1', 'Fp2', 'POz','PO8', 'AF4', ...
                            'AF8', 'O2'};
    elseif day          == 2
        flg_trls         = [];
        flg_chans        = {};
    elseif day          == 3
        flg_trls         = [];
        flg_chans        = {};
    end
elseif subjID           == 11
    if day              == 1
        flg_trls         = [42 43 48 61 64 65 66 78 79 92 114 115 116 117 ...
                            118 119 120 134 135 162 175 180 182 197 198 199 ...
                            200 201 202 208 215 216 219 221 222 228 229 237 ...
                            253 262 277 278 279 280 281 282 283 284 285 286 287 ...
                            289 291 294  315 317 329 356 357 358 359 363 364 377 ...
                            378 379 380 385 388 390 391];
        flg_chans        = {'PO4', 'P6', 'C2', 'F2', 'TP8', 'CP2', 'FC6', ...
                            'Fp1', 'FC4', 'P1'};
    elseif day          == 2
        flg_trls         = [14 40 94 96 106 137 138 158 160 164 193 229 230 ...
                            243 244 264 316 322 323 330 384 385 389 390 396];
        flg_chans        = {'Fz', 'Fp1', 'FC1', 'O1', 'Oz', 'Fp2', 'F3', 'F4', ...
                            'AF3', 'PO3', 'PO7'};
    elseif day          == 3
        flg_trls         = [16 36 40 68 80 81 104 135 158 160 184 185 194 197 ...
                            198 199 215 216 223 257 264 265 278 281 287 288 ...
                            291 292 296 299 304 306 315 319 320 321 372];
        flg_chans        = {'F3', 'Fp2', 'F5', 'AF8', 'Fp1', 'AF7', 'AF4', 'O1', ...
                            'PO3', 'PO4'};
    end
elseif subjID           == 12
    if day              == 1
        flg_trls         = [22 57 98 143 328 370 371];
        flg_chans        = {'C1', 'PO7', 'Oz', 'FT8', 'Fp1', ...
                            'Fp2', 'O2'}; % 'FT9', 'FT10'
    elseif day          == 2
        flg_trls         = [10 134 135 194 252 253 268 281 308];
        flg_chans        = {'O1', 'PO7', 'C1', 'PO3', 'Oz', 'POz', 'PO4'};
    elseif day          == 3
        flg_trls         = [1 33 34 35 38 39 40 64 75 90 148 162 170 216 ...
                            247 262 280 281 300 301 309 331 343 391 ];
        flg_chans        = {'O1',  'CP2', 'TP7', 'O2', 'P8', 'F7', 'Pz', ...
                            'POz', 'Oz'}; %'FT9',
    end
elseif subjID           == 13
    if day              == 1
        flg_trls         = [69 85 161 234 337 366];
        flg_chans        = {'POz', 'CP2', 'CP1', 'P3', 'P7', 'PO7', 'TP7', ...
                            'CP3', 'CPz', 'TP8', 'PO3', 'O1', 'Fp1', 'Fp2', 'T7'};
    elseif day          == 2
        flg_trls         = [2 71 74 75 77 100 111 149 150 170 211 230 236 262 ...
                            263 264 270 271 274 303 304 305 306 307 308 309 310 ...
                            311 312 317 318 319 320 321 326 327 328];
        flg_chans        = {'Oz', 'O1', 'O2', 'PO4', 'PO8', 'F3', 'C4', ...
                            'CPz', 'PO3', 'POz', 'TP8', 'FC4', 'FC5', 'T8'}; %'FT9', 
    elseif day          == 3
        flg_trls         = [42 43 80 85 117 123 136 140 149 170 180 186 215 230 ...
                            238 247 253 273 284 299 308 318 330 335 336 337 338 ...
                            369 393 395];
        flg_chans        = {'O2', 'PO4', 'Oz', 'O1', 'PO7', 'POz', 'PO8', 'P3', 'PO3', 'P8'};
    end
elseif subjID           == 14
    if day              == 1
        flg_trls         = [75 106 116 119 137 186 188 212 226 292 381];
        flg_chans        = {'T7', 'AF4', 'TP8', 'Fp1', 'Fp2', 'P2', 'PO4', ...
                            'O2', 'PO8', 'P4'};
    elseif day          == 2
        flg_trls         = [30 31 36 37 78 80 81 169 170 171 181 190 194 196 197 ...
                            224 242 243 266 267 268 270 271 272 273 279 309 318 ...
                            353 357 358 383 388 391 394 395];
        flg_chans        = {'Fp1', 'Fp2', 'CP2', 'AF8', 'P2', 'P4', 'PO4', 'PO8'}; %'FT9', 
    elseif day          == 3
        flg_trls         = [37 72 106 107 108 109 159 238 239 304 306 307 340 344 361];
        flg_chans        = {'PO4', 'FT8', 'Fp1', 'P5'}; % 'FT9', 'FT10', 
    end
elseif subjID           == 15
    if day              == 1
        flg_trls         = [2 42 75 79 80 119 120 136 139 150 161 163 164 165 ...
                            199 200 201 202 203 204 218 232 233 234 237 242 ...
                            261 263 266 271 293 318 319 320 321 322 323 324 325 ...
                            333 334 335 336 337 338 343 345 346 349 351 352 353 ...
                            354 359 360 369 370 371 376 377 378];
        flg_chans        = {'FC1', 'CPz', 'Oz', 'Fp1', 'POz', 'PO4'};
    elseif day          == 2
        flg_trls         = [21 26 27 28 29 30 31 32 73 80 81 85 86 100 117 121 ...
                            131 132 138 150 160 161 170 200 201 223 261 275 ...
                            283 296 297 298 299 300 320];
        flg_chans        = {'Oz', 'FC2', 'TP8', 'Pz', 'FT8', 'F3', 'P1', 'P2'};
    elseif day          == 3
        flg_trls         = [39 48 49 79 159 190 191 252 267 268 279 301 327 359 362 ...
                            373 379 395];
        flg_chans        = {'Oz', 'PO4', 'Fp1', 'FT7', 'O2', 'P2', 'PO4'}; % 'FT10', 
    end
elseif subjID           == 16
    if day              == 1
        flg_trls         = [1 134 189 203 255 321 323 379 380 381 388 398];
        flg_chans        = {'Fp1', 'Oz', 'Pz', 'PO8', 'Pz', 'T7', 'F7', 'P3', ...
                            'O1', 'Fp2', 'AF3', 'AF7', 'AFz', 'FT7', 'P1', ...
                            'POz', 'AF8', 'FT8', 'AF4'};
    elseif day          == 2
        flg_trls         = [4 13 19 20 21 62 78 80 81 82 83 84 85 87 88 89 ...
                            140 144 166 175 199 248 249 276 297 298 300 321 ...
                            322 323 333 334 335 336 391 392];
        flg_chans        = {'Fp1', 'Fp2', 'AF8', 'Pz', 'F7', 'O1', 'Oz', 'TP8', ...
                            'P3', 'P1'};
    elseif day          == 3
        flg_trls         = [10 13 18 41 42 118 124 189 190 251 259 260 261 ...
                            275 311 336 342];
        flg_chans        = {'Fp1', 'Fp2', 'AF8', 'AF4', 'P1', 'P3'};
    end
elseif subjID           == 17
    if day              == 1
        flg_trls         = [14 40 161 162 163 164 165 166 167 168 169 201 202 203 ...
                            205 206 207 271];
        flg_chans        = {'Pz', 'Fp2', 'POz', 'Fp1', 'O1', 'PO3'};
    elseif day          == 2
        flg_trls         = [9 10 53 91 153 161 168 169];
        flg_chans        = {'Oz', 'O2', 'POz', 'P3', 'Fp2', 'P1', 'PO3'};
    elseif day          == 3
        flg_trls         = [1 41 70 83 121 154 164 165 272 311 312 361 362];
        flg_chans        = {'P1', 'Fp1', 'Fp2', 'Pz', 'O1', 'AF7', 'PO3', 'POz', ...
                            'AF8', 'AF4'};
    end
elseif subjID           == 18 % very strong blink artifacts
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
elseif subjID           == 22 % Trial rejection not done well
    if day              == 1
        flg_trls         = [27 28 97];
        flg_chans        = {'Oz', 'POz', 'P2', 'Pz', 'Fp1', 'Fp2'};
    elseif day          == 2
        flg_trls         = [1 2 10 17 18 21 31 55 171 175 176 180 181 212 213 ...
                            343 344 345 346];
        flg_chans        = {'O2', 'PO4', 'Fp1', 'Fp2', 'Oz', 'POz', 'P2'};
    elseif day          == 3
        flg_trls         = [31 32];
        flg_chans        = {'P2', 'O2', 'PO4', 'P4'}; % 'FT10', 
    end
elseif subjID           == 23 % Not included for now
    if day              == 1 % blink artifact very strong, no activity seen except blinks, probably GND too close to eyes?
        flg_trls         = [6 7 9 191 222 237 238 317];
        flg_chans        = {'O2', 'PO4', 'P2'};
    elseif day          == 2
        flg_trls         = [];
        flg_chans        = {};
    elseif day          == 3
        flg_trls         = [];
        flg_chans        = {};
    end
elseif subjID           == 24
    if day              == 1
        flg_trls         = [8 70 274 275];
        flg_chans        = {'Oz', 'POz'};
    elseif day          == 2
        flg_trls         = [];
        flg_chans        = {'F3', 'PO7'};
    elseif day          == 3
        flg_trls         = [4 5 6 29 40 41 ];
        flg_chans        = {'CP2', 'POz', 'P7'};
    end
elseif subjID           == 25
    if day              == 1
        flg_trls         = [48 52 60 77 78 90 102 108 137 147 148 211 222 223 ...
                            261 277 299 309 310 327 328 329 330 331 342 357 ...
                            373 382 397];
        flg_chans        = {'Fp1', 'Fp2', 'P2', 'FCz', 'PO4', 'O2'};
    elseif day          == 2
        flg_trls         = [3 92 99 104 160 165 166 199 200 204 205 212 220 221 ...
                            228 229 230 231 232 233 234 243 244 247 248 251 261 ...
                            262 278 289 290 294 297 300 301 313 314 315 319 323 ...
                            329 330 337 338 339 340 341 342 345 347 348 352 353 ...
                            354 358 362 366 367 391 395 399];
        flg_chans        = {'PO7', 'Pz', 'Fp1', 'O1', 'Oz', 'T8', 'F4', 'Fp2', ...
                            'P1', 'PO3', 'POz', 'F6', 'AF4', 'AF8'};
    elseif day          == 3
        flg_trls         = [68 74 81 105 109 110 111 126 127 128 134 154 155 ...
                            156 180 181 199 200 237 241 242  267 268 272 276 ...
                            284 290 297 304 305 306 310 311 312 315 319 320 ...
                            321 322 323 324 325 326 328 336 346 350 351 358 ...
                            359 373 374];
        flg_chans        = {'FT9', 'POz', 'Fp1', 'Fp2', 'Pz', 'P2'};
    end
elseif subjID           == 26
    if day              == 1
        flg_trls         = [59 115 145 162 264 327 330 331 332 333 337 338 ...
                            341 342 343 353 363 387];
        flg_chans        = {'FC2', 'Oz', 'P1', 'Fp1', 'Fp2', 'FC4', 'F6', 'AF8', 'AF4'};
    elseif day          == 2 % Very strong muscle/blink artifacts, definitely need ICA for this one 
                            % (why did this happen?: Maybe don't put ground too low and exactly at centre on the bone)
        flg_trls         = [15 29 30 33 34 39 40 41 42 43 44 45 48 49 50 51 ...
                            56 57 58 62 63 68 79 98 99 100 111 112 158 159 ...
                            167 176 178 182 224 263 282 283 284 337];
        flg_chans        = {'FC1', 'F1', 'Fp1', 'Fp2', 'O1', 'FC6', 'P1', 'POz', ...
                            'AF8', 'P1', 'P3'};
    elseif day          == 3
        flg_trls         = [];
        flg_chans        = {};
    end
elseif subjID           == 27
    if day              == 1
        flg_trls         = [32 118 121 172 177 189 197 276 298 371];
        flg_chans        = {'FT10', 'CP5', 'Pz', 'POz', 'Fp1', 'Fp2', 'Oz', ...
                            'O2', 'AF4'};
    elseif day          == 2
        flg_trls         = [19 39 65 66 94 133 135 136 137 138 161 162 165 ...
                            166 169 170 171 172 213 214 241 242 262 263 264 ...
                            302 303];
        flg_chans        = {'PO8', 'P1', 'CPz', 'Fp1', 'P3', 'P5'};
    elseif day          == 3
        flg_trls         = [33 38 73 74 75 76 77 78 79 100 108 118 119 127 ...
                            144 156 191 198 199 238 239 285 311 312 318 319 ...
                            320 366];
        flg_chans        = {'CP1', 'Oz', 'Fp1', 'O2', 'P2', 'PO4', 'P1'};
    end
end


end
