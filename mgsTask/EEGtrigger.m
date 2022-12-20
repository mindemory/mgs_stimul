TB = IOPort('OpenSerialPort', '/dev/ttyUSB1');
Available = IOPort('BytesAvailable', TB)
if(Available>0)
    disp(IOPort('Read'), TB, 0, Available);
end
IOPort('Write', TB, uint8(0), 0);
Available = IOPort('BytesAvailable', TB)

IOPort('Write', TB, uint8(1), 0);
Available = IOPort('BytesAvailable', TB)

IOPort('Write', TB, uint8(0), 0);
Available = IOPort('BytesAvailable', TB)
IOPort('Write', TB, uint8(255), 0);
Available = IOPort('BytesAvailable', TB)
IOPort('Write', TB, uint8(1), 0);
Available = IOPort('BytesAvailable', TB)
IOPort('Close', TB);

%%
SerialPortObj=serial('/dev/ttyUSB2', 'TimeOut', 1); % in this example x=4
SerialPortObj.BytesAvailableFcnMode='byte';
SerialPortObj.BytesAvailableFcnCount=1;
SerialPortObj.BytesAvailableFcn=@ReadCallback;
% To connect the serial port object with serial port hardware
fopen(SerialPortObj);
% Set the port to zero state 0
fwrite(SerialPortObj, 0,'sync');
pause(0.01);
% Set Bit 0 (Pin 2 of the Output(to Amp) connector)
fwrite(SerialPortObj, 1,'sync');
pause(0.01);

% Reset the port to zero state 0
fwrite(SerialPortObj, 0,'sync');
pause(0.01);
% Reset the port (i.e. bit 0 to 7) to its resting state 255
fwrite(SerialPortObj, 255,'sync');
pause(0.01);
% Then disconnect/close the serial port object from the serial port
fclose(SerialPortObj);
% Remove the serial port object from memory
delete(SerialPortObj);
% Remove the serial port object from the MATLAB® workspace
clear SerialPortObj;
%%
% Read callback function
function ReadCallback(src, event)
 %disp(event.Type);
 if(src.BytesAvailable > 0)
 disp(fread(src, src.BytesAvailable));
 end
end