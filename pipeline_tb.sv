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
    logic [0:31] BTA;
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
        .BTA       (BTA)
    );

    initial begin
        rst_n        = 0;
        RA_addr_even = 0; RB_addr_even = 0; RC_addr_even = 0; RT_addr_even = 0;
        instr_even   = 0; ID_even      = 0; Latency_even = 0; RegWriteEven_in = 0;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;
        PC           = 0;

        @(posedge clk);
        #1;
        rst_n        = 1;
        //ahi r2,r0,1
        RA_addr_even = 0; RB_addr_even = 0; RC_addr_even = 0; RT_addr_even = 7'd2;
        instr_even   = 32'h1d004002; ID_even  = 7'd2; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //ai r3,r0,2
        RA_addr_even = 0; RB_addr_even = 0; RC_addr_even = 0; RT_addr_even = 7'd3;
        instr_even   = 32'h1c008003; ID_even  = 7'd4; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;
        
        @(posedge clk);
        #1;
        //SFHI r4, r0, 1
        RA_addr_even = 0; RB_addr_even = 0; RC_addr_even = 0; RT_addr_even = 7'd4;
        instr_even   = 32'h0d004004; ID_even  = 7'd10; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //SFI r5, r0, 2
        RA_addr_even = 0; RB_addr_even = 0; RC_addr_even = 0; RT_addr_even = 7'd5;
        instr_even   = 32'h0c008005; ID_even  = 7'd12; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //ANDHI r6, r2, 3
        RA_addr_even = 7'd2; RB_addr_even = 0; RC_addr_even = 0; RT_addr_even = 7'd6;
        instr_even   = 32'h1500c106; ID_even  = 7'd14; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //ANDI r7, r3, 3
        RA_addr_even = 7'd3; RB_addr_even = 0; RC_addr_even = 0; RT_addr_even = 7'd7;
        instr_even   = 32'h1400c187; ID_even  = 7'd15; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //ORHI r8, r4, 1
        RA_addr_even = 7'd4; RB_addr_even = 0; RC_addr_even = 0; RT_addr_even = 7'd8;
        instr_even   = 32'h05004208; ID_even  = 7'd17; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //ORI r9, r4, 1
        RA_addr_even = 7'd4; RB_addr_even = 0; RC_addr_even = 0; RT_addr_even = 7'd9;
        instr_even   = 32'h04004209; ID_even  = 7'd18; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //XORHI r10, r6, 3
        RA_addr_even = 7'd6; RB_addr_even = 0; RC_addr_even = 0; RT_addr_even = 7'd10;
        instr_even   = 32'h4500c30a; ID_even  = 7'd20; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //XORI r11, r6, 3
        RA_addr_even = 7'd6; RB_addr_even = 0; RC_addr_even = 0; RT_addr_even = 7'd11;
        instr_even   = 32'h4400c30b; ID_even  = 7'd21; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //AH r12, r2, r3
        RA_addr_even = 7'd2; RB_addr_even = 7'd3; RC_addr_even = 0; RT_addr_even = 7'd12;
        instr_even   = 32'h1900c10c; ID_even  = 7'd1; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //A r13, r2, r3
        RA_addr_even = 7'd2; RB_addr_even = 7'd3; RC_addr_even = 0; RT_addr_even = 7'd13;
        instr_even   = 32'h1800c10d; ID_even  = 7'd3; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //CG r14, r10, r11
        RA_addr_even = 7'd10; RB_addr_even = 7'd11; RC_addr_even = 0; RT_addr_even = 7'd14;
        instr_even   = 32'h1842c50e; ID_even  = 7'd6; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //SFX r15, r10, r2
        RA_addr_even = 7'd10; RB_addr_even = 7'd2; RC_addr_even = 0; RT_addr_even = 7'd15;
        instr_even   = 32'h6820850f; ID_even  = 7'd7; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //BG r16, r10, r11
        RA_addr_even = 7'd10; RB_addr_even = 7'd11; RC_addr_even = 0; RT_addr_even = 7'd16;
        instr_even   = 32'h0842c510; ID_even  = 7'd8; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //SFH r17, r7, r8
        RA_addr_even = 7'd7; RB_addr_even = 7'd8; RC_addr_even = 0; RT_addr_even = 7'd17;
        instr_even   = 32'h09020391; ID_even  = 7'd9; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;
        
        @(posedge clk);
        #1;
        //SF r18, r5, r6
        RA_addr_even = 7'd5; RB_addr_even = 7'd6; RC_addr_even = 0; RT_addr_even = 7'd18;
        instr_even   = 32'h08018292; ID_even  = 7'd11; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //AND r19, r11, r4
        RA_addr_even = 7'd11; RB_addr_even = 7'd4; RC_addr_even = 0; RT_addr_even = 7'd19;
        instr_even   = 32'h18210593; ID_even  = 7'd13; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //OR r20, r4, r10
        RA_addr_even = 7'd4; RB_addr_even = 7'd10; RC_addr_even = 0; RT_addr_even = 7'd20;
        instr_even   = 32'h08228214; ID_even  = 7'd16; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //XOR r21, r11, r2 
        RA_addr_even = 7'd11; RB_addr_even = 7'd2; RC_addr_even = 0; RT_addr_even = 7'd21;
        instr_even   = 32'h48208595; ID_even  = 7'd19; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //NAND r22, r10, r11
        RA_addr_even = 7'd10; RB_addr_even = 7'd11; RC_addr_even = 0; RT_addr_even = 7'd22;
        instr_even   = 32'h1922c516; ID_even  = 7'd22; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //NOR r23, r10, r11
        RA_addr_even = 7'd10; RB_addr_even = 7'd11; RC_addr_even = 0; RT_addr_even = 7'd23;
        instr_even   = 32'h0922c517; ID_even  = 7'd23; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //CLZ r24, R20
        RA_addr_even = 7'd20; RB_addr_even = 7'd0; RC_addr_even = 0; RT_addr_even = 7'd24;
        instr_even   = 32'h54a00a18; ID_even  = 7'd24; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //FSMH	r25, r21
        RA_addr_even = 7'd21; RB_addr_even = 7'd0; RC_addr_even = 0; RT_addr_even = 7'd25;
        instr_even   = 32'h36a00a99; ID_even  = 7'd25; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //FSM r26, r21
        RA_addr_even = 7'd21; RB_addr_even = 7'd0; RC_addr_even = 0; RT_addr_even = 7'd26;
        instr_even   = 32'h36800a9a; ID_even  = 7'd26; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //CEQH r27, r20, r11
        RA_addr_even = 7'd20; RB_addr_even = 7'd11; RC_addr_even = 0; RT_addr_even = 7'd27;
        instr_even   = 32'h7902ca1b; ID_even  = 7'd27; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //CEQHI r28,  r11, -1
        RA_addr_even = 7'd11; RB_addr_even = 7'd0; RC_addr_even = 0; RT_addr_even = 7'd28;
        instr_even   = 32'h7dffc59c; ID_even  = 7'd28; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //CEQ r29, r20, r25
        RA_addr_even = 7'd20; RB_addr_even = 7'd25; RC_addr_even = 0; RT_addr_even = 7'd29;
        instr_even   = 32'h78064a1d; ID_even  = 7'd29; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //CEQI r30, r11, -1
        RA_addr_even = 7'd11; RB_addr_even = 7'd0; RC_addr_even = 0; RT_addr_even = 7'd30;
        instr_even   = 32'h7cffc59e; ID_even  = 7'd30; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //CGTH r31, r21, r27
        RA_addr_even = 7'd21; RB_addr_even = 7'd27; RC_addr_even = 0; RT_addr_even = 7'd31;
        instr_even   = 32'h4906ca9f; ID_even  = 7'd31; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //CGTHI r32, r21, -1
        RA_addr_even = 7'd21; RB_addr_even = 7'd0; RC_addr_even = 0; RT_addr_even = 7'd32;
        instr_even   = 32'h4dffcaa0; ID_even  = 7'd32; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //CGT r33, r22, r23
        RA_addr_even = 7'd22; RB_addr_even = 7'd23; RC_addr_even = 0; RT_addr_even = 7'd33;
        instr_even   = 32'h4805cb21; ID_even  = 7'd33; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //ILH r34, 16
        RA_addr_even = 7'd0; RB_addr_even = 7'd0; RC_addr_even = 0; RT_addr_even = 7'd34;
        instr_even   = 32'h4805cb21; ID_even  = 7'd39; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //ILHU r35, 16
        RA_addr_even = 7'd0; RB_addr_even = 7'd0; RC_addr_even = 0; RT_addr_even = 7'd35;
        instr_even   = 32'h41000823; ID_even  = 7'd40; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //SHLH r36, r2, r4
        RA_addr_even = 7'd2; RB_addr_even = 7'd4; RC_addr_even = 0; RT_addr_even = 7'd36;
        instr_even   = 32'h0be10124; ID_even  = 7'd45; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        @(posedge clk);
        #1;
        //ROTH r37, r10, r2
        RA_addr_even = 7'd10; RB_addr_even = 7'd2; RC_addr_even = 0; RT_addr_even = 7'd37;
        instr_even   = 32'h0b808525; ID_even  = 7'd49; Latency_even = 7'd3; RegWriteEven_in = 1;
        RA_addr_odd  = 0; RB_addr_odd  = 0; RT_addr_odd  = 0;
        instr_odd    = 0; ID_odd       = 0; Latency_odd  = 0; RegWriteOdd_in = 0;

        repeat(20) @(posedge clk);

        $display("TB: done");
        $finish;
    end

endmodule