import packet_pkg::*;

module odd_pipe #(
    localparam LAST_STAGE = 8
)(
    input clk,
    input rst_n,
    input branch_flush,
    input [0:31] PC,
    input packet pkt_in, //biggest packet containing all the control signals and data from the decode stage.
    output logic [0:31] BTA,
    output logic BT,
    output logic canForwardOdd[0:LAST_STAGE-1],
    output odd_packet odd_pkt_pipes[0:LAST_STAGE-1]
);

logic [0:127] data_out_odd;
logic [0:3] curr_stage_counter [0:LAST_STAGE-1];

logic [0:31] computed_BTA;

logic computed_BT;

logic [0:31] computed_BTA_pipe[0:1];
logic computed_BT_pipe[0:1];

odd_packet pipeline_packet;
odd_packet nop_packet;

always_comb begin
    pipeline_packet.unit_ID            = pkt_in.ID;
    pipeline_packet.result             = data_out_odd;
    pipeline_packet.latency            = pkt_in.Latency;
    pipeline_packet.RegWr              = pkt_in.RegWrite;
    pipeline_packet.dest_addr          = pkt_in.RT_dest_addr;
    pipeline_packet.curr_stage_counter = 0;
    pipeline_packet.instr_order        = pkt_in.instr_order;
end

always_comb begin
    nop_packet.unit_ID            = 0;
    nop_packet.result             = 0;
    nop_packet.latency            = 0;
    nop_packet.RegWr              = 0;
    nop_packet.dest_addr          = 0;
    nop_packet.curr_stage_counter = 0;
    nop_packet.instr_order        = 0;
end

odd_execute u_odd_execute (
    .clk             (clk),
    .rst_n           (rst_n),
    .PC              (PC),
    .RA_odd          (pkt_in.RA),
    .RB_odd          (pkt_in.RB),
    .instr_odd       (pkt_in.instr),
    .ID_odd          (pkt_in.ID),
    .RT_odd          (pkt_in.RT_read_data),
    .BTA          (computed_BTA),
    .BT             (computed_BT),
    //.RT_odd_dest_data(RT_dest_data),
    .data_out_odd    (data_out_odd)
);

// the packet that contains the control signals from decode stage and data from execute that will be stored in the pipeline registers
// odd_packet pipeline_packet ( 
//     .unit_ID(pkt_in.ID_odd),
//     .result(data_out_odd), //data from even execute module
//     .latency(pkt_in.Latency_odd),
//     .RegWr(pkt_in.RegWrite_odd),
//     .dest_addr(pkt_in.RT_dest_addr),
//     .curr_stage_counter(curr_stage_counter),
//     .PC(BTA)
// );

always_ff @(posedge clk) begin
    if(!rst_n) begin
        computed_BTA_pipe[0] <= 0;
        computed_BT_pipe[0] <= 0;
        computed_BTA_pipe[1] <= 0;
        computed_BT_pipe [1]<= 0;
        for(int i = 0; i < LAST_STAGE; i++) begin
            odd_pkt_pipes[i].unit_ID <= 0;
            odd_pkt_pipes[i].result <= 0;
            odd_pkt_pipes[i].latency <= 0;
            odd_pkt_pipes[i].RegWr <= 0;
            odd_pkt_pipes[i].dest_addr <= 0;
            odd_pkt_pipes[i].curr_stage_counter <= 0;
            odd_pkt_pipes[i].instr_order <= 0;
        end
    end
    else begin
        //@TODO change branch timing -> add one pipeline register in betwewen
        //@TODO Also double check to make sure canForward signal is actually correct
        computed_BT_pipe[0] <= computed_BT;
        computed_BTA_pipe[0] <= computed_BTA;
        computed_BT_pipe[1] <= computed_BT_pipe[0];
        computed_BTA_pipe[1] <= computed_BTA_pipe[0];
        //odd_pkt_pipes[0].curr_stage_counter <= 0;
        if(branch_flush) begin 
            odd_pkt_pipes[0] <= nop_packet;
            odd_pkt_pipes[1] <= nop_packet;
        end
        else begin 
            odd_pkt_pipes[0] <= pipeline_packet;
            odd_pkt_pipes[1] <= odd_pkt_pipes[0];
            if(odd_pkt_pipes[0].curr_stage_counter < odd_pkt_pipes[0].latency) odd_pkt_pipes[1].curr_stage_counter <= odd_pkt_pipes[0].curr_stage_counter + 1;
            else odd_pkt_pipes[1].curr_stage_counter <= odd_pkt_pipes[0].curr_stage_counter;
        end
        
        for(int i = 2; i < LAST_STAGE; i++) begin
            odd_pkt_pipes[i] <= odd_pkt_pipes[i-1];
            //Logic to increment counter (or not increment it) based on 
            //if counter associated with stage reached the instruction's latency
            if(odd_pkt_pipes[i-1].curr_stage_counter < odd_pkt_pipes[i-1].latency) odd_pkt_pipes[i].curr_stage_counter <= odd_pkt_pipes[i-1].curr_stage_counter + 1;
            else odd_pkt_pipes[i].curr_stage_counter <= odd_pkt_pipes[i-1].curr_stage_counter;
        end
    end
end

always_comb begin
    for(int i = 0; i < LAST_STAGE; i++) begin
        canForwardOdd[i] = ((odd_pkt_pipes[i].latency != 0) && 
                            (odd_pkt_pipes[i].curr_stage_counter >= odd_pkt_pipes[i].latency - 1)) ? 1 : 0;
    end
end

assign BTA = computed_BTA_pipe[1];
assign BT = computed_BT_pipe[1];

endmodule