import packet_pkg::*;

module top_level #(
    localparam LAST_STAGE = 8,
    localparam EVENTYPE = 0,
    localparam ODDTYPE = 1
)(
    input clk,
    input rst_n
);

    // IF / ID register outputs
    logic stall;
    logic stall_prev;

    logic ignore_instr1;
    logic instr1_issued;
    logic instr1_issued_prev;

    // logic instr2_issued;
    // logic instr2_issued_prev;

    // ID stage outputs / ID_EX inputs
    logic [0:6]  RA_addr_even_id, RB_addr_even_id, RC_addr_even_id;
    logic [0:31] instr_even_id;
    logic [0:6]  ID_even_id;
    logic [0:3]  Latency_even_id;
    logic [0:6]  RT_addr_even_id;
    logic        RegWriteEven_id;
    logic [0:1]  instr_order_even_id;
    

    logic [0:31] PC_id;
    logic [0:6]  RA_addr_odd_id, RB_addr_odd_id;
    logic [0:31] instr_odd_id;
    logic [0:6]  ID_odd_id;
    logic [0:3]  Latency_odd_id;
    logic [0:6]  RT_addr_odd_id;
    logic        RegWriteOdd_id;
    logic [0:1]  instr_order_odd_id;

    logic        RT_source_instr1;
    logic        RA_source_instr1;
    logic        RB_source_instr1;
    logic        RC_source_instr1;
    logic [0:6]  RT_addr1;
    logic [0:6]  RA_addr1;
    logic [0:6]  RB_addr1;
    logic [0:6]  RC_addr1;
    logic instr1_data_hazard;
    logic instr1_rf_hazard;
    logic instr1_pipe_hazard;

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
    logic [0:1]  instr_order_even_ex;

    logic [0:31] PC_ex;
    logic [0:6]  RA_addr_odd_ex, RB_addr_odd_ex;
    logic [0:31] instr_odd_ex;
    logic [0:6]  ID_odd_ex;
    logic [0:3]  Latency_odd_ex;
    logic [0:6]  RT_addr_odd_ex;
    logic        RegWriteOdd_ex;
    logic [0:1]  instr_order_odd_ex;
   
    logic instr2_data_hazard;
    logic instr2_rf_hazard;
    logic instr2_pipe_hazard;
    logic instr2_decode_hazard;

    logic structural_hazard;
    logic flush;

    // Execute outputs
    logic [0:31] BTA;
    logic        BT;

    logic [0:31] BTA_delayed;
    logic BT_delayed;

    logic [0:31] instr1_comb;
    logic [0:31] instr2_comb;
    
    logic [0:31] instr1_if_in;
    logic [0:31] instr2_if_in;

    logic [0:31] instr1;
    logic [0:31] instr2;

    logic [0:31] pc_out;
    logic [0:31] PC;

    logic [0:31] pc_next;

    logic [0:6] ID1, ID2;
    logic [0:3] Latency1, Latency2;

    even_packet even_pkt_pipes [0:LAST_STAGE - 1];
    odd_packet odd_pkt_pipes [0:LAST_STAGE - 1];

    logic stop;

    assign pc_next = BT ? (BTA & 32'hFFFFFFF8) : pc_out + 8; //check if branch is asserted. if so, pc_next gets BTA (& 0x08), else PC + 4
    assign ignore_instr1 = (BT_delayed && BTA_delayed[29]) | instr1_issued; 
    //if BTA[29] == 1 and BT is set or instr1_issued == 1, ignore instruction 1

    assign pc_write = ~stall | BT;

    always_ff @(posedge clk) begin
        if(!rst_n) begin
            BT_delayed <= 0;
            BTA_delayed <= 0;
        end else begin 
            BT_delayed <= BT;
            BTA_delayed <= BTA;
        end
    end

    program_counter u_program_counter(
        .pc_next(pc_next),
        .clk(clk),
        .rst_n(rst_n),
        .pc_write(pc_write), //@TODO: MAKE SURE TO CHANGE AFTER HAZARD LOGIC FOR BRANCH
        .pc_out(pc_out)
    );

    instruction_memory u_instruction_memory (
        .address  (pc_out),
        .instr1   (instr1_comb),
        .instr2   (instr2_comb)
    );

    assign instr1_if_in = (stall && (BT != 1)) ? instr1 : instr1_comb;
    assign instr2_if_in = (stall && (BT != 1)) ? instr2 : instr2_comb;

    //stall means that if instr1_issued is 1, we repeat instruction inputs
    assign stall = instr1_issued | (instr1_data_hazard && !instr1_issued_prev) | instr2_data_hazard;

    IF_ID_reg u_IF_ID_reg(
        .pc_in(pc_out),
        .clk(clk),
        .rst_n(rst_n),
        .instr1_in(instr1_if_in),
        .instr2_in(instr2_if_in),
        // .stall_in(stall), //from decode logic.
        .instr1_issued_in(ignore_instr1),
        
        .instr1_out(instr1),
        .instr2_out(instr2),
        .pc_out(PC),
        // .stall_out(stall_prev), //output is the new input to our hazard/decode logic stage
        .instr1_issued_out(instr1_issued_prev),
        .flush(flush) //MAKE SURE TO CHANGE AFTER IMPLEMENTING DECODE LOGIC
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
        .Instr_type(Instr_type1),

        .RT_source(RT_source_instr1),
        .RA_source(RA_source_instr1),
        .RB_source(RB_source_instr1),
        .RC_source(RC_source_instr1)
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
        .Instr_type(Instr_type2),

        .RT_source(RT_source_instr2),
        .RA_source(RA_source_instr2),
        .RB_source(RB_source_instr2),
        .RC_source(RC_source_instr2)
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

    always_comb begin
        //No data hazard for first instruction: None of the instructions in the next stage or
        //in either pipe writes to rd and isn't completed yet (most recent)
        instr1_data_hazard = 0;
        instr1_pipe_hazard = 0;
        instr1_rf_hazard = 0; //default value 

        instr2_data_hazard = 0;
        instr2_pipe_hazard = 0;
        instr2_rf_hazard = 0; //default value
        instr2_decode_hazard = 0;


        if ((RegWriteEven_ex && RT_source_instr1 && (RT_addr_even_ex == RT_addr1)) ||    // if RT_addr in execute unit == RT_addr in decode unit, and the current instr uses RT as a source, then its a hazard.
            (RegWriteEven_ex && RA_source_instr1 && (RT_addr_even_ex == RA_addr1)) ||
            (RegWriteEven_ex && RB_source_instr1 && (RT_addr_even_ex == RB_addr1)) ||
            (RegWriteEven_ex && RC_source_instr1 && (RT_addr_even_ex == RC_addr1)) ||
            
            (RegWriteOdd_ex && RT_source_instr1 && (RT_addr_odd_ex == RT_addr1)) ||
            (RegWriteOdd_ex && RA_source_instr1 && (RT_addr_odd_ex == RA_addr1)) ||
            (RegWriteOdd_ex && RB_source_instr1 && (RT_addr_odd_ex == RB_addr1))) 
        begin
                instr1_rf_hazard = 1;
        end

        if ((RT_addr1 == RT_addr2) && !instr1_issued_prev && RegWrite1 && RegWrite2) structural_hazard = 1; //if both instructions have the same destination register, we can't dual issue because of structural hazard. We can only issue one instruction, and then the other instruction on the next cycle (assuming no data hazard).
        else structural_hazard = 0;

        if ((RegWrite1 && RT_source_instr2 && (RT_addr1 == RT_addr2)) ||    // if RT_addr in execute unit == RT_addr in decode unit, and the current instr uses RT as a source, then its a hazard.
           (RegWrite1 && RA_source_instr2 && (RT_addr1 == RA_addr2)) ||
           (RegWrite1 && RB_source_instr2 && (RT_addr1 == RB_addr2)) ||
           (RegWrite1 && RC_source_instr2 && (RT_addr1 == RC_addr2))) begin
                if(!instr1_issued_prev) instr2_decode_hazard = 1;
           end
            
        for(int i = 0; i < LAST_STAGE; i++) begin
            //----------RT checks------
            //checks if a destination register in the even pipe is our RT source in the decode stage.
            //the below two if statements is possible because no two instructions can have the same dest addr at the same stage.
            //If there is a case when two instructions have the same dest addr, we would need to stall one of them in the decode stage and thereby create a cycle offset for the writeback to occur.
            //Therefore, only one if block would execute.
            if (even_pkt_pipes[i].RegWr && RT_source_instr1 && 
                (even_pkt_pipes[i].dest_addr == RT_addr1)) begin
                    if((even_pkt_pipes[i].curr_stage_counter + 1) < even_pkt_pipes[i].latency) begin
                        instr1_pipe_hazard = 1;
                        break;
                    end
            end
            //odd pipe
            if (odd_pkt_pipes[i].RegWr && RT_source_instr1 && 
                (odd_pkt_pipes[i].dest_addr == RT_addr1)) begin
                    if((odd_pkt_pipes[i].curr_stage_counter + 1) < odd_pkt_pipes[i].latency) begin
                        instr1_pipe_hazard = 1;
                        break;
                    end
            end


            //---------RA checks------
            //checks if a destination register in the pipe is our RA source in the decode stage.
            if (even_pkt_pipes[i].RegWr && RA_source_instr1 && 
                (even_pkt_pipes[i].dest_addr == RA_addr1)) begin
                    if((even_pkt_pipes[i].curr_stage_counter + 1) < even_pkt_pipes[i].latency) begin
                        instr1_pipe_hazard = 1;
                        break;
                    end
            end
            //odd pipe
            if (odd_pkt_pipes[i].RegWr && RA_source_instr1 && 
                (odd_pkt_pipes[i].dest_addr == RA_addr1)) begin
                    if((odd_pkt_pipes[i].curr_stage_counter + 1) < odd_pkt_pipes[i].latency) begin
                        instr1_pipe_hazard = 1;
                        break;
                    end
            end

            //---------RB checks------
            //checks if a destination register in the pipe is our RB source in the decode stage.
            if (even_pkt_pipes[i].RegWr && RB_source_instr1 && 
                (even_pkt_pipes[i].dest_addr == RB_addr1)) begin
                    if((even_pkt_pipes[i].curr_stage_counter + 1) < even_pkt_pipes[i].latency) begin
                        instr1_pipe_hazard = 1;
                        break;
                    end
            end
            //odd pipe
            if (odd_pkt_pipes[i].RegWr && RB_source_instr1 && 
                (odd_pkt_pipes[i].dest_addr == RB_addr1)) begin
                    if((odd_pkt_pipes[i].curr_stage_counter + 1) < odd_pkt_pipes[i].latency) begin
                        instr1_pipe_hazard = 1;
                        break;
                    end
            end


            //---------RC checks------
            //checks if a destination register in the pipe is our RC source in the decode stage.
            if (even_pkt_pipes[i].RegWr && RC_source_instr1 && 
                (even_pkt_pipes[i].dest_addr == RC_addr1)) begin
                    if((even_pkt_pipes[i].curr_stage_counter + 1) < even_pkt_pipes[i].latency) begin
                        instr1_pipe_hazard = 1;
                        break;
                    end
            end
            //odd pipe
            if (odd_pkt_pipes[i].RegWr && RC_source_instr1 && 
                (odd_pkt_pipes[i].dest_addr == RC_addr1)) begin
                    if((odd_pkt_pipes[i].curr_stage_counter + 1) < odd_pkt_pipes[i].latency) begin
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

        if (!instr1_data_hazard) begin   //only when first instr has not data hazard, do we check the second instr.
            // instr2_data_hazard = 0;
            // instr2_pipe_hazard = 0;
            // instr2_rf_hazard = 0; //default value 

            if ((RegWriteEven_ex && RT_source_instr2 && (RT_addr_even_ex == RT_addr2)) ||    // if RT_addr in execute unit == RT_addr in decode unit, and the current instr uses RT as a source, then its a hazard.
                (RegWriteEven_ex && RA_source_instr2 && (RT_addr_even_ex == RA_addr2)) ||
                (RegWriteEven_ex && RB_source_instr2 && (RT_addr_even_ex == RB_addr2)) ||
                (RegWriteEven_ex && RC_source_instr2 && (RT_addr_even_ex == RC_addr2)) ||
                
                (RegWriteOdd_ex && RT_source_instr2 && (RT_addr_odd_ex == RT_addr2)) ||
                (RegWriteOdd_ex && RA_source_instr2 && (RT_addr_odd_ex == RA_addr2)) ||
                (RegWriteOdd_ex && RB_source_instr2 && (RT_addr_odd_ex == RB_addr2))) 
            begin
                    instr2_rf_hazard = 1;
            end
                
            for(int i = 0; i < LAST_STAGE; i++) begin
                //----------RT checks------
                //the below two if statements is possible because no two instructions can have the same dest addr at the same stage, i.e. same value of loop variable 'i'.
                //If there is a case when two instructions have the same dest addr, we would need to stall one of them in the decode stage and thereby create a cycle offset for the writeback to occur.
                if (even_pkt_pipes[i].RegWr && RT_source_instr2 && 
                    (even_pkt_pipes[i].dest_addr == RT_addr2)) begin    //checks if a destination register in the even pipe is our RT source in the decode stage.
                        if((even_pkt_pipes[i].curr_stage_counter + 1) < even_pkt_pipes[i].latency) begin
                            instr2_pipe_hazard = 1;
                            break;
                        end
                end
                //odd pipe
                if (odd_pkt_pipes[i].RegWr && RT_source_instr2 && 
                    (odd_pkt_pipes[i].dest_addr == RT_addr2)) begin
                        if((odd_pkt_pipes[i].curr_stage_counter + 1) < odd_pkt_pipes[i].latency) begin
                            instr2_pipe_hazard = 1;
                            break;
                        end
                end

                //---------RA checks------
                //checks if a destination register in the pipe is our RA source in the decode stage.
                if (even_pkt_pipes[i].RegWr && RA_source_instr2 && 
                    (even_pkt_pipes[i].dest_addr == RA_addr2)) begin
                        if((even_pkt_pipes[i].curr_stage_counter + 1) < even_pkt_pipes[i].latency) begin
                            instr2_pipe_hazard = 1;
                            break;
                        end
                end
                //odd pipe
                if (odd_pkt_pipes[i].RegWr && RA_source_instr2 && 
                    (odd_pkt_pipes[i].dest_addr == RA_addr2)) begin
                        if((odd_pkt_pipes[i].curr_stage_counter + 1) < odd_pkt_pipes[i].latency) begin
                            instr2_pipe_hazard = 1;
                            break;
                        end
                end

                //---------RB checks------
                //checks if a destination register in the pipe is our RB source in the decode stage.
                if (even_pkt_pipes[i].RegWr && RB_source_instr2 && 
                    (even_pkt_pipes[i].dest_addr == RB_addr2)) begin
                        if((even_pkt_pipes[i].curr_stage_counter + 1) < even_pkt_pipes[i].latency) begin
                            instr2_pipe_hazard = 1;
                            break;
                        end
                end
                //odd pipe
                if (odd_pkt_pipes[i].RegWr && RB_source_instr2 && 
                    (odd_pkt_pipes[i].dest_addr == RB_addr2)) begin
                        if((odd_pkt_pipes[i].curr_stage_counter + 1) < odd_pkt_pipes[i].latency) begin
                            instr2_pipe_hazard = 1;
                            break;
                        end
                end


                //---------RC checks------
                //checks if a destination register in the pipe is our RC source in the decode stage.
                if (even_pkt_pipes[i].RegWr && RC_source_instr2 && 
                    (even_pkt_pipes[i].dest_addr == RC_addr2)) begin
                        if((even_pkt_pipes[i].curr_stage_counter + 1) < even_pkt_pipes[i].latency) begin
                            instr2_pipe_hazard = 1;
                            break;
                        end
                end
                //odd pipe
                if (odd_pkt_pipes[i].RegWr && RC_source_instr2 && 
                    (odd_pkt_pipes[i].dest_addr == RC_addr2)) begin
                        if((odd_pkt_pipes[i].curr_stage_counter + 1) < odd_pkt_pipes[i].latency) begin
                            instr2_pipe_hazard = 1;
                            break;
                        end
                end
            end
        end

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
        instr1_data_hazard = instr1_rf_hazard | instr1_pipe_hazard;
        instr2_data_hazard = instr2_decode_hazard | instr2_rf_hazard | instr2_pipe_hazard;
    end

    assign PC_id = PC; //always pass PC as PC_id (combinational)

    
    //handle stall logic for instr 1 and instr 2
    always_comb begin
        instr1_issued = 0;

        //default odd pipe to HW no op
        RA_addr_odd_id  = 0;
        RB_addr_odd_id  = 0;
        instr_odd_id    = 0;
        ID_odd_id       = 0;
        Latency_odd_id  = 0;
        RT_addr_odd_id  = 0;
        RegWriteOdd_id  = 0;
        instr_order_odd_id = 0;

        //default even pipe to HW No op
        RA_addr_even_id = 0;
        RB_addr_even_id = 0;
        RC_addr_even_id = 0;
        instr_even_id   = 0;
        ID_even_id      = 0;
        Latency_even_id = 0;
        RT_addr_even_id = 0;
        RegWriteEven_id = 0;
        instr_order_even_id = 0;
        
        if (!BT) begin

            if (!stop) begin
                //if we're issuing the first instruction, go here
                //@TODO Note: might need to add a check for flash after (i.e. from branch), but that is okay
                //@TODO: WE HAVE TO ADD LOGIC TO SUPPORT FLUSHING ONE PIPE BECAUSE OF PC MULTIPLE (i.e. Branch to address divisible by 4)
                if(!instr1_data_hazard && !instr1_issued_prev) begin 
                    //if instr1 has no data hazard and we didn't issue it on last cycle, issue instruction 1
                    //This signal is only 1 if we issue 1st instruction, but not second instruction
                    instr1_issued = 1;
                    //we need to make sure we issue instruction 1 to the correct pipe
                    if (Instr_type1 == EVENTYPE) begin
                        RA_addr_even_id = RA_addr1;
                        RB_addr_even_id = RB_addr1;
                        RC_addr_even_id = RC_addr1;
                        instr_even_id   = instr1;
                        ID_even_id      = ID1;
                        Latency_even_id = Latency1;
                        RT_addr_even_id = RT_addr1;
                        RegWriteEven_id = RegWrite1;
                        instr_order_even_id = 1;

                    end else begin //Instr_type1 == ODDTYPE
                        RA_addr_odd_id  = RA_addr1;
                        RB_addr_odd_id  = RB_addr1;
                        instr_odd_id    = instr1;
                        ID_odd_id       = ID1;
                        Latency_odd_id  = Latency1;
                        RT_addr_odd_id  = RT_addr1;
                        RegWriteOdd_id  = RegWrite1;
                        instr_order_odd_id = 1;
                    end
                end

                //only check if both pipes are the same if instr1 wasn't already issued
                //(structural hazard)
                if(!instr1_issued_prev && !instr1_data_hazard) begin
                    //we only issue an instruction if both pipes aren't the same for dual issue (and instr 1 doesn't have an issue)
                    //which means we might dual issue
                    instr1_issued = 1; //default case (if instr_type2 == instr_type1)
                    if(Instr_type2 != Instr_type1 && !structural_hazard) begin
                        instr1_issued = 0; //reset instr1_issued flag because we're issuing both instructions
                        if (Instr_type2 == EVENTYPE) begin
                            RA_addr_even_id = RA_addr2;
                            RB_addr_even_id = RB_addr2;
                            RC_addr_even_id = RC_addr2;
                            instr_even_id   = instr2;
                            ID_even_id      = ID2;
                            Latency_even_id = Latency2;
                            RT_addr_even_id = RT_addr2;
                            RegWriteEven_id = RegWrite2;
                            instr_order_even_id = 2;
                        end else begin //Instr_type2 == ODDTYPE
                            RA_addr_odd_id  = RA_addr2;
                            RB_addr_odd_id  = RB_addr2;
                            instr_odd_id    = instr2;
                            ID_odd_id       = ID2;
                            Latency_odd_id  = Latency2;
                            RT_addr_odd_id  = RT_addr2;
                            RegWriteOdd_id  = RegWrite2;
                            instr_order_odd_id = 2;
                        end
                    end
                end else if(instr1_issued_prev) begin //if instr1_issued_prev is set, see if there is a data hazard
                    instr1_issued = 1;
                    if(!instr2_data_hazard && !structural_hazard) begin //if no data hazard, we can clear the flag and go to new data on next cycle
                        instr1_issued = 0;
                        if (Instr_type2 == EVENTYPE) begin
                            RA_addr_even_id = RA_addr2;
                            RB_addr_even_id = RB_addr2;
                            RC_addr_even_id = RC_addr2;
                            instr_even_id   = instr2;
                            ID_even_id      = ID2;
                            Latency_even_id = Latency2;
                            RT_addr_even_id = RT_addr2;
                            RegWriteEven_id = RegWrite2;
                            instr_order_even_id = 2;
                        end else begin //Instr_type2 == ODDTYPE
                            RA_addr_odd_id  = RA_addr2;
                            RB_addr_odd_id  = RB_addr2;
                            instr_odd_id    = instr2;
                            ID_odd_id       = ID2;
                            Latency_odd_id  = Latency2;
                            RT_addr_odd_id  = RT_addr2;
                            RegWriteOdd_id  = RegWrite2;
                            instr_order_odd_id = 2;
                        end
                    end
                end
            end
            // else begin
            //     RA_addr_odd_id  = 0;
            //     RB_addr_odd_id  = 0;
            //     instr_odd_id    = 0;
            //     ID_odd_id       = 0;
            //     Latency_odd_id  = 0;
            //     RT_addr_odd_id  = 0;
            //     RegWriteOdd_id  = 0;
            //     instr_order_odd_id = 0;

            //     //default even pipe to HW No op
            //     RA_addr_even_id = 0;
            //     RB_addr_even_id = 0;
            //     RC_addr_even_id = 0;
            //     instr_even_id   = 0;
            //     ID_even_id      = 0;
            //     Latency_even_id = 0;
            //     RT_addr_even_id = 0;
            //     RegWriteEven_id = 0;
            //     instr_order_even_id = 0;
            // end

        end
    end



    ID_EX_reg u_ID_EX_reg (
        .clk              (clk),
        .rst_n            (rst_n),
        .flush            (flush), // MAKE SURE TO CHANGE AFTER IMPLEMENTING DECODE LOGIC
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
        .instr_order_even_in (instr_order_even_id), 


        // Odd pipe inputs
        .PC_in            (PC_id),
        .RA_addr_odd_in   (RA_addr_odd_id),
        .RB_addr_odd_in   (RB_addr_odd_id),
        .instr_odd_in     (instr_odd_id),
        .ID_odd_in        (ID_odd_id),
        .Latency_odd_in   (Latency_odd_id),
        .RT_addr_odd_in   (RT_addr_odd_id),
        .RegWriteOdd_in   (RegWriteOdd_id),
        .instr_order_odd_in (instr_order_odd_id),

        // Even pipe outputs
        .RA_addr_even_out (RA_addr_even_ex),
        .RB_addr_even_out (RB_addr_even_ex),
        .RC_addr_even_out (RC_addr_even_ex),
        .instr_even_out   (instr_even_ex),
        .ID_even_out      (ID_even_ex),
        .Latency_even_out (Latency_even_ex),
        .RT_addr_even_out (RT_addr_even_ex),
        .RegWriteEven_out (RegWriteEven_ex),
        .instr_order_even_out (instr_order_even_ex),


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
        .RegWriteOdd_out  (RegWriteOdd_ex),
        .instr_order_odd_out (instr_order_odd_ex)

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
        .instr_order_even(instr_order_even_ex),

        .PC              (PC_ex),
        .RA_addr_odd     (RA_addr_odd_ex),
        .RB_addr_odd     (RB_addr_odd_ex),
        .instr_odd       (instr_odd_ex),
        .ID_odd          (ID_odd_ex),
        .Latency_odd     (Latency_odd_ex),
        .RT_addr_odd     (RT_addr_odd_ex),
        .RegWriteOdd_in  (RegWriteOdd_ex),
        .instr_order_odd (instr_order_odd_ex),

        .BTA             (BTA),
        .BT              (BT),
        .odd_pkt_pipes   (odd_pkt_pipes),
        .even_pkt_pipes  (even_pkt_pipes)
    );

//branch logic
always_comb begin
    if (BT) flush = 1;
    else flush = 0;
end

always_ff @(posedge clk) begin
    if (!rst_n) begin
        stop <= 0;
    end
    if (BT) begin
        stop <= 0;
    end
    else if (ID_odd_id == 99 || ID_even_id == 99) begin
        stop <= 1;
    end
end

endmodule