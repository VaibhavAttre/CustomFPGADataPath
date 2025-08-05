module top #(
    parameter WIDTH = 8,
    parameter ADDR_S = 3
)(
    input clk,
    input choose_display,
    input store_addr_now,
    input rst,
    input store_now,
    input display_addr_vs_data,
    output [3:0] rows,
    input [3:0] cols,
    output [WIDTH-1:0] led,
    output ledtest
);

wire [WIDTH-1:0] data_in;
wire [ADDR_S-1:0] addr_in;
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
wire wr_en = (key_data == 4'b1010);
wire mem_out_en = (key_data == 4'b1100);
wire rd_en = (key_data == 4'b0011); //7 kypd

wire disp_addr_mode = (key_data == 4'b0111);  //3 keypad
wire disp_data_mode = (key_data == 4'b1000);  //6 keypad
reg disp_addr, disp_data;

wire bit_in = (key_data == 1) ? 1 : 0;

reg [WIDTH-1:0] mem_out_reg;
reg [WIDTH-1:0] disp_reg;


reg showing_address;
reg showing_data;

always @(posedge clk) begin

  if (key_ready) begin
    if (disp_addr_mode) begin
      showing_address <= 1'b1;
      showing_data    <= 1'b0;
    end else if (disp_data_mode || rd_en) begin
      showing_address <= 1'b0;
      showing_data    <= 1'b1;
    end
  end

  // 2) choose what to display
  if (showing_address)
    disp_reg <= { {WIDTH-ADDR_S{1'b0}}, addr_in };
  else if (showing_data)
    disp_reg <= (choose_display ? regB : regA);
  // else: hold last value
end


assign led = ~disp_reg;



//assign led = ~disp_reg;//{{WIDTH-ADDR_S{1'b0}}, disp_data_mode};//disp_reg;


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
) INBUF (
    
    .clk(clk),
    .rst(rst),
    .bit_in(bit_in),
    .store(store_now),
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
    .d_in(regB),
    .d_out(mem_out) 
);

//regB <= mem_out;


endmodule
