`timescale 1ns / 1ps

module EX_pipe_stage(
    input [31:0] id_ex_instr, //check
    input [31:0] reg1, reg2,
    input [31:0] id_ex_imm_value,
    input [31:0] ex_mem_alu_result,
    input [31:0] mem_wb_write_back_result,
    input id_ex_alu_src,
    input [1:0] id_ex_alu_op,
    input [1:0] Forward_A, Forward_B,
    output [31:0] alu_in2_out,
    output [31:0] alu_result
    );
    
    // Write your code here
    wire [3:0] alu_control_out;
    ALUControl ALU_Control_unit(
        .ALUOp(id_ex_alu_op),
        .Function(id_ex_instr[5:0]),
        .ALU_Control(alu_control_out));
    
    // d:11 c:10 b:01 a:00 
    wire [31:0] id_ex_reg1_out;
    mux4 #(.mux_width(32)) mux_id_ex_reg1
    (   .a(reg1),
        .b(mem_wb_write_back_result),
        .c(ex_mem_alu_result),
        .d(),
        .sel(Forward_A),
        .y(id_ex_reg1_out));
         
    wire [31:0] alu_in2_out2;   
    mux4 #(.mux_width(32)) mux_id_ex_reg2
    (   .a(reg2),
        .b(mem_wb_write_back_result),
        .c(ex_mem_alu_result),
        .d(),
        .sel(Forward_B),
        .y(alu_in2_out2)); 
    assign alu_in2_out = alu_in2_out2;
    
    wire [31:0] alu_src_out;    
    mux2 #(.mux_width(32)) mux_id_alu
    (   .a(alu_in2_out2),
        .b(id_ex_imm_value),
        .sel(id_ex_alu_src),
        .y(alu_src_out));   
    
    wire [31:0] zero;
    assign zero = 0;
    ALU alu_inst (
        .a(id_ex_reg1_out),
        .b(alu_src_out),
        .alu_control(alu_control_out),
        .zero(zero[0]),
        .alu_result(alu_result)); 
       
endmodule
