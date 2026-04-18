import packet_pkg::*;

module top_level #(
    localparam LAST_STAGE = 7
)(
    input clk,
    input rst_n
);

    // IF / ID register outputs
    logic single_issue_stall;
    logic single_issue_stall_prev;

    logic instr1_issued;
    logic instr1_issued_prev;

    logic instr2_issued;
    logic instr2_issued_prev;

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

    logic        RT_source_instr1;
    logic        RA_source_instr1;
    logic        RB_source_instr1;
    logic        RC_source_instr1;
    logic [0:6]  RT_addr1;
    logic [0:6]  RA_addr1;
    logic [0:6]  RB_addr1;
    logic [0:6]  RC_addr1;
    logic instr1_data_hazard;

    logic        RT_source_instr2;
    logic        RA_source_instr2;
    logic        RB_source_instr2;
    logic        RC_source_instr2;
    logic [0:6]  RT_addr2;
    logic [0:6]  RA_addr2;
    logic [0:6]  RB_addr2;
    logic [0:6]  RC_addr2;

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

    //Data hazard ID / EX signals
    logic RT_source_even_id;
    logic RA_source_even_id;
    logic RB_source_even_id;
    logic RC_source_even_id;

    logic RT_source_odd_id;
    logic RA_source_odd_id;
    logic RB_source_odd_id;

    logic RT_source_even_ex;
    logic RA_source_even_ex;
    logic RB_source_even_ex;
    logic RC_source_even_ex;

    logic RT_source_odd_ex;
    logic RA_source_odd_ex;
    logic RB_source_odd_ex;

    logic instr1_data_hazard;
    logic instr1_rf_hazard;
    logicc instr1_pipe_hazard;

    // Execute outputs
    logic [0:31] BTA;
    logic        BT;

    logic [0:31] instr1_comb;
    logic [0:31] instr2_comb;
    
    logic [0:31] instr1_id_in;
    logic [0:31] instr2_id_in;

    logic [0:31] instr1;
    logic [0:31] instr2;

    logic [0:31] pc_out;
    logic [0:31] PC;

    even_packet even_pkt_pipes [0:LAST_STAGE - 1];
    odd_packet odd_pkt_pipes [0:LAST_STAGE - 1];

    program_counter u_program_counter(
        .pc_next(pc_next),
        .clk(clk),
        .rst_n(rst_n),
        .pc_write(1'b1), //MAKE SURE TO CHANGE AFTER IMPLEMENTING DECODE LOGIC
        .pc_out(pc_out)
    );

    instruction_memory u_instruction_memory (
        .address  (pc_out),
        .instr1   (instr1_comb),
        .instr2   (instr2_comb)
    );

    assign instr1_id_in = (single_issue_stall) ? instr1 : instr1_comb;
    assign instr2_id_in = (single_issue_stall) ? instr2 : instr2_comb;

    IF_ID_reg u_IF_ID_reg(
        .pc_in(pc_out),
        .clk(clk),
        .rst_n(rst_n),
        .instr1_in(instr1_id_in),
        .instr2_in(instr2_id_in),
        .single_issue_stall_in(single_issue_stall), //from decode logic.
        .instr1_issued_in(instr1_issued),
        
        .instr1_out(instr1),
        .instr2_out(instr2),
        .pc_out(PC),
        .single_issue_stall_out(single_issue_stall_prev), //output is the new input to our hazard/decode logic stage
        .instr1_issued_out(instr1_issued_prev)
        // .flush(1'b0), //MAKE SURE TO CHANGE AFTER IMPLEMENTING DECODE LOGIC
        // .stall(1'b0) //MAKE SURE TO CHANGE AFTER IMPLEMENTING DECODE LOGIC
    );

    // IF_ID_reg u_IF_ID_reg (
    //     .pc_in(pc_out),
    //     .pc_out(PC),
    //     .instr1(instr1),
    //     .instr2(instr2),
    //     .flush(1'b0) //MAKE SURE TO CHANGE AFTER IMPLEMENTING DECODE LOGIC
    // );
    
    decode_stage u1_decode (
        .clk            (clk),
        .rst_n          (rst_n),

        .instr     (instr1),

        .RT        (RT_addr1),
        .RA        (RA_addr1),
        .RB        (RB_addr1),
        .RC        (RC_addr1),
        .ID        (ID1),
        .Latency   (Latency1),
        .RegWrite  (RegWrite1),
        .Instr_type(Instr_type1)
    );

    decode_stage u2_decode (
        .clk            (clk),
        .rst_n          (rst_n),

        .instr     (instr2),

        .RT        (RT_addr2),
        .RA        (RA_addr2),
        .RB        (RB_addr2),
        .RC        (RC_addr2),
        .ID        (ID2),
        .Latency   (Latency2),
        .RegWrite  (RegWrite2),
        .Instr_type(Instr_type2)
    );


    //Notes: For hazard detection, we need to keep track of which source registers are being used (i.e. RA, RB, RC). New signals?
    //We also need to know if Rt is being used as a destination or a source (Easy. condition isRegWrite == 0?)
    //Process to find if we have a data hazard: Iterate through both even and odd pipe, see if we encounter destination
    //equal to one of our sources and if curr_stage_counter + 1 < latency, we need to stall
    //data hazard for second instr exists if first instr writes and second instr reads that register

        //For branching: 
            //If branch taken signal != branch prediction, flush EVERYTHING that precedes the branch, and set PC's next value to BTA
            //Moreover, if BRANCH target address is multiple of 4, don't attempt to issue first instruction
            //Branch flush has priority over single issue because we need to wipe those instructions anyways
    assign instr1_data_hazard = instr1_rf_hazard || instr1_pipe_hazard;
    always_comb begin
        //No data hazard for first instruction: None of the instructions in the next stage or
        //in either pipe writes to rd and isn't completed yet (most recent)
        instr1_data_hazard = 0;
        instr1_pipe_hazard = 0;
        if ((RegWriteEven_ex && RT_source_instr1 && (RT_addr_even_ex == RT_addr1)) ||
            (RegWriteEven_ex && RA_source_instr1 && (RT_addr_even_ex == RA_addr1)) ||
            (RegWriteEven_ex && RB_source_instr1 && (RT_addr_even_ex == RB_addr1)) ||
            (RegWriteEven_ex && RC_source_instr1 && (RT_addr_even_ex == RC_addr1)) ||
            
            (RegWriteOdd_ex && RT_source_instr1 && (RT_addr_odd_ex == RT_addr1)) ||
            (RegWriteOdd_ex && RA_source_instr1 && (RT_addr_odd_ex == RA_addr1)) ||
            (RegWriteOdd_ex && RB_source_instr1 && (RT_addr_odd_ex == RB_addr1))) 
        begin
                instr1_rf_hazard = 1;
        end
            
        for(int i = 0; i < LAST_STAGE; i++) begin
            if ((even_pkt_pipes[i].RegWr && RT_source_instr1 && 
                (even_pkt_pipes[i].dest_addr == RT_addr1)) begin
                    if((even_pkt_pipes[i].curr_stage_counter + 1) < even_pkt_pipes[i].latency) begin
                        instr1_pipe_hazard = 1;
                        break;
                    end
            end
        end
        // check for first instruction data hazard
        // once there's no data hazard in first instruction, 
        // check second instruction's data hazard and which pipe it belongs to and check if destination address == first instr destination address
        // if either data hazard or belongs to same pipe or rd1==rd2, only issue first instruction,
        // and then attempt to issue the second instruction on next clock cycle (assuming no data hazard)
        // Don't flush if instr, branch

        //For branching: 
        //If branch taken signal != branch prediction, flush EVERYTHING that precedes the branch, and set PC's next value to BTA
        //Moreover, if BRANCH target address is multiple of 4, don't attempt to issue first instruction

        // if(first_instr_no_data_hazard && first_instr_not_issued_yet) begin
        //     if(second_instruction_no_data_hazard && second_instruction_different_pipe && second_instruction_different_rd) begin
        //         //dual issue, prepare to increment PC
        //     end
        //     else
        //         //single issue
        //         //state issued first one
        // end
        // else if(first_instr_issued && second_instruction_not_issued) begin
        //     if(second_instruction_no_data_hazard) begin
        //         //single issue second instruction and prepare to increment PC
        //     end
        // end
    end

    always_comb begin
        if ((Instr_type1 == EVENTYPE) && (Instr_type2 == ODDTYPE)) begin
            RA_addr_even_id = RA_addr1;
            RB_addr_even_id = RB_addr1;
            RC_addr_even_id = RC_addr1;
            instr_even_id   = instr1;
            ID_even_id      = ID1;
            Latency_even_id = Latency1;
            RT_addr_even_id = RT_addr1;
            RegWriteEven_id = RegWrite1;

            PC_id           = PC;

            RA_addr_odd_id  = RA_addr2;
            RB_addr_odd_id  = RB_addr2;
            instr_odd_id    = instr2;
            ID_odd_id       = ID2;
            Latency_odd_id  = Latency2;
            RT_addr_odd_id  = RT_addr2;
            RegWriteOdd_id  = RegWrite2;
        end
        else if ((Instr_type1 == ODDTYPE) && (Instr_type2 == EVENTYPE)) begin
            RA_addr_even_id = RA_addr2;
            RB_addr_even_id = RB_addr2;
            RC_addr_even_id = RC_addr2;
            instr_even_id   = instr2;
            ID_even_id      = ID2;
            Latency_even_id = Latency2;
            RT_addr_even_id = RT_addr2;
            RegWriteEven_id = RegWrite2;

            PC_id           = PC;

            RA_addr_odd_id  = RA_addr1;
            RB_addr_odd_id  = RB_addr1;
            instr_odd_id    = instr1;
            ID_odd_id       = ID1;
            Latency_odd_id  = Latency1;
            RT_addr_odd_id  = RT_addr1;
            RegWriteOdd_id  = RegWrite1;
        end

        else if (Instr_type1 == EVENTYPE && Instr_type2 == EVENTYPE) begin
            RA_addr_even_id = RA_addr1;
            RB_addr_even_id = RB_addr1;
            RC_addr_even_id = RC_addr1;
            instr_even_id   = instr1;
            ID_even_id      = ID1;
            Latency_even_id = Latency1;
            RT_addr_even_id = RT_addr1;
            RegWriteEven_id = RegWrite1;
        end
        else if ( no_data_hazard && Instr_type1 == ODDTYPE && Instr_type2 == ODDTYPE) begin
            RA_addr_odd_id  = RA_addr1;
            RB_addr_odd_id  = RB_addr1;
            instr_odd_id    = instr1;
            ID_odd_id       = ID1;
            Latency_odd_id  = Latency1;
            RT_addr_odd_id  = RT_addr1;
            RegWriteOdd_id  = RegWrite1;

            if(!instr1_issued) instr1_issued = 1'b1;
            else begin
                instr1_issued = 1'b1;
                instr2_issued = 1'b1;
            end
        end


        elseif (ID1 == 99 || ) begin
            
        end

        else 
    end

    ID_EX_reg u_ID_EX_reg (
        .clk              (clk),
        .rst_n            (rst_n),
        .flush            (1'b0), // MAKE SURE TO CHANGE AFTER IMPLEMENTING DECODE LOGIC
        .stall            (1'b0), // MAKE SURE TO CHANGE AFTER IMPLEMENTING HAZARD DETECTION LOGIC

        // Even pipe inputs
        .RA_addr_even_in  (RA_addr_even_id),
        .RB_addr_even_in  (RB_addr_even_id),
        .RC_addr_even_in  (RC_addr_even_id),
        .instr_even_in    (instr_even_id),
        .ID_even_in       (ID_even_id),
        .Latency_even_in  (Latency_even_id),
        .RT_addr_even_in  (RT_addr_even_id),
        .RegWriteEven_in  (RegWriteEven_id),

        .RT_source_even_id (RT_source_even_id),
        .RA_source_even_id (RA_source_even_id),
        .RB_source_even_id (RB_source_even_id),
        .RC_source_even_id (RC_source_even_id),

        // Odd pipe inputs
        .PC_in            (PC_id),
        .RA_addr_odd_in   (RA_addr_odd_id),
        .RB_addr_odd_in   (RB_addr_odd_id),
        .instr_odd_in     (instr_odd_id),
        .ID_odd_in        (ID_odd_id),
        .Latency_odd_in   (Latency_odd_id),
        .RT_addr_odd_in   (RT_addr_odd_id),
        .RegWriteOdd_in   (RegWriteOdd_id),

        .RT_source_odd_id (RT_source_odd_id),
        .RA_source_odd_id (RA_source_odd_id),
        .RB_source_odd_id (RB_source_odd_id),

        // Even pipe outputs
        .RA_addr_even_out (RA_addr_even_ex),
        .RB_addr_even_out (RB_addr_even_ex),
        .RC_addr_even_out (RC_addr_even_ex),
        .instr_even_out   (instr_even_ex),
        .ID_even_out      (ID_even_ex),
        .Latency_even_out (Latency_even_ex),
        .RT_addr_even_out (RT_addr_even_ex),
        .RegWriteEven_out (RegWriteEven_ex),

        // .RT_source_even_out (RT_source_even_ex),
        // .RA_source_even_out (RA_source_even_ex),
        // .RB_source_even_out (RB_source_even_ex),
        // .RC_source_even_out (RC_source_even_ex),

        // Odd pipe outputs
        .PC_out           (PC_ex),
        .RA_addr_odd_out  (RA_addr_odd_ex),
        .RB_addr_odd_out  (RB_addr_odd_ex),
        .instr_odd_out    (instr_odd_ex),
        .ID_odd_out       (ID_odd_ex),
        .Latency_odd_out  (Latency_odd_ex),
        .RT_addr_odd_out  (RT_addr_odd_ex),
        .RegWriteOdd_out  (RegWriteOdd_ex)

        // .RT_source_odd_out (RT_source_odd_ex),
        // .RA_source_odd_out (RA_source_odd_ex),
        // .RB_source_odd_out (RB_source_odd_ex)
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
        .BT              (BT),
        .odd_pkt_pipes   (odd_pkt_pipes),
        .even_pkt_pipes  (even_pkt_pipes)
    );

endmodule