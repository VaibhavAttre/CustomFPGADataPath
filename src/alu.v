module alu #(

    parameter WIDTH = 8,
    parameter OPWIDTH = 3
)(

    input [WIDTH-1:0] A,
    input [WIDTH-1:0] B,
    input calculate_now,
    input [OPWIDTH-1:0] opcode,
    output reg [WIDTH-1:0]  res,
    output reg zeroflag,
    output reg carryflag
);

always @(*) begin 
    
    if(calculate_now) begin
        case (opcode)
            
            3'b000: {carryflag, res} = A + B;
            3'b001: {carryflag, res} = A - B;
            3'b010: res = 8'b10101010;//A & B;
            3'b011: res = A | B;
            3'b100: res = A ^ B;
            3'b101: res = B;
            3'b110: res = (A == B) ? 8'b1 : 8'b0;
            3'b111: res = 0;
        endcase

        zeroflag = (res == 0);
        if(opcode != 3'b000 && opcode != 3'b001) 
            carryflag = 0;
    end
end

endmodule