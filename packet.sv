package packet_pkg;
    typedef struct packed {
        logic [0:127] RA_even, 
        logic [0:127] RB_even,
        logic [0:127] RC_even,
        logic [0:6] RT_even_addr,
        logic [0:6] imm_7bit,
        logic [0:9] imm_10bit,
        logic [0:15] imm_16bit,
        logic [0:17] imm_18bit,
        logic [0:6] ID_even, //there are 100 instructions
        logic [0:3] Latency_even, //max latency is 8
        logic [0:127] RT_even,
        logic RegWrite_even,
        logic [0:6] RT_even_dest_addr,
        logic [0:127] RT_even_dest_data
    } packet;

    typedef struct packed {
        logic [0:2] unit_ID,
        logic [0:127] result,
        logic [0:2] latency,
        logic RegWr,
        logic [0:6] dest_addr
    } unit_result_packet;

endpackage