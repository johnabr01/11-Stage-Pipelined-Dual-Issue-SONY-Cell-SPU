package packet_pkg;
    typedef struct packed {
        logic [0:127] RA; 
        logic [0:127] RB;
        logic [0:127] RC;
        logic [0:6] RT_read_addr;
        logic [0:6] ID; //there are 100 instructions
        logic [0:3] Latency; //max latency is 8
        logic [0:127] RT_read_data;
        logic RegWrite;
        logic [0:31] instr;
        logic [0:6] RT_dest_addr;
        int instr_order; //1 first packet, 2 second packet
        //logic [0:127] RT_dest_data;
    } packet;

    typedef struct packed {
        logic [0:6] unit_ID;
        logic [0:127] result;
        logic [0:2] latency;
        logic RegWr;
        logic [0:6] dest_addr;
        logic [0:3] curr_stage_counter;
        int instr_order; //1 first packet, 2 second packet
    } even_packet;

    typedef struct packed {
        logic [0:6] unit_ID;
        logic [0:127] result;
        logic [0:2] latency;
        logic RegWr;
        logic [0:6] dest_addr;
        logic [0:3] curr_stage_counter;
        unsigned int instr_order; //1 first packet, 2 second
    } odd_packet;

endpackage