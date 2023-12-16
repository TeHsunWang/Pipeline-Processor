`timescale 1ns / 1ps


module mips_32(
    input clk, reset,  
    output[31:0] result
    );
    
// define all the wires here. You need to define more wires than the ones you did in Lab2
wire [9:0] pc_plus4;
wire [31:0] instr;
wire [9:0] branch_addr;
wire [9:0] jump_addr;
wire branch_taken;
wire jump;

wire if_flush;
wire [9:0] if_id_pc_plus4;
wire [31:0] if_id_instr;
   
wire [31:0] mem_wb_write_back_data;//
wire data_hazard;
//wire control_Hazard;  //if_flush
wire [31:0] reg1;
wire [31:0] reg2;
wire [31:0] imm_val;
wire [4:0] dest_reg;
wire mem2reg;
wire [1:0] alu_op;
wire mem_read;
wire mem_write;
wire alu_src;
wire reg_write;

wire [31:0] id_ex_instr; 
wire [31:0] id_ex_reg1;
wire [31:0] id_ex_reg2;
wire [31:0] id_ex_imm_value;
wire [4:0] id_ex_destination_reg;
wire id_ex_mem_to_reg;
wire [1:0] id_ex_alu_op;
wire id_ex_mem_read;
wire id_ex_mem_write;
wire id_ex_alu_src;
wire id_ex_reg_write;

wire [31:0] ex_mem_alu_result;
wire [31:0] write_back_data;
wire [1:0] Forward_A;
wire [1:0] Forward_B;
wire [31:0] alu_in2_out;
wire [31:0] alu_result;

wire ex_mem_reg_write; 
wire mem_wb_reg_write; 

wire [31:0] ex_mem_instr;
wire [4:0] ex_mem_destination_reg;
wire [31:0] ex_mem_alu_in2_out;
wire ex_mem_mem_to_reg;
wire ex_mem_mem_read;
wire ex_mem_mem_write;


wire [31:0] mem_read_data; 

wire [31:0] mem_wb_alu_result;
wire [31:0] mem_wb_mem_read_data; 
wire mem_wb_mem_to_reg;
wire [4:0] mem_wb_destination_reg;


// Build the pipeline as indicated in the lab manual

///////////////////////////// Instruction Fetch    
    // Complete your code here      
//create i instant for IF block
IF_pipe_stage IF_pipeline_stage(
    .clk(clk),
    .reset(reset),
    .branch_address(branch_addr),
    .jump_address(jump_addr),
    .branch_taken(branch_taken),
    .jump(jump),
    .en(data_hazard), // which comes from daa hazard
    .pc_plus4(pc_plus4),
    .instr(instr));    
        
///////////////////////////// IF/ID registers
    // Complete your code here
//add reg
pipe_reg_en #(.WIDTH (10)) pipe_reg_en_id_pc_plus4
    (   .clk(clk),
        .reset(reset),
        .en(data_hazard), //comes from Data_Hazard
        .flush(if_flush), //comes from IF_Flush
        .d(pc_plus4),
        .q(if_id_pc_plus4)
        );
pipe_reg_en #(.WIDTH (32)) pipe_reg_en_id_instr
    (   .clk(clk),
        .reset(reset),
        .en(data_hazard),
        .flush(if_flush),
        .d(instr),
        .q(if_id_instr)
        );
///////////////////////////// Instruction Decode 
	// Complete your code here
ID_pipe_stage ID_pipeline_stage(
    .clk(clk),
    .reset(reset),
    .pc_plus4(if_id_pc_plus4),//check
    .instr(if_id_instr), //check
    .mem_wb_reg_write(mem_wb_reg_write),
    .mem_wb_write_reg_addr(mem_wb_destination_reg),
    .mem_wb_write_back_data(write_back_data),
    .Data_Hazard(data_hazard),
    .Control_Hazard(if_flush),
    .reg1(reg1),
    .reg2(reg2),
    .imm_value(imm_val),
    .branch_address(branch_addr),
    .jump_address(jump_addr),
    .branch_taken(branch_taken),
    .destination_reg(dest_reg),
    .mem_to_reg(mem2reg),
    .alu_op(alu_op),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .alu_src(alu_src),
    .reg_write(reg_write),
    .jump(jump));
    
             
///////////////////////////// ID/EX registers 
	// Complete your code here
pipe_reg #(.WIDTH (32)) pipe_reg_id_ex_instr
    (   .clk(clk),
        .reset(reset),
        .d(if_id_instr),
        .q(id_ex_instr)
        );
        
pipe_reg #(.WIDTH (32)) pipe_reg_id_ex_reg1
    (   .clk(clk),
        .reset(reset),
        .d(reg1),
        .q(id_ex_reg1)
        );
        
pipe_reg #(.WIDTH (32)) pipe_reg_id_ex_reg2
    (   .clk(clk),
        .reset(reset),
        .d(reg2),
        .q(id_ex_reg2)
        );

pipe_reg #(.WIDTH (32)) pipe_reg_id_ex_imm_value
    (   .clk(clk),
        .reset(reset),
        .d(imm_val),
        .q(id_ex_imm_value)
        );

pipe_reg #(.WIDTH (5)) pipe_reg_id_ex_destination_reg
    (   .clk(clk),
        .reset(reset),
        .d(dest_reg),
        .q(id_ex_destination_reg)
        );
        
pipe_reg #(.WIDTH (1)) pipe_reg_id_ex_mem2reg
    (   .clk(clk),
        .reset(reset),
        .d(mem2reg),
        .q(id_ex_mem_to_reg)
        );
        
pipe_reg #(.WIDTH (2)) pipe_reg_id_ex_alu_op
    (   .clk(clk),
        .reset(reset),
        .d(alu_op),
        .q(id_ex_alu_op)
        );
        
pipe_reg #(.WIDTH (1)) pipe_reg_id_ex_mem_read
    (   .clk(clk),
        .reset(reset),
        .d(mem_read),
        .q(id_ex_mem_read)
        );
        
pipe_reg #(.WIDTH (1)) pipe_reg_id_ex_mem_write
    (   .clk(clk),
        .reset(reset),
        .d(mem_write),
        .q(id_ex_mem_write)
        );
        
pipe_reg #(.WIDTH (1)) pipe_reg_id_ex_alu_src
    (   .clk(clk),
        .reset(reset),
        .d(alu_src),
        .q(id_ex_alu_src)
        );
        
pipe_reg #(.WIDTH (1)) pipe_reg_id_ex_reg_write
    (   .clk(clk),
        .reset(reset),
        .d(reg_write),
        .q(id_ex_reg_write)
        );
///////////////////////////// Hazard_detection unit
	// Complete your code here    
Hazard_detection hazard_dection_unit(
    .id_ex_mem_read(id_ex_mem_read),
    .id_ex_destination_reg(id_ex_destination_reg),
    .if_id_rs(if_id_instr[25:21]), 
    .if_id_rt(if_id_instr[20:16]),
    .branch_taken(branch_taken),
    .jump(jump),
    .Data_Hazard(data_hazard),
    .IF_Flush(if_flush));
           
///////////////////////////// Execution    
	// Complete your code here
EX_pipe_stage ex_pipeline_stage(
    .id_ex_instr(id_ex_instr),
    .reg1(id_ex_reg1),
    .reg2(id_ex_reg2),
    .id_ex_imm_value(id_ex_imm_value),
    .ex_mem_alu_result(ex_mem_alu_result),
    .mem_wb_write_back_result(write_back_data), //notice
    .id_ex_alu_src(id_ex_alu_src),
    .id_ex_alu_op(id_ex_alu_op),
    .Forward_A(Forward_A),
    .Forward_B(Forward_B),
    .alu_in2_out(alu_in2_out),
    .alu_result(alu_result));
        
///////////////////////////// Forwarding unit
	// Complete your code here 
EX_Forwarding_unit ex_forwarding_unit(
    .ex_mem_reg_write(ex_mem_reg_write),
    .ex_mem_write_reg_addr(ex_mem_destination_reg),
    .id_ex_instr_rs(id_ex_instr[25:21]),
    .id_ex_instr_rt(id_ex_instr[20:16]),
    .mem_wb_reg_write(mem_wb_reg_write),
    .mem_wb_write_reg_addr(mem_wb_destination_reg),
    .Forward_A(Forward_A),
    .Forward_B(Forward_B));
     
///////////////////////////// EX/MEM registers
	// Complete your code here 
pipe_reg #(.WIDTH (32)) pipe_reg_ex_mem_instr
    (   .clk(clk),
        .reset(reset),
        .d(id_ex_instr),
        .q(ex_mem_instr)
        );
 
pipe_reg #(.WIDTH (5)) pipe_reg_ex_mem_desination_reg
    (   .clk(clk),
        .reset(reset),
        .d(id_ex_destination_reg),
        .q(ex_mem_destination_reg)
        );
 
pipe_reg #(.WIDTH (32)) pipe_reg_ex_mem_alu_result
    (   .clk(clk),
        .reset(reset),
        .d(alu_result),
        .q(ex_mem_alu_result)
        );     
  
pipe_reg #(.WIDTH (32)) pipe_reg_ex_mem_alu_in2_out
    (   .clk(clk),
        .reset(reset),
        .d(alu_in2_out),
        .q(ex_mem_alu_in2_out)
        );     

pipe_reg #(.WIDTH (1)) pipe_reg_ex_mem_to_reg
    (   .clk(clk),
        .reset(reset),
        .d(id_ex_mem_to_reg),
        .q(ex_mem_mem_to_reg)
        );

pipe_reg #(.WIDTH (1)) pipe_reg_ex_mem_read
    (   .clk(clk),
        .reset(reset),
        .d(id_ex_mem_read),
        .q(ex_mem_mem_read)
        );        

pipe_reg #(.WIDTH (1)) pipe_reg_ex_mem_write
    (   .clk(clk),
        .reset(reset),
        .d(id_ex_mem_write),
        .q(ex_mem_mem_write)
        );     
pipe_reg #(.WIDTH (1)) pipe_reg_ex_mem_reg_write
    (   .clk(clk),
        .reset(reset),
        .d(id_ex_reg_write),
        .q(ex_mem_reg_write)
        );     
///////////////////////////// memory    
	// Complete your code here
data_memory data_mem(
    .clk(clk),
    .mem_access_addr(ex_mem_alu_result), 
    .mem_write_data(ex_mem_alu_in2_out), 
    .mem_write_en(ex_mem_mem_write), 
    .mem_read_en(ex_mem_mem_read), 
    .mem_read_data(mem_read_data));

///////////////////////////// MEM/WB registers  
	// Complete your code here
pipe_reg #(.WIDTH (32)) pipe_reg_mem_wb_alu_result
    (   .clk(clk),
        .reset(reset),
        .d(ex_mem_alu_result),
        .q(mem_wb_alu_result)
        );
    
pipe_reg #(.WIDTH (32)) pipe_reg_mem_read_data
    (   .clk(clk),
        .reset(reset),
        .d(mem_read_data),
        .q(mem_wb_mem_read_data)
        ); 
        
pipe_reg #(.WIDTH (1)) pipe_reg_mem_wb_mem_to_reg
    (   .clk(clk),
        .reset(reset),
        .d(ex_mem_mem_to_reg),
        .q(mem_wb_mem_to_reg)
        );

pipe_reg #(.WIDTH (1)) pipe_reg_mem_reg_write
    (   .clk(clk),
        .reset(reset),
        .d(ex_mem_reg_write),
        .q(mem_wb_reg_write)
        );     

pipe_reg #(.WIDTH (5)) pipe_reg_mem_wb_destination_reg
    (   .clk(clk),
        .reset(reset),
        .d(ex_mem_destination_reg),
        .q(mem_wb_destination_reg)
        );  
///////////////////////////// writeback    
	// Complete your code here
mux2 #(.mux_width(32)) mux_write_back_data
    (   .a(mem_wb_alu_result), //check
        .b(mem_wb_mem_read_data),//check
        .sel(mem_wb_mem_to_reg),
        .y(write_back_data)); 
assign result = write_back_data;

    
endmodule
