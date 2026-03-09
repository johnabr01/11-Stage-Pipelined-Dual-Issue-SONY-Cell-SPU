import packet_pkg::*;

module even_pipe (
    input clk,
    input rst_n,
    input packet pkt_in, //biggest packet containing all the control signals and data from the decode stage.
    output logic [0:127] RT_even_dest_data,
    output logic canForwardEven[0:6],
    output unit_result_packet pkt_pipes[0:6]
);

logic [0:3] curr_stage_counter [0:6];

even_execute u_even_execute (
    .clk              (clk),
    .rst_n            (rst_n),
    .RA_even          (pkt_in.RA_even),
    .RB_even          (pkt_in.RB_even),
    .RC_even          (pkt_in.RC_even),
    .RT_even_addr     (pkt_in.RT_even_addr),
    .imm_7bit         (pkt_in.imm_7bit),
    .imm_10bit        (pkt_in.imm_10bit),
    .imm_16bit        (pkt_in.imm_16bit),
    .imm_18bit        (pkt_in.imm_18bit),
    .ID_even          (pkt_in.ID_even),
    //.Latency_even     (pkt_in.Latency_even),
    .RT_even          (pkt_in.RT_even),
    //.RegWrite_even    (pkt_in.RegWrite_even),
    //.RT_even_dest_addr(pkt_in.RT_even_dest_addr),
    .RT_even_dest_data(pkt_in.RT_even_dest_data),
    .data_out_even(data_out_even)
);

unit_result_packet pipeline_packet (
    .unit_ID(pkt_in.ID_even),
    .result(data_out_even),
    .latency(pkt_in.Latency_even),
    .RegWr(pkt_in.RegWrite_even),
    .dest_addr(pkt_in.RT_even_dest_addr)
);


always_ff @(posedge clk) begin
    if(!rst_n) begin
        for(int i = 0; i < 7; i++) begin
            pkt_pipes[i].unit_ID = 0;
            pkt_pipes[i].result = 0;
            pkt_pipes[i].latency = 0;
            pkt_pipes[i].RegWr = 0;
            pkt_pipes[i].dest_addr = 0;
        end
    end
    else begin
        pkt_pipes[0] <= pipeline_packet;
        if(curr_stage_counter < pkt_pipes[0].latency) curr_stage_counter = curr_stage_counter + 1;
        for(int i = 1; i < 7; i++) begin
            pkt_pipes[i] <= pkt_pipes[i-1];
            if(curr_stage_counter < pkt_pipes[i].latency) curr_stage_counter = curr_stage_counter + 1;
        end
    end
end

always_comb begin
    for(int i = 0; i < 7; i++) begin
        canForwardEven[i] = (curr_stage_counter[i] == pkt_pipes[i].latency) ? 1 : 0;
    end
end


endmodule