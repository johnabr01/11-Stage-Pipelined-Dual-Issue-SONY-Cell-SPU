module odd_pipe(
    input clk,
    input rst_n,
    input [0:31] PC;
    input [0:127] RA_odd, 
    input [0:127] RB_odd,
    input [0:127] RC_odd,
    input [0:6] RT_odd_addr,
    input [0:6] imm_7bit,
    input [0:9] imm_10bit,
    input [0:15] imm_16bit,
    input [0:17] imm_18bit,
    input [0:6] ID_odd, //there are 100 instructions
    input [0:3] Latency_odd, //max latency is 8
    input [0:127] RT_odd,
    input RegWrite_odd,
    output logic [0:31] PC_out,
    output logic [0:6] RT_odd_dest_addr,
    output logic [0:127] RT_odd_dest_data
);

logic [0:2] s_3bit;
logic [0:4] s_5bit;
logic [0:3] s_4bit;
logic [0:7] s_8bit;

logic [0:127] r;
logic [0:127] r_mem; //output from local store
logic [0:31] LSA;   //Local Store Address
logic MemWrite; //Memory Write Enable

local_store local_store_inst(
    .clk(clk),
    .address(LSA[0:10]),
    .write_data(RT_odd),
    .MemWrite(MemWrite),
    .read_data(r_mem)
);


always_comb begin
    s_3bit = 0;
    s_5bit = 0;
    s_4bit = 0;
    s_8bit = 0;
    r = 0;
    MemWrite = 0;

    case(ID_odd) : //Shift left quadword by bits
        0: begin
            //hardware no op
        end
        67: begin
            s_3bit = RB_odd[29:31];
            for(int b = 0; b < 127; b++) begin
                if (b + s_3bit < 128) r[b]= RA_odd[b+s_3bit];
                else r[b] = 0;
            end
        end
        
        68: begin //Shift left quadword by bits immediate
            s_3bit = imm_7bit & 7'h07;
            for(int b = 0; b < 128; b++) begin
                if (b + s_3bit < 128) r[b]= RA_odd[b+s_3bit];
                else r[b] = 0;
            end
        end

        69 : begin //Shift Left Quadword by Bytes
            s_5bit = RB_odd[27:31];
            for(int b = 0; b < 16; b++) begin
                if(b + s_5bit < 16) r[b*8 +: 8] = RA_odd[(b+s_5bit)*8 +: 8];
                else r[b*8 +: 8] = 0;
            end
        end

        70 : begin //Shift Left Quadword by Bytes Immediate
            s_5bit = imm_7bit & 7'h1f; //imm_7bit[13:17]
            for(int b = 0; b < 16; b++) begin
                if(b + s_5bit < 16) r[b*8 +: 8] = RA_odd[(b+s_5bit)*8 +: 8];
                else r[b*8 +: 8] = 0;
            end
        end

        71 : begin //Rotate Quadword by Bytes
            s_4bit = RB_odd[28:31];
            for(int b = 0; b < 16; b++) begin
                if(b + s_4bit < 16) r[b*8 +: 8] = RA_odd[(b+s_4bit)*8 +: 8];
                else r[b*8 +: 8] = RA_odd[(b+s_4bit - 16)*8 +: 8];
            end
        end

        72 : begin //Rotate Quadword by Bytes Immediate
            s_4bit = imm_7bit[3:6];
            for(int b = 0; b < 16; b++) begin
                if(b + s_4bit < 16) r[b*8 +: 8] = RA_odd[(b+s_4bit)*8 +: 8];
                else r[b*8 +: 8] = RA_odd[(b+s_4bit - 16)*8 +: 8];
            end
        end

        73 : begin //Rotate Quadword by Bytes from Bit Shift Count
            s_4bit = RB_odd[25:28];
            for(int b = 0; b < 16; b++) begin
                if(b + s_4bit < 16) r[b*8 +: 8] = RA_odd[(b+s_4bit)*8 +: 8];
                else r[b*8 +: 8] = RA_odd[(b+s_4bit - 16)*8 +: 8];
            end
        end
        
        74: begin //Rotate Quadword by Bits
            s_3bit = RB_odd[29:31];
            for(int b = 0; b < 128; b++) begin
                r[b] = ( b + s < 128 ) ? RA_odd[b+s] : RA_odd[b+s-128];
            end
        end

        75: begin //Rotate Quadword by Bits Immediate
            s_3bit = imm_7bit[4:6];
            for(int b = 0; b < 128; b++) begin
                r[b] = ( b + s < 128 ) ? RA_odd[b+s] : RA_odd[b+s-128];
            end
        end

        76: begin //Gather Bits from Halfwords
            s_8bit = 0;
            for(int i = 15, j = 0; i < 128; i += 16, j++) begin
                s_8bit[j] = RA_odd[i];
            end
            r[0:31] = {24{1'b0}, s_8bit};
            r[32:63] = 0;
            r[64:95] = 0;
            r[96:127] = 0;
        end

        77 : begin //Gather Bits from Words
            s_4bit = 0;
            for(int i = 31, j = 0; i < 128; i += 32, j++) begin
                s_4bit[j] = RA_odd[i];
            end
            r[0:31] = {28{1'b0}, s_4bit};
            r[32:63] = 0;
            r[64:95] = 0;
            r[96:127] = 0;
        end

        78 : begin //Load Quadword (d-form)
            LSA = ($signed({18{imm_10bit[0]}, imm_10bit, 4'b0000}) + $signed(RA_odd[0:31])) & 32'hFFFFFFF0; //RA bytes 0 to 3
            r = r_mem; ///*memory[LSA]*/;
        end

        79 : begin //Load Quadword (x-form)
            LSA = ($signed(RA_odd[0:31]) + $signed(RB_odd[0:31])) & 32'hFFFFFFF0;
            r = r_mem;
        end

        80 : begin //Load Quadword (a-form)
            LSA = ({14{imm_16bit[0]}, imm_16bit, 4'b00}) & 32'hFFFFFFF0; 
            r = r_mem;
        end

        81 : begin //Store Quadword (d-form)
            LSA = ($signed({18{imm_10bit[0]}, imm_10bit, 4'b0000}) + $signed(RA_odd[0:31])) & 32'hFFFFFFF0; //RA bytes 0 to 3
            MemWrite = 1;
        end

        82: begin //Store Quadword (x-form)
            LSA = ($signed(RA_odd[0:31]) + $signed(RB_odd[0:31])) & 32'hFFFFFFF0;
            MemWrite = 1;
        end

        83: begin //Store Quadword (a-form)
            LSA = ({14{imm_16bit[0]}, imm_16bit, 4'b00}) & 32'hFFFFFFF0; 
            MemWrite = 1;
        end

        84: begin //Branch Relative
            PC_out = PC + $signed({14{imm_16bit[0]}, imm_16bit, 2'b00});    
        end

        85: begin //Branch Absolute 
            PC_out = {14{imm_16bit[0]}, imm_16bit, 2'b00};
        end

        86: begin //Branch Relative and Set Link
            r[0:31] = PC + 4; //Address of the next instruction
            r[32: 127] = 0;
            PC_out = PC + $signed({14{imm_16bit[0]}, imm_16bit, 2'b00});
        end
        
        87: begin //Branch Absolute and Set Link
            r[0:31] = PC + 4; //Address of the next instruction
            r[32:127] = 0;
            PC_out = {14{imm_16bit[0]}, imm_16bit, 2'b00};
        end

        88: begin //Branch Indirect
            PC_out = RA_odd[0:31] &  32'hFFFFFFFC; //RA bytes 0 to 3
        end

        89: begin //Branch If Not Zero Word
            if (RT_odd[0:31] != 0) PC_out = {14{imm_16bit[0]}, imm_16bit, 2'b00};
            else PC_out = PC + 4;
        end

        90: begin //Branch if Zero Word
            if (RT_odd[0:31] == 0) PC_out = {14{imm_16bit[0]}, imm_16bit, 2'b00} & 32'hFFFFFFFC;
            else PC_out = PC + 4;
        end

        91: begin //Branch IF Not Zero Halfword
            if (RT_odd[16:31] != 0) PC_out = {14{imm_16bit[0]}, imm_16bit, 2'b00} & 32'hFFFFFFFC;
            else PC_out = PC + 4;
        end

        92: begin //Branch if Zero Halfword
            if (RT_odd[16:31] == 0) PC_out = {14{imm_16bit[0]}, imm_16bit, 2'b00} & 32'hFFFFFFFC;
            else PC_out = PC + 4;
        end

        93: begin //Branch Indirect If Zero
            t = RA_odd[0:31] & 32'hFFFFFFFC; //RA bytes 0 to 3
            u =  PC + 4;
            if (RT_odd[0:31] == 0) PC_out = t & 32'hFFFFFFFC;
            else PC_out = u;
        end
        
        94: begin //Branch Indirect If Not Zero
            t = RA_odd[0:31] & 32'hFFFFFFFC; //RA bytes 0 to 3
            u =  PC + 4;
            if (RT_odd[0:31] != 0) PC_out = t & 32'hFFFFFFFC;
            else PC_out = u;
        end

        95: begin //Branch Indirect If Zero Halfword
            t = RA_odd[0:31] & 32'hFFFFFFFC; //RA bytes 0 to 3
            u =  PC + 4;
            if (RT_odd[16:31] != 0) PC_out = t & 32'hFFFFFFFC;
            else PC_out = u;
        end
        

        96: begin //Branch Indirect If Not Zero Halfword
            t = RA_odd[0:31] & 32'hFFFFFFFC; //RA bytes 0 to 3
            u =  PC + 4;
            if (RT_odd[16:31] != 0) PC_out = t & 32'hFFFFFFFC;
            else PC_out = u;
        end

        98: begin //Nop load
        end
        
        99: begin //Stop and signal
        end
    endcase
end

// always_ff @(posedge clk) begin
//     RT_odd <= r;
// end


endmodule