module ID_EX_reg (
    input  logic clk,
    input  logic rst_n,
    input  logic flush,
    input  logic stall,

    // Even pipe inputs (from ID stage)
    input  logic [0:6]  RA_addr_even_in,
    input  logic [0:6]  RB_addr_even_in,
    input  logic [0:6]  RC_addr_even_in,
    input  logic [0:31] instr_even_in,
    input  logic [0:6]  ID_even_in,
    input  logic [0:3]  Latency_even_in,
    input  logic [0:6]  RT_addr_even_in,
    input  logic        RegWriteEven_in,
    input  logic        RT_source_even_in,
    input  logic        RA_source_even_in,
    input  logic        RB_source_even_in,
    input  logic        RC_source_even_in,

    // Odd pipe inputs (from ID stage)
    input  logic [0:31] PC_in,
    input  logic [0:6]  RA_addr_odd_in,
    input  logic [0:6]  RB_addr_odd_in,
    input  logic [0:31] instr_odd_in,
    input  logic [0:6]  ID_odd_in,
    input  logic [0:3]  Latency_odd_in,
    input  logic [0:6]  RT_addr_odd_in,
    input  logic        RegWriteOdd_in,
    input  logic        RT_source_odd_in,
    input  logic        RA_source_odd_in,
    input  logic        RB_source_odd_in,

    // Even pipe outputs (to EX stage)
    output logic [0:6]  RA_addr_even_out,
    output logic [0:6]  RB_addr_even_out,
    output logic [0:6]  RC_addr_even_out,
    output logic [0:31] instr_even_out,
    output logic [0:6]  ID_even_out,
    output logic [0:3]  Latency_even_out,
    output logic [0:6]  RT_addr_even_out,
    output logic        RegWriteEven_out,
    // output logic        RT_source_even_out,
    // output logic        RA_source_even_out,
    // output logic        RB_source_even_out,
    // output logic        RC_source_even_out,

    // Odd pipe outputs (to EX stage)
    output logic [0:31] PC_out,
    output logic [0:6]  RA_addr_odd_out,
    output logic [0:6]  RB_addr_odd_out,
    output logic [0:31] instr_odd_out,
    output logic [0:6]  ID_odd_out,
    output logic [0:3]  Latency_odd_out,
    output logic [0:6]  RT_addr_odd_out,
    output logic        RegWriteOdd_out,
    // output logic        RT_source_odd_out,
    // output logic        RA_source_odd_out,
    // output logic        RB_source_odd_out
);

    always_ff @(posedge clk) begin
        if (!rst_n || flush) begin
            // Even pipe reset
            RA_addr_even_out   <= 7'b0;
            RB_addr_even_out   <= 7'b0;
            RC_addr_even_out   <= 7'b0;
            instr_even_out     <= 32'b0;
            ID_even_out        <= 7'b0;
            Latency_even_out   <= 4'b0;
            RT_addr_even_out   <= 7'b0;
            RegWriteEven_out   <= 1'b0;

            // RT_source_even_out  <= 1'b0;
            // RA_source_even_out  <= 1'b0;
            // RB_source_even_out  <= 1'b0;
            // RC_source_even_out  <= 1'b0;

            // Odd pipe reset
            PC_out             <= 32'b0;
            RA_addr_odd_out    <= 7'b0;
            RB_addr_odd_out    <= 7'b0;
            instr_odd_out      <= 32'b0;
            ID_odd_out         <= 7'b0;
            Latency_odd_out    <= 4'b0;
            RT_addr_odd_out    <= 7'b0;
            RegWriteOdd_out    <= 1'b0;

            // RT_source_odd_out  <= 1'b0;
            // RA_source_odd_out  <= 1'b0;
            // RB_source_odd_out  <= 1'b0;

        end else if (!stall) begin
            // Even pipe passthrough
            RA_addr_even_out   <= RA_addr_even_in;
            RB_addr_even_out   <= RB_addr_even_in;
            RC_addr_even_out   <= RC_addr_even_in;
            instr_even_out     <= instr_even_in;
            ID_even_out        <= ID_even_in;
            Latency_even_out   <= Latency_even_in;
            RT_addr_even_out   <= RT_addr_even_in;
            RegWriteEven_out   <= RegWriteEven_in;

            // RT_source_even_out  <= RT_source_even_in;
            // RA_source_even_out  <= RA_source_even_in;
            // RB_source_even_out  <= RB_source_even_in;
            // RC_source_even_out  <= RC_source_even_in;

            // Odd pipe passthrough
            PC_out             <= PC_in;
            RA_addr_odd_out    <= RA_addr_odd_in;
            RB_addr_odd_out    <= RB_addr_odd_in;
            instr_odd_out      <= instr_odd_in;
            ID_odd_out         <= ID_odd_in;
            Latency_odd_out    <= Latency_odd_in;
            RT_addr_odd_out    <= RT_addr_odd_in;
            RegWriteOdd_out    <= RegWriteOdd_in;

            // RT_source_odd_out  <= RT_source_odd_in;
            // RA_source_odd_out  <= RA_source_odd_in;
            // RB_source_odd_out  <= RB_source_odd_in;
        end
        // stall: hold state
    end

endmodule