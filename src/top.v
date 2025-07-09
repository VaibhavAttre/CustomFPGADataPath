module top (
    input clk,
    input bit_in,
    input rst,
    input store_now,
    output [7:0] led
);

wire [7:0] data_in;
wire input_ready;
wire [7:0] current_shift;
wire [7:0] pc;

program_counter_reg # (

    .WIDTH(8)
) PC (
    .clk(clk),
    .rst(rst),
    .increment(1),
    .pc(pc)
);

input_buffer # (
    .WIDTH(8)
) INBUF (
    
    .clk(clk),
    .rst(rst),
    .bit_in(bit_in),
    .store(store_now),
    .out(data_in),
    .ready(input_ready),
    .current_shift(current_shift)
);



assign led = ~current_shift;

endmodule
