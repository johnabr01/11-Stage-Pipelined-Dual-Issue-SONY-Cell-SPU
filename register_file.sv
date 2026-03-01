module register_file(
    input clk,
    input reset_n,
    input wen1,
    input wen2,
    input  logic [127:0]  waddr1,
    input  logic [127:0]  waddr2,
    input  logic [127:0]  wdata1,
    input  logic [127:0]  wdata2,
    input  logic [127:0]  raddr1,
    input  logic [127:0]  raddr2,
    output logic [127:0]  rdata1,
    output logic [127:0]  rdata2 
);

    logic [127 : 0] registers [0 : 127];

    always_ff @(posedge clk) begin
        if(!reset_n) begin
            for(int i = 0; i < N; i++) registers[i] = 0;
        end
        else if (wen1) regs[waddr1] <= wdata1;
        else if (wen2) regs[waddr2] <= wdata2;
    end

    
  always_comb begin
    rdata1 = regs[raddr1];
    rdata2 = regs[raddr2];
  end

endmodule