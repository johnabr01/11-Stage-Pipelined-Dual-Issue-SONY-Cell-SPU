module pipeline_tb();
    localparam CLK_PERIOD = 10;
    localparam LAST_STAGE  = 8;

    logic clk=0, rst_n;

    always #(CLK_PERIOD/2) clk = ~clk;

    logic [0:6]  RA_addr_even, RB_addr_even, RC_addr_even;
    logic [0:31] instr_even;
    logic [0:6]  ID_even;
    logic [0:3]  Latency_even;
    logic [0:6]  RT_addr_even;
    logic RegWriteEven_in;

    logic [0:31] PC;
    logic [0:6]  RA_addr_odd, RB_addr_odd;
    logic [0:31] instr_odd;
    logic [0:6]  ID_odd;
    logic [0:3]  Latency_odd;
    logic [0:6]  RT_addr_odd;
    logic [0:31] PC_out;
    logic RegWriteOdd_in;

    execute dut (
        .clk          (clk),
        .rst_n        (rst_n),
        .RA_addr_even (RA_addr_even),
        .RB_addr_even (RB_addr_even),
        .RC_addr_even (RC_addr_even),
        .instr_even   (instr_even),
        .ID_even      (ID_even),
        .Latency_even (Latency_even),
        .RT_addr_even (RT_addr_even),
        .RegWriteEven_in(RegWriteEven_in),
        .PC           (PC),
        .RA_addr_odd  (RA_addr_odd),
        .RB_addr_odd  (RB_addr_odd),
        .instr_odd    (instr_odd),
        .ID_odd       (ID_odd),
        .Latency_odd  (Latency_odd),
        .RT_addr_odd  (RT_addr_odd),
        .RegWriteOdd_in(RegWriteOdd_in),
        .PC_out       (PC_out)
    );

    initial begin
        rst_n        = 0;
        RA_addr_even = 0; RB_addr_even = 0; RC_addr_even = 0; RT_addr_even = 0;
        instr_even   = 0; ID_even      = 0; Latency_even = 0; RegWriteEven_in = 0;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;
        PC           = 0;

        repeat(4) @(posedge clk);
        rst_n = 1;

        // ahi r1, r0, 1
        // @(negedge clk);
        // instr_even   = 32'h1D004001;
        // RA_addr_even = 7'd0;   // r0
        // RT_addr_even = 7'd1;   // r1
        // ID_even      = 7'd2;
        // Latency_even = 4'd3;
        // RegWriteEven_in = 1; 

        @(negedge clk);
        instr_even   = 32'h0D004083;
        RA_addr_even = 7'd1;   // r0
        RT_addr_even = 7'd3;   // r3
        ID_even      = 7'd10;
        Latency_even = 4'd3;
        RegWriteEven_in = 1; 

        //shlqbii
        // @(negedge clk);
        // instr_odd  = 32'h3F604082;
        // RA_addr_odd = 7'd1;   // r1
        // RT_addr_odd = 7'd2;   // r2
        // ID_odd     = 7'd68;
        // Latency_odd = 4'd4;
        // RegWriteOdd_in = 1; 

        // @(negedge clk);
        // instr_even   = 32'h1D004001;
        // RA_addr_even = 7'd0;   // r0
        // RT_addr_even = 7'd2;   // r1
        // ID_even      = 7'd2;
        // Latency_even = 4'd3;
        // RegWriteEven_in = 1; 

        // instr_odd  = 32'h3F604082;
        // RA_addr_odd = 7'd1;   // r1
        // RT_addr_odd = 7'd3;   // r2
        // ID_odd     = 7'd68;
        // Latency_odd = 4'd4;
        // RegWriteOdd_in = 1; 

        // @(negedge clk);
        // instr_even   = 32';
        // RA_addr_even = 7'd;   // r0
        // RT_addr_even = 7'd;   // r3
        // ID_even      = 7'd;
        // Latency_even = 4'd;
        // RegWriteEven_in = 1; 

        repeat(20) @(posedge clk);

        $display("TB: done");
        $finish;
    end

endmodule