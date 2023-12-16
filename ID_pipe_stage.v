`timescale 1ns / 1ps


module ID_pipe_stage(
    input  clk, reset,
    input  [9:0] pc_plus4,
    input  [31:0] instr,
    input  mem_wb_reg_write,
    input  [4:0] mem_wb_write_reg_addr, 
    input  [31:0] mem_wb_write_back_data,
    input  Data_Hazard,
    input  Control_Hazard,
    output [31:0] reg1, reg2,
    output [31:0] imm_value,
    output [9:0] branch_address,
    output [9:0] jump_address,
    output branch_taken,
    output [4:0] destination_reg, 
    output mem_to_reg,
    output [1:0] alu_op,
    output mem_read,  
    output mem_write,
    output alu_src,
    output reg_write,
    output jump
    );
    
    // write your code here 
    // Remember that we test if the branch is taken or not in the decode stage.
 
    wire branch_taken2, reg_dst, mem_to_reg2, mem_read2, mem_write2, alu_src2, reg_write2, jump2;

    wire [1:0] alu_op2;
    
    control control_unit(
        .reset(reset),
        .opcode(instr[31:26]),
        .reg_dst(reg_dst), 
        .mem_to_reg(mem_to_reg2),
        .alu_op(alu_op2),
        .mem_read(mem_read2),  
        .mem_write(mem_write2),
        .alu_src(alu_src2),
        .reg_write(reg_write2),
        .branch(branch_taken2),
        .jump(jump2)); 
    assign jump = jump2;
    
    wire out_control_hazard;
    assign out_control_hazard = (~Data_Hazard | Control_Hazard);//check
    wire [31:0] zero;
    assign zero = 0;
    //output reg reg_dst, mem_to_reg, output reg [1:0] alu_op, output reg mem_read, mem_write, alu_src, reg_write, branch, jump 
    mux2 #(.mux_width(1)) mux_mem2reg
    (   .a(mem_to_reg2),
        .b(zero[0]),
        .sel(out_control_hazard),
        .y(mem_to_reg)); 
        
    mux2 #(.mux_width(2)) mux_aluop
    (   .a(alu_op2),
        .b(zero[1:0]),
        .sel(out_control_hazard),
        .y(alu_op));
    
    mux2 #(.mux_width(1)) mux_mem_read
    (   .a(mem_read2),
        .b(zero[0]),
        .sel(out_control_hazard),
        .y(mem_read));
    
    mux2 #(.mux_width(1)) mux_mem_write
    (   .a(mem_write2),
        .b(zero[0]),
        .sel(out_control_hazard),
        .y(mem_write));
    
    mux2 #(.mux_width(1)) mux_alu_src
    (   .a(alu_src2),
        .b(zero[0]),
        .sel(out_control_hazard),
        .y(alu_src));
        
    mux2 #(.mux_width(1)) mux_reg_write
    (   .a(reg_write2),
        .b(zero[0]),
        .sel(out_control_hazard),
        .y(reg_write));     
        
    assign jump_address = instr[25:0] << 2;
    
    wire [31:0] sign_ex_out;
    sign_extend sign_ex
    (   .sign_ex_in(instr[15:0]),
        .sign_ex_out(sign_ex_out));
    
    assign branch_address = pc_plus4 + (sign_ex_out<<2);
    
    register_file reg_file (
        .clk(clk),  
        .reset(reset),  
        .reg_write_en(mem_wb_reg_write),  
        .reg_write_dest(mem_wb_write_reg_addr),  
        .reg_write_data(mem_wb_write_back_data),  
        .reg_read_addr_1(instr[25:21]), 
        .reg_read_addr_2(instr[20:16]), 
        .reg_read_data_1(reg1),
        .reg_read_data_2(reg2));
    
    assign imm_value = sign_ex_out;
    
    wire [4:0] destination_reg2;
    mux2 #(.mux_width(5)) mux_reg_dst
    (   .a(instr[20:16]),
        .b(instr[15:11]),
        .sel(reg_dst),
        .y(destination_reg2));
    assign destination_reg = destination_reg2;
    
    wire eq_test;
    assign eq_test = ((reg1 ^ reg2) == 32'd0) ? 1'b1: 1'b0;
    assign branch_taken =  eq_test & branch_taken2;

         
endmodule
