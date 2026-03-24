module register_file(
    input clk,
    input reset_n,
    input RegWriteEven,
    input RegWriteOdd,
    input [0:6]  RA_addr_even,
    input [0:6]  RB_addr_even,
    input [0:6]  RC_addr_even,
    input [0:6]  RT_addr_even,
    input [0:6]  RA_addr_odd,
    input [0:6]  RB_addr_odd,
    input [0:6]  RT_addr_odd,
    
    //for the write back stage
    input [0:6]  waddr_odd,
    input [0:6]  waddr_even,
    input [0:127] wdata_even,
    input [0:127] wdata_odd,    
    
    output  logic [0:127]  RA_even,
    output  logic [0:127]  RB_even,
    output  logic [0:127]  RC_even,
    output  logic [0:127]  RT_even,
    output  logic [0:127]  RA_odd,
    output  logic [0:127]  RB_odd,
    output  logic [0:127]  RT_odd
);

    logic [0:127] registers [0:127];

    always_ff @(posedge clk) begin
        if (!reset_n) begin
            for (int i = 0; i < 128; i++) registers[i] <= '0;
            registers[1] <= '1;
        end
        else begin
            if (RegWriteEven) registers[waddr_even] <= wdata_even;
            if (RegWriteOdd)  registers[waddr_odd]  <= wdata_odd;
        end
    end
    
    always_comb begin
        RA_even = registers[RA_addr_even];
        RB_even = registers[RB_addr_even];
        RC_even = registers[RC_addr_even];
        RT_even = registers[RT_addr_even];
        RA_odd  = registers[RA_addr_odd];
        RB_odd  = registers[RB_addr_odd];
        RT_odd  = registers[RT_addr_odd];
    end

endmodule