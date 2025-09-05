module top #(
    parameter WIDTH = 8,
    parameter ADDR_S = 3,
    parameter OP_S = 3
)(
    input clk,
    input choose_display,
    input store_addr_now,
    input rst,
    input store_now,
    input opcode_vs_data,
    output [3:0] rows,
    input [3:0] cols,
    output [WIDTH-1:0] led
);

wire [WIDTH-1:0] data_in;
wire [ADDR_S-1:0] addr_in;
wire [OP_S-1:0] alu_in;
wire [OP_S-1:0] alu_opcode_in;
wire input_ready;   
wire data_ready;
wire [WIDTH-1:0] regA;
wire [WIDTH-1:0] regB;
wire [WIDTH-1:0] mem_out;


wire key_ready;
wire [3:0] key_data;
wire [3:0] press_count;


keypad_interpreter interpreter (
    .Clock(clk),
    .ResetButton(rst),  
    .KeyRead(1'b1),      
    .RowDataIn(cols),    
    .KeyReady(key_ready),
    .DataOut(key_data),
    .ColDataOut(rows),   
    .PressCount(press_count)
);

wire loadA = input_ready & ~choose_display;
wire loadB = input_ready & choose_display;

wire store_signal = (key_data == 4'b0101); //5 keypad
wire wr_en = (key_data == 4'b1010);
wire calculate_now = (key_data == 4'b0110); //8 keypad
wire rd_en = (key_data == 4'b0011); //7 kypd
wire disp_addr_mode = (key_data == 4'b0111);  //3 keypad
wire disp_data_mode = (key_data == 4'b1000);  //6 keypad
wire disp_op_mode = (key_data == 4'b1100); //# keypad
reg disp_addr, disp_data, disp_op;

wire bit_in = (key_data == 1) ? 1 : 0;

wire store_data_now = (store_now & ~opcode_vs_data);
wire store_opcode_now = (store_now & opcode_vs_data);

reg [WIDTH-1:0] mem_out_reg;
reg [WIDTH-1:0] disp_reg;


reg showing_address;
reg showing_data;
reg showing_op;

always @(posedge clk) begin

  if (key_ready) begin
    if (disp_addr_mode) begin
        showing_address <= 1'b1;
        showing_data <= 1'b0;
        showing_op <= 1'b0;
    end else if (disp_op_mode) begin
        showing_address <= 1'b0;
        showing_data <= 1'b0;
        showing_op <= 1'b1;
    end else if (disp_data_mode || rd_en) begin
        showing_address <= 1'b0;
        showing_data <= 1'b1;
        showing_op <= 1'b0;
    end
  end

  // 2) choose what to display
    if (showing_address)
        disp_reg <= { {WIDTH-ADDR_S{1'b0}}, addr_in };
    else if (showing_data)
        disp_reg <= (choose_display ? regB : regA);
    else if (showing_op)
        disp_reg <= { {WIDTH-OP_S{1'b0}}, alu_opcode_in};
  // else: hold last value
end


assign led = choose_display ? ~disp_reg : ~alu_in;//~disp_reg;//choose_display ? ~disp_reg : ~(alu_opcode_in == 3'b010);//~disp_reg;



/*
program_counter_reg # (

    .WIDTH(WIDTH)
) PC (
    .clk(clk),
    .rst(rst),
    .increment(1),
    .pc(pc)
);
*/


input_buffer # (
    .WIDTH(WIDTH)
) DATABUF (
    
    .clk(clk),
    .rst(rst),
    .bit_in(bit_in),
    .store(store_data_now),
    .out(data_in),
    .ready(input_ready),
    .current_shift()
);

input_buffer # (
    .WIDTH(ADDR_S)
) ADDRBUF (
    
    .clk(clk),
    .rst(rst),
    .bit_in(bit_in),
    .store(store_addr_now),
    .out(addr_in),
    .ready(),
    .current_shift()
);

input_buffer # (
    .WIDTH(3)
) OPCODEBUF (
    
    .clk(clk),
    .rst(rst),
    .bit_in(bit_in),
    .store(store_opcode_now),
    .out(alu_opcode_in),
    .ready(),
    .current_shift()
);

register_file # (

    .WIDTH(WIDTH)
) REGFILE (
    .clk(clk),
    .rst(rst),
    .loadA(loadA),
    .loadB(loadB | rd_en),
    .data_in(rd_en ? mem_out : data_in),
    .A(regA),
    .B(regB)
);


memory_bank # ( 
    
    .WIDTH(WIDTH),
    .REGS(1 << ADDR_S),
    .ADDR_S(ADDR_S)
) MEMBANK (
    
    .clk(clk),
    .rst(rst),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .addr(addr_in),
    .d_in(alu_in),
    .d_out(mem_out) 
);

alu # (

    .WIDTH(WIDTH),
    .OPWIDTH(OP_S)
) ALU (
    
    .A(regA),
    .B(regB),
    .calculate_now(calculate_now),
    .opcode(alu_opcode_in),
    .res(alu_in),
    .zeroflag(),
    .carryflag()
);

endmodule
