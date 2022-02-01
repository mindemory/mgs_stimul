% The Teensy trigger project
% Copyright (c) 2014-2018 Yong-Jun Lin.
% MEX C code version: 2018-01-16
% MEX help file version: 2018-02-06
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, version 3.
%
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
% General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program. If not, see <http://www.gnu.org/licenses/>.
%
%  The Teensy trigger device ("device" in the following text) is built for
%  triggering TMS pulses and/or generating EEG events with high temporal
%  precision (mean and variance of delay is about 0.2 ms and <~0.01 ms
%  benchmarked by measuring serial communication round trip time with both
%  C and Python). The device receives 1 byte input (0~255) from the stimuli
%  presentation computer and translates that into parallel 8 bit electric
%  signals. With an extra ground pin, it supports 8-bit event outputs to
%  EEG systems such as Brain Products (TM) or BioSemi (TM) with a
%  custom-made 9-pin header to DB-25 parallel port adaptor. When used to
%  trigger a TMS system, only 1 signal pin and 1 ground pin are required.
%  When used in a TMS-EEG combined case, 1 signal pin (usually the 2^7 pin,
%  not the 2^0 pin) is simultaneously used as the TMS triggering and the
%  EEG event generating pin.
%
%  Do NOT use MATLAB's built-in serial communication commands such as
%  fopen(), fprintf(), and fclose() because they introduce large and
%  random communucation delay (4~8 ms) possibly because they are
%  Java-based. Accordingly, use the provided MEX file written in C and
%  compiled to be used by MATLAB. The TeensyTrigger.mexmaci and the
%  TeensyTrigger.mexmaci64 are for 32- and 64-bit MATLAB environments,
%  respectively. You can include both in MATLAB search path and MATLAB will
%  determine which to use. MEX files for Windows PC environment will be
%  provided in the future.
%
%  Turn the device on by connecting it to the stimuli presentation computer
%  with a USB mini B to USB type A cable. When the power is on, the orange
%  LED on the Teensy microcontroller board lights up, indicating that it is
%  waiting for handshake. After successful handshake, the LED goes off.
%  From then on, the user can send values ranging from 0~255 at anytime.
%  Note that in most EEG and TMS systems, 0 is the default off value. As a
%  result, only 1~255 are considered as signals by these systems.
%
%   TeensyTrigger('i', '/dev/cu.usbmodem12341) initializes serial
%   communication and handshakes with the device. This is required before
%   executing any of the following three sub-commands ('t', 's', and 'x').
%
%    If MATLAB hangs for more than 2 seconds, it means that the device is
%    not in a state waiting for handshakes. Make sure that the demo mode
%    switch is OFF and press the black reset button on the breadboard (not
%    the white button on the Teensy microcontroller board). The second
%    parameter is the default path for Teensy microcontroller boards on
%    Linux and MacOS X. In Windows, find out the port on your own (COMx).
%
%   TeensyTrigger('s', bTTL, TTLPulseWidth) modifies the device settings.
%    bTTL: true (1) or false (0)--whether to send the signals by TTL
%    modulation, meaning that the output value goes back to 0 after a
%    certain duration.
%    TTLPulseWidth: duration of the TTL pulse (latency between rising and
%    falling edges) in microseconds. The default value is 1000. If bTTL ==
%    false, this value will be ignored.
%
%	 If the user does not wish to modify the default settings, just skip
%	 playing with this subcommand.
%
%   TeensyTrigger('t', val) sends a trigger/event value ranging from 0 to
%   255.
%
%   TeensyTrigger('x') shuts down the serial communication and resets the
%   device, so that the device will be waiting for handshake again.
%
%    Without executing this sub-command, the user has to press the black
%    button to reset the device manually.
%
% For example,
%  (at the beginning of your script)
%  TeensyTrigger('i', '/dev/cu.usbmodem12341)
%  TeensyTrigger('s', true, 1000)
%
%  (in the middle of your script)
%  TeensyTrigger('t', 20) % Onset of stimulus A
%  TeensyTrigger('t', 30) % Onset of stimulus B
%  TeensyTrigger('t', 20+128) % Onset of stimulus A + TMS
%  TeensyTrigger('t', 30+128) % Onset of stimulus B + TMS
%
%  (at the end of your script)
%  TeensyTrigger('x')
