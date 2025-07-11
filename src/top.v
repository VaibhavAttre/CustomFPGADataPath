module top #(
    parameter WIDTH = 8
)(
    input clk,
    input bit_in,
    input choose_display,
    input rst,
    input store_now,
    output [WIDTH-1:0] led
);

wire [WIDTH-1:0] data_in;
wire [WIDTH-1:0] current_shift;
wire [WIDTH-1:0] pc;
wire [WIDTH-1:0] regA;
wire [WIDTH-1:0] regB;

wire input_ready;   
wire loadA = input_ready & ~choose_display;
wire loadB = input_ready &  choose_display;

assign led = choose_display ? ~regB : ~regA;

program_counter_reg # (

    .WIDTH(WIDTH)
) PC (
    .clk(clk),
    .rst(rst),
    .increment(1),
    .pc(pc)
);

input_buffer # (
    .WIDTH(WIDTH)
) INBUF (
    
    .clk(clk),
    .rst(rst),
    .bit_in(bit_in),
    .store(store_now),
    .out(data_in),
    .ready(input_ready),
    .current_shift(current_shift)
);

register_file # (

    .WIDTH(WIDTH)
) REGFILE (
    .clk(clk),
    .rst(rst),
    .loadA(loadA),
    .loadB(loadB),
    .data_in(data_in),
    .A(regA),
    .B(regB)
);

endmodule
