module IF_ID_reg(
    input clk,
    input rst_n,
    input [0:31] pc_in,
    input [0:31] instr1_in,
    input [0:31] instr2_in,
    input single_issue_stall_in,
    input instr1_issued_in,
    input flush,

    output logic [0:31] instr1_out,
    output logic [0:31] instr2_out,
    output logic [0:31] pc_out,
    output logic single_issue_stall_out,
    output logic instr1_issued_out
);

    always_ff @(posedge clk) begin
        if(rst_n == 1'b0 || flush) begin 
            instr1_out <= 32'h40200000;
            instr2_out <= 32'h00200000;
            pc_out <= 0;
            single_issue_stall_out <= 0;
            instr1_issued_out <= 0;
        end
        else begin
            instr1_out <= instr1_in;
            instr2_out <= instr2_in;
            pc_out <= pc_in;
            single_issue_stall_out <= single_issue_stall_in;
            instr1_issued_out <= instr1_issued_in;
        end
    end

endmodule