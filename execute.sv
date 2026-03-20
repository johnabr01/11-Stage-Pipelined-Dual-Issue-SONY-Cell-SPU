import packet_pkg::*;

module execute(
    input clk,
    input rst_n,

    input [0:6]  RA_addr_even,
    input [0:6]  RB_addr_even,
    input [0:6]  RC_addr_even,
    input [0:31] instr_even,
    input [0:6]  ID_even,
    input [0:3]  Latency_even,
    input [0:6]  RT_addr_even,

    input [0:31] PC,
    input [0:6]  RA_addr_odd,
    input [0:6]  RB_addr_odd,
    input [0:31] instr_odd,
    input [0:6]  ID_odd,
    input [0:3]  Latency_odd,
    input [0:6]  RT_addr_odd,
    output logic [0:31] PC_out
);

// --- Register File Outputs ---
logic [0:127] RA_even_data, RB_even_data, RC_even_data, RT_even_data;
logic [0:127] RA_odd_data,  RB_odd_data,  RT_odd_data;

// --- Register File Write Ports (driven by forwarding/writeback) ---
logic         RegWriteEven, RegWriteOdd;
logic [0:6]   waddr_even,   waddr_odd;
logic [0:127] wdata_even,   wdata_odd;

// --- Even Pipe ---
packet        pkt_in_even;
logic         canForwardEven;
even_packet   even_pkt_pipes [0:6];
logic [0:127] RT_even_dest_data;

// --- Odd Pipe ---
packet        pkt_in_odd;
logic         canForwardOdd;
odd_packet    odd_pkt_pipes  [0:6];
logic [0:127] RT_odd_dest_data;

// --- Pack input structs ---
always_comb begin
    // Even packet
    pkt_in_even.RA           = RA_even_data;
    pkt_in_even.RB           = RB_even_data;
    pkt_in_even.RC           = RC_even_data;
    pkt_in_even.RT_read_addr = RT_addr_even;
    pkt_in_even.RT_read_data = RT_even_data;
    pkt_in_even.RT_dest_addr = RT_addr_even;  // Fix #2: was empty
    pkt_in_even.ID           = ID_even;
    pkt_in_even.Latency      = Latency_even;
    pkt_in_even.instr        = instr_even;
    pkt_in_even.RegWrite     = RegWriteEven;
    pkt_in_even.RT_dest_data = RT_even_dest_data;

    // Odd packet
    pkt_in_odd.RA            = RA_odd_data;
    pkt_in_odd.RB            = RB_odd_data;
    pkt_in_odd.RC            = '0;
    pkt_in_odd.RT_read_addr  = RT_addr_odd;   // Fix #1: was missing
    pkt_in_odd.RT_read_data  = RT_odd_data;
    pkt_in_odd.RT_dest_addr  = RT_addr_odd;
    pkt_in_odd.ID            = ID_odd;
    pkt_in_odd.Latency       = Latency_odd;
    pkt_in_odd.instr         = instr_odd;
    pkt_in_odd.RegWrite      = RegWriteOdd;
    pkt_in_odd.RT_dest_data  = RT_odd_dest_data;
end

// --- Writeback: drive reg file write ports from pipe outputs ---
always_comb begin
    RegWriteEven = even_pkt_pipes[6].RegWr;
    waddr_even   = even_pkt_pipes[6].dest_addr;
    wdata_even   = even_pkt_pipes[6].result;

    RegWriteOdd  = odd_pkt_pipes[6].RegWr;
    waddr_odd    = odd_pkt_pipes[6].dest_addr;
    wdata_odd    = odd_pkt_pipes[6].result;
end

register_file reg_file_inst(
    .clk          (clk),
    .reset_n      (rst_n),
    .RegWriteEven (RegWriteEven),
    .RegWriteOdd  (RegWriteOdd),

    .RA_addr_even (RA_addr_even),
    .RB_addr_even (RB_addr_even),
    .RC_addr_even (RC_addr_even),
    .RT_addr_even (RT_addr_even),

    .RA_addr_odd  (RA_addr_odd),
    .RB_addr_odd  (RB_addr_odd),
    .RT_addr_odd  (RT_addr_odd),

    .waddr_even   (waddr_even),
    .waddr_odd    (waddr_odd),
    .wdata_even   (wdata_even),
    .wdata_odd    (wdata_odd),

    .RA_even      (RA_even_data),
    .RB_even      (RB_even_data),
    .RC_even      (RC_even_data),
    .RT_even      (RT_even_data),
    .RA_odd       (RA_odd_data),
    .RB_odd       (RB_odd_data),
    .RT_odd       (RT_odd_data)
);

odd_pipe odd_pipe_inst(
    .clk              (clk),
    .rst_n            (rst_n),
    .PC               (PC),
    .pkt_in           (pkt_in_odd),
    .PC_out           (PC_out),
    .canForwardOdd    (canForwardOdd),
    .odd_pkt_pipes    (odd_pkt_pipes)
);

even_pipe even_pipe_inst(
    .clk               (clk),
    .rst_n             (rst_n),
    .pkt_in            (pkt_in_even),
    .canForwardEven    (canForwardEven),
    .even_pkt_pipes    (even_pkt_pipes)
);

endmodule