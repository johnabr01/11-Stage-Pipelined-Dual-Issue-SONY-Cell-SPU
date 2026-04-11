module top_level (
    input clk,
    input rst_n
);

    // ID stage outputs / ID_EX inputs
    logic [0:6]  RA_addr_even_id, RB_addr_even_id, RC_addr_even_id;
    logic [0:31] instr_even_id;
    logic [0:6]  ID_even_id;
    logic [0:3]  Latency_even_id;
    logic [0:6]  RT_addr_even_id;
    logic        RegWriteEven_id;

    logic [0:31] PC_id;
    logic [0:6]  RA_addr_odd_id, RB_addr_odd_id;
    logic [0:31] instr_odd_id;
    logic [0:6]  ID_odd_id;
    logic [0:3]  Latency_odd_id;
    logic [0:6]  RT_addr_odd_id;
    logic        RegWriteOdd_id;

    // ID_EX outputs / EX inputs
    logic [0:6]  RA_addr_even_ex, RB_addr_even_ex, RC_addr_even_ex;
    logic [0:31] instr_even_ex;
    logic [0:6]  ID_even_ex;
    logic [0:3]  Latency_even_ex;
    logic [0:6]  RT_addr_even_ex;
    logic        RegWriteEven_ex;

    logic [0:31] PC_ex;
    logic [0:6]  RA_addr_odd_ex, RB_addr_odd_ex;
    logic [0:31] instr_odd_ex;
    logic [0:6]  ID_odd_ex;
    logic [0:3]  Latency_odd_ex;
    logic [0:6]  RT_addr_odd_ex;
    logic        RegWriteOdd_ex;

    // Execute outputs
    logic [0:31] BTA;
    logic        BT;

    logic [0:31] instr1;
    logic [0:31] instr2;

    logic [0:31] pc_out;
    logic [0:31] PC;


    program_counter u_program_counter(
        .pc_next(pc_next),
        .clk(clk),
        .rst_n(rst_n),
        .pc_write(1'b1), //MAKE SURE TO CHANGE AFTER IMPLEMENTING DECODE LOGIC
        .pc_out(pc_out)
    );

    instruction_memory u_instruction_memory (
        .address  (pc_out),
        .instr1   (instr1),
        .instr2   (instr2)
    );

    IF_ID_reg u_IF_ID_reg (
        .pc_in(pc_out),
        .pc_out(PC),
        .instr1(instr1),
        .instr2(instr2),
        .flush(1'b0) //MAKE SURE TO CHANGE AFTER IMPLEMENTING DECODE LOGIC
    );
    
    decode_stage u_decode_stage (
    .clk            (clk),
    .rst_n          (rst_n),

    .instr_even     (instr1),
    .instr_odd      (instr2),

    .RT_even        (RT_addr_even_id),
    .RA_even        (RA_addr_even_id),
    .RB_even        (RB_addr_even_id),
    .RC_even        (RC_addr_even_id),
    .ID_even        (ID_even_id),
    .Latency_even   (Latency_even_id),
    .RegWrite_even  (RegWriteEven_id),

    .RT_odd         (RT_addr_odd_id),
    .RA_odd         (RA_addr_odd_id),
    .RB_odd         (RB_addr_odd_id),
    .ID_odd         (ID_odd_id),
    .Latency_odd    (Latency_odd_id),
    .RegWrite_odd   (RegWriteOdd_id)
);


    ID_EX_reg u_ID_EX_reg (
        .clk              (clk),
        .rst_n            (rst_n),
        .flush            (1'b0), //MAKE SURE TO CHANGE AFTER IMPLEMENTING DECODE LOGIC
        .stall            (1'b0), //MAKE SURE TO CHANGE AFTER IMPLEMENTING HAZARD DETECTION LOGIC

        .RA_addr_even_in  (RA_addr_even_id),
        .RB_addr_even_in  (RB_addr_even_id),
        .RC_addr_even_in  (RC_addr_even_id),
        .instr_even_in    (instr_even_id),
        .ID_even_in       (ID_even_id),
        .Latency_even_in  (Latency_even_id),
        .RT_addr_even_in  (RT_addr_even_id),
        .RegWriteEven_in  (RegWriteEven_id),

        .PC_in            (PC_id),
        .RA_addr_odd_in   (RA_addr_odd_id),
        .RB_addr_odd_in   (RB_addr_odd_id),
        .instr_odd_in     (instr_odd_id),
        .ID_odd_in        (ID_odd_id),
        .Latency_odd_in   (Latency_odd_id),
        .RT_addr_odd_in   (RT_addr_odd_id),
        .RegWriteOdd_in   (RegWriteOdd_id),

        .RA_addr_even_out (RA_addr_even_ex),
        .RB_addr_even_out (RB_addr_even_ex),
        .RC_addr_even_out (RC_addr_even_ex),
        .instr_even_out   (instr_even_ex),
        .ID_even_out      (ID_even_ex),
        .Latency_even_out (Latency_even_ex),
        .RT_addr_even_out (RT_addr_even_ex),
        .RegWriteEven_out (RegWriteEven_ex),

        .PC_out           (PC_ex),
        .RA_addr_odd_out  (RA_addr_odd_ex),
        .RB_addr_odd_out  (RB_addr_odd_ex),
        .instr_odd_out    (instr_odd_ex),
        .ID_odd_out       (ID_odd_ex),
        .Latency_odd_out  (Latency_odd_ex),
        .RT_addr_odd_out  (RT_addr_odd_ex),
        .RegWriteOdd_out  (RegWriteOdd_ex)
    );

    execute u_execute (
        .clk             (clk),
        .rst_n           (rst_n),

        .RA_addr_even    (RA_addr_even_ex),
        .RB_addr_even    (RB_addr_even_ex),
        .RC_addr_even    (RC_addr_even_ex),
        .instr_even      (instr_even_ex),
        .ID_even         (ID_even_ex),
        .Latency_even    (Latency_even_ex),
        .RT_addr_even    (RT_addr_even_ex),
        .RegWriteEven_in (RegWriteEven_ex),

        .PC              (PC_ex),
        .RA_addr_odd     (RA_addr_odd_ex),
        .RB_addr_odd     (RB_addr_odd_ex),
        .instr_odd       (instr_odd_ex),
        .ID_odd          (ID_odd_ex),
        .Latency_odd     (Latency_odd_ex),
        .RT_addr_odd     (RT_addr_odd_ex),
        .RegWriteOdd_in  (RegWriteOdd_ex),

        .BTA             (BTA),
        .BT              (BT)
    );

endmodule