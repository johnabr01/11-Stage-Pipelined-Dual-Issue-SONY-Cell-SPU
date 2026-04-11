module program_counter(
    input [0:31] pc_next,
    input clk,
    input rst_n,
    input pc_write,
    output logic [0:31] pc_out
);

    always_ff @(posedge clk) begin
        if(rst_n == 1'b0) pc_out <= 0;
        else if(pc_write) pc_out <= pc_next;
    end

endmodule