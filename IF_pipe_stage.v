`timescale 1ns / 1ps


module IF_pipe_stage(
    input clk, reset,
    input en,
    input [9:0] branch_address,
    input [9:0] jump_address,
    input branch_taken,
    input jump,
    output [9:0] pc_plus4,
    output [31:0] instr
    );
    // write your code here
    reg [9:0] pc; // program counter
    wire [9:0] w_pc_plus4;
    //wire for the jump_mux
    wire [9:0] output_jump;
        //wire for the branch taken mux
    wire [9:0] output_branch_taken;
    
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            pc <= 0;
        end
        else if (en) begin
            pc <= output_jump;
        end
    end
    
    assign w_pc_plus4 = pc + 10'b0000000100;
    assign pc_plus4 = w_pc_plus4;
    //create mux for branch taken
    mux2 #(.mux_width(10)) branch_taken_mux
    (   .a(w_pc_plus4),
        .b(branch_address),
        .sel(branch_taken),
        .y(output_branch_taken)); 
        

    //create mux for jump 
    mux2 #(.mux_width(10)) jump_mux
    (   .a(output_branch_taken),
        .b(jump_address),
        .sel(jump),
        .y(output_jump));   
          
    instruction_mem instr_mem (
        .read_addr(pc),
        .data(instr));
            
     
    
    
endmodule
