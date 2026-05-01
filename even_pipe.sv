import packet_pkg::*;

module even_pipe #(
    localparam LAST_STAGE = 8
)(
    input clk,
    input rst_n,
    input branch_flush,
    input branch_flush_all,
    input packet pkt_in, //biggest packet containing all the control signals and data from the decode stage.
    output logic canForwardEven[0:LAST_STAGE-1],
    output even_packet even_pkt_pipes[0:LAST_STAGE-1]
);

logic [0:3] curr_stage_counter [0:LAST_STAGE-1];
logic [0:127] data_out_even;

even_packet pipeline_packet;
even_packet nop_packet;

always_comb begin
    pipeline_packet.unit_ID            = pkt_in.ID;
    pipeline_packet.result             = data_out_even;
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

even_execute u_even_execute (
    .clk              (clk),
    .rst_n            (rst_n),
    .RA_even          (pkt_in.RA),
    .RB_even          (pkt_in.RB),
    .RC_even          (pkt_in.RC),
    .instr_even       (pkt_in.instr),
    .ID_even          (pkt_in.ID),
    //.Latency_even     (pkt_in.Latency_even),
    .RT_even          (pkt_in.RT_read_data),
    //.RegWrite_even    (pkt_in.RegWrite_even),
    //.RT_even_dest_addr(pkt_in.RT_even_dest_addr),
    //.RT_even_dest_data(RT_even_dest_data),
    .data_out_even(data_out_even)
);

// // the packet that contains the control signals from decode stage and data from execute that will be stored in the pipeline registers
// even_packet pipeline_packet ( 
//     .unit_ID(pkt_in.ID_even),
//     .result(data_out_even), //data from even execute module
//     .latency(pkt_in.Latency_even),
//     .RegWr(pkt_in.RegWrite_even),
//     .dest_addr(pkt_in.RT_dest_addr),
//     .curr_stage_counter(curr_stage_counter)
// );


always_ff @(posedge clk) begin
    if(!rst_n) begin
        for(int i = 0; i < LAST_STAGE; i++) begin
            even_pkt_pipes[i].unit_ID <= 0;
            even_pkt_pipes[i].result <= 0;
            even_pkt_pipes[i].latency <= 0;
            even_pkt_pipes[i].RegWr <= 0;
            even_pkt_pipes[i].dest_addr <= 0;
            even_pkt_pipes[i].curr_stage_counter <= 0;
            even_pkt_pipes[i].instr_order <= 0;
        end
    end
    else begin
        if(branch_flush) begin 
            even_pkt_pipes[0] <= nop_packet;
            even_pkt_pipes[1] <= nop_packet;
        end
        else begin 
            even_pkt_pipes[0] <= pipeline_packet;
            even_pkt_pipes[1] <= even_pkt_pipes[0];
            if(even_pkt_pipes[0].curr_stage_counter < even_pkt_pipes[0].latency) even_pkt_pipes[1].curr_stage_counter <= even_pkt_pipes[0].curr_stage_counter + 1;
            else even_pkt_pipes[1].curr_stage_counter <= even_pkt_pipes[0].curr_stage_counter;
        end
        //even_pkt_pipes[0].curr_stage_counter <= 0;
        if(branch_flush && branch_flush_all) begin
            even_pkt_pipes[2] <= nop_packet;
        end else begin
            even_pkt_pipes[2] <= even_pkt_pipes[1];
            if(even_pkt_pipes[1].curr_stage_counter < even_pkt_pipes[1].latency) even_pkt_pipes[2].curr_stage_counter <= even_pkt_pipes[1].curr_stage_counter + 1;
            else even_pkt_pipes[2].curr_stage_counter <= even_pkt_pipes[1].curr_stage_counter;
        end
        for(int i = 3; i < LAST_STAGE; i++) begin
            even_pkt_pipes[i] <= even_pkt_pipes[i-1];
            //Logic to increment counter (or not increment it) based on 
            //if counter associated with stage reached the instruction's latency
            if(even_pkt_pipes[i-1].curr_stage_counter < even_pkt_pipes[i-1].latency) even_pkt_pipes[i].curr_stage_counter <= even_pkt_pipes[i-1].curr_stage_counter + 1;
            else even_pkt_pipes[i].curr_stage_counter <= even_pkt_pipes[i-1].curr_stage_counter;
        end
    end
end

always_comb begin
    for(int i = 0; i < LAST_STAGE; i++) begin
        canForwardEven[i] = ((even_pkt_pipes[i].latency != 0) && 
                            (even_pkt_pipes[i].curr_stage_counter >= even_pkt_pipes[i].latency - 1)) ? 1 : 0;
    end
end

endmodule