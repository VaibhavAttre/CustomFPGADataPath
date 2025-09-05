module microcode_engine #(
    parameter OP_S = 3,
    parameter MICROADDR_S = 3, 
    parameter MICRO_W = 32
)(
    input clk, input rst,
    input start,
    input [OP_S-1:0] opcode_in,
    output reg busy,
    output reg done,
    output reg pc_inc,
    output reg pc_load,
    output reg mar_load,
    output reg mar_from_operand,
    output reg mem_rd,
    output reg mem_wr,
    output reg mdr_load,
    output reg ir_load,
    output reg reg_loadA,
    output reg reg_loadB,
    output reg alu_calc,
    output reg [OP_S-1:0] alu_opcode,
    output reg mdr_sel_mem,
    output reg mem_d_from_alu,
    output reg reg_from_mdr_A,
    output reg reg_from_mdr_B
);

    localparam OPCODES = (1<<OP_S);
    localparam MICRO_STEPS = (1<<MICROADDR_S);
    localparam ROM_DEPTH = OPCODES * MICRO_STEPS;

    reg [MICRO_W-1:0] rom [0:ROM_DEPTH-1];
    integer i;
    initial begin
        for (i = 0; i < ROM_DEPTH; i = i + 1) rom[i] = 32'h80000000;

        // opcode mapping:
        // 000 NOP
        // 001 LOAD A, [IMM_ADDR]   (operand = address)
        // 010 STORE [IMM_ADDR], A
        // 011 ADD A, B
        // 100 SUB A, B
        // 101 MOV A, #IMM
        // 110 JMP IMM
        // 111 HALT (treated as NOP)

        rom[{3'b001, 3'd0}] = 32'b0_0_000000_0_0_1_1_0_0_0_0_0_0_000_0_0_0;
      
        rom[{3'b001, 3'd1}] = 32'b0_0_000000_0_0_0_0_1_0_0_0_0_0_000_0_0_0;
 
        rom[{3'b001, 3'd2}] = 32'b1_0_000000_0_0_0_0_0_1_0_0_0_0_000_1_0_0;

        rom[{3'b010, 3'd0}] = 32'b0_0_000000_0_0_1_1_0_0_0_0_0_000_0_0_0;
        rom[{3'b010, 3'd1}] = 32'b0_0_000000_0_0_0_0_0_1_0_0_0_0_000_1_0_0; 
        rom[{3'b010, 3'd2}] = 32'b1_0_000000_0_0_0_0_0_0_1_0_0_000_0_1_0;

        rom[{3'b011, 3'd0}] = 32'b0_0_000000_0_0_0_0_0_0_0_1_0_001_0_0_0;
        rom[{3'b011, 3'd1}] = 32'b1_0_000000_0_0_0_0_0_0_1_0_0_000_0_0_0;

        rom[{3'b100, 3'd0}] = 32'b0_0_000000_0_0_0_0_0_0_0_1_0_010_0_0_0;
        rom[{3'b100, 3'd1}] = 32'b1_0_000000_0_0_0_0_0_0_1_0_0_000_0_0_0;

        rom[{3'b101, 3'd0}] = 32'b0_0_000000_0_0_0_0_0_0_0_0_0_000_0_1_0;
        rom[{3'b101, 3'd1}] = 32'b1_0_000000_0_0_0_0_0_0_1_0_0_000_1_0_0;

        rom[{3'b110, 3'd0}] = 32'b1_0_000000_0_1_0_0_0_0_0_0_0_000_0_0_0;

    end

    reg [MICROADDR_S-1:0] micro_pc;
    reg running;

    function [MICRO_W-1:0] rom_fetch;
        input [OP_S+MICROADDR_S-1:0] addr;
        begin
            rom_fetch = rom[addr];
        end
    endfunction

    wire [OP_S+MICROADDR_S-1:0] rom_addr = {opcode_in, micro_pc};
    wire [MICRO_W-1:0] cur_instr = rom[rom_addr];

    wire instr_end        = cur_instr[31];
    wire instr_pc_load    = cur_instr[22];
    wire instr_pc_inc     = cur_instr[23];
    wire instr_mar_load   = cur_instr[21];
    wire instr_mar_from_op= cur_instr[20];
    wire instr_mem_rd     = cur_instr[19];
    wire instr_mem_wr     = cur_instr[18];
    wire instr_mdr_load   = cur_instr[17];
    wire instr_ir_load    = cur_instr[16];
    wire instr_reg_loadA  = cur_instr[15];
    wire instr_reg_loadB  = cur_instr[14];
    wire instr_alu_calc   = cur_instr[13];
    wire [2:0] instr_alu_op = cur_instr[12:10];
    wire instr_mdr_sel_mem = cur_instr[9];
    wire instr_mem_d_alu   = cur_instr[8];
    wire instr_reg_from_mdr_A = cur_instr[7];
    wire instr_reg_from_mdr_B = cur_instr[6];

    integer j;
    always @(posedge clk) begin
        if (rst) begin
            micro_pc <= {MICROADDR_S{1'b0}}; running <= 1'b0; busy <= 1'b0; done <= 1'b0;
        
            pc_inc <= 0; pc_load <= 0; mar_load <= 0; mar_from_operand <= 0;
            mem_rd <= 0; mem_wr <= 0; mdr_load <= 0; ir_load <= 0;
            reg_loadA <= 0; reg_loadB <= 0; alu_calc <= 0; alu_opcode <= 0;
            mdr_sel_mem <= 0; mem_d_from_alu <= 0;
            reg_from_mdr_A <= 0; reg_from_mdr_B <= 0;
        end else begin

            pc_inc <= 0; pc_load <= 0; mar_load <= 0; mar_from_operand <= 0;
            mem_rd <= 0; mem_wr <= 0; mdr_load <= 0; ir_load <= 0;
            reg_loadA <= 0; reg_loadB <= 0; alu_calc <= 0; alu_opcode <= 0;
            mdr_sel_mem <= 0; mem_d_from_alu <= 0;
            reg_from_mdr_A <= 0; reg_from_mdr_B <= 0;
            done <= 0;

            if (~running) begin
                if (start) begin
                    running <= 1'b1;
                    busy <= 1'b1;
                    micro_pc <= {MICROADDR_S{1'b0}};
                end
            end else begin
              
                pc_load <= instr_pc_load;
                pc_inc  <= instr_pc_inc;
                mar_load <= instr_mar_load;
                mar_from_operand <= instr_mar_from_op;
                mem_rd <= instr_mem_rd;
                mem_wr <= instr_mem_wr;
                mdr_load <= instr_mdr_load;
                ir_load <= instr_ir_load;
                reg_loadA <= instr_reg_loadA;
                reg_loadB <= instr_reg_loadB;
                alu_calc <= instr_alu_calc;
                alu_opcode <= instr_alu_op;
                mdr_sel_mem <= instr_mdr_sel_mem;
                mem_d_from_alu <= instr_mem_d_alu;
                reg_from_mdr_A <= instr_reg_from_mdr_A;
                reg_from_mdr_B <= instr_reg_from_mdr_B;

                if (instr_end) begin
                    running <= 1'b0;
                    busy <= 1'b0;
                    done <= 1'b1;
                end else begin
                    micro_pc <= micro_pc + 1'b1;
                end
            end
        end
    end

endmodule