module keypad_interpreter(
input  Clock, 
input  ResetButton,
input  KeyRead, 			
input  [3:0] RowDataIn,
output KeyReady,			
output [3:0] DataOut,
output [3:0] ColDataOut,
output [3:0] PressCount
);


wire [3:0] KeyCode;
wire LFSRRst;
wire LFSRFlg;

LFSR LFSR (Clock, LFSRRst, LFSRFlg);
keypad_reader Scanner (ResetButton, Clock, RowDataIn, ColDataOut, LFSRRst, LFSRFlg, KeyCode, KeyReady, KeyRead);
pulse_counter Count (ResetButton, Clock, KeyReady, PressCount);
keypad_decode Decoder (KeyCode , DataOut);


endmodule