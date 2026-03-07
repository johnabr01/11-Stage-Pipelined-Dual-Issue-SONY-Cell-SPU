module even_pipe #(
    localparam BYTE = 8
)
(
    input clk,
    input rst_n,
    input [0:127] RA_even, 
    input [0:127] RB_even,
    input [0:127] RC_even,
    input [0:6] RT_even_addr,
    input [0:6] imm_7bit,
    input [0:9] imm_10bit,
    input [0:15] imm_16bit,
    input [0:17] imm_18bit,
    input [0:6] ID_even, //there are 100 instructions
    input [0:3] Latency_even, //max latency is 8
    input [0:127] RT_even,
    input RegWrite_even,
    output [0:6] RT_even_dest_addr,
    output [0:127] RT_even_dest_data
);

logic [0:15] s;
logic [0:31] t;
logic [0:15] t_16bit; 
logic [0:32] t_33bit; // for carry generate
logic [0:3] s_4bit;
logic [0:7] s_8bit;
logic [0:31] s_32bit; 
logic [0:4] k;

logic [0:127] temp;
assign temp = 0; // default value for temp


always_comb begin 
    case (ID_even)
        0: begin
            //hardware NOP
        end 
        1: begin //AH: Add halfword
            for (int j=0; j<8; j++) begin
                temp[2*j*BYTE +: 2*BYTE] = $signed(RA_even[2*j*BYTE +: 2*BYTE]) + $signed(RB_even[2*j*BYTE +: 2*BYTE]);
            end
        end
        2: begin //AHI: Add halfword immediate
            s = {{6{imm_10bit[0]}}, imm_10bit}; 
            for (int j=0; j<8; j++) begin
                temp[2*j*BYTE +: 2*BYTE] = $signed(RA_even[2*j*BYTE +: 2*BYTE]) + $signed(s);
            end
        end
        3: begin //A: Add word
            for (int j=0; j<4; j++) begin
                temp[4*j*BYTE +: 4*BYTE] = $signed(RA_even[4*j*BYTE +: 4*BYTE]) + $signed(RB_even[4*j*BYTE +: 4*BYTE]);
            end
        end
        4: begin //AI: add word immediate
            t = {{22{imm_10bit[0]}}, imm_10bit};
            for (int j=0; j<4; j++) begin
                temp[4*j*BYTE +: 4*BYTE] = $signed(RA_even[4*j*BYTE +: 4*BYTE]) + $signed(t);
            end
        end
        5: begin //ADDX: add extended
            for (int j = 0; j < 4; j++) begin
                temp[j*4*BYTE +: 4*BYTE] = $signed(RA_even[j*4*BYTE +: 4*BYTE]) + $signed(RB_even[j*4*BYTE +: 4*BYTE]) + $signed(RT_even[32*j + 31]);
            end
        end
        6: begin //CG: Carry generate
            for (int j=0; j<16; j+=4) begin
                t_33bit = {1'b0, RA[j +: 4]} + {1'b0, RB[j +: 4]};
                temp[j*BYTE +: 4*BYTE] = {32'b0,t[31]}; 
            end
        end
        7: begin //SFX: subtract from extended
            for (int j = 0; j< 4; j++) begin
                temp[j*4*BYTE +: 4*BYTE] = RA_even[j*4*BYTE +: 4*BYTE] + (~RB_even[j*4*BYTE +: 4*BYTE]) + RT_even[32*j + 31];
            end
        end
        8: begin //BG: Borrow generate
            for (int j=0; j<16; j+=4) begin
                if (RB_even[j*BYTE +: 4*BYTE] > RA_even[j*BYTE +: 4*BYTE]) begin
                    temp[j*BYTE +: 4*BYTE] = '1; // borrow generated
                end else begin
                    temp[j*BYTE +: 4*BYTE] = '0; // no borrow
                end
            end
        end
        9: begin // SFH: Subtract from halfword
            for (int j=0; j<8; j++) begin
                temp[2*j*BYTE +: 2*BYTE] = RB_even[2*j*BYTE +: 2*BYTE] + (~RA_even[2*j*BYTE +: 2*BYTE]) + 1; // two's complement subtraction
            end
        end
        10: begin // SFHI: Subtract from halfword immediate
            t = {{6{imm_10bit[0]}}, imm_10bit}; 
            for (int j=0; j<8; j++) begin
                temp[2*j*BYTE +: 2*BYTE] = t + (~RA_even[2*j*BYTE +: 2*BYTE]) + 1; // two's complement subtraction
            end
        end
        11: begin //SF: Subtract from word
            for (int j=0; j<4; j++) begin
                temp[4*j*BYTE +: 4*BYTE] = RB_even[4*j*BYTE +: 4*BYTE] + (~RA_even[4*j*BYTE +: 4*BYTE]) + 1; // two's complement subtraction
            end
        end
        12: begin // SFI: Subtract from word immediate
            t = {{22{imm_10bit[0]}}, imm_10bit};
            for (int j=0; j<4; j++) begin
                temp[4*j*BYTE +: 4*BYTE] = t + (~RA_even[4*j*BYTE +: 4*BYTE]) + 1; // two's complement subtraction
            end
        end
        13: begin //AND: bitwise AND
            for (int j=0; j<4; j++) begin
                temp[4*j*BYTE +: 4*BYTE] = RA_even[4*j*BYTE +: 4*BYTE] & RB_even[4*j*BYTE +: 4*BYTE];
            end
        end
        14: begin //ANDHI: And halfword immediate
            t = {{6{imm_10bit[0]}}, imm_10bit}; 
            for (int j=0; j<8; j++) begin
                temp[2*j*BYTE +: 2*BYTE] = RA_even[2*j*BYTE +: 2*BYTE] & t;
            end
        end
        15: begin //ANDI: And word immediate
            t = {{22{imm_10bit[0]}}, imm_10bit};
            for (int j=0; j<4; j++) begin
                temp[4*j*BYTE +: 4*BYTE] = RA_even[4*j*BYTE +: 4*BYTE] & t;
            end
        end
        16: begin //OR: bitwise OR
            for (int j=0; j<4; j++) begin
                temp[4*j*BYTE +: 4*BYTE] = RA_even[4*j*BYTE +: 4*BYTE] | RB_even[4*j*BYTE +: 4*BYTE];
            end
        end
        17: begin //ORHI: Or halfword immediate
            t = {{6{imm_10bit[0]}}, imm_10bit}; 
            for (int j=0; j<8; j++) begin
                temp[2*j*BYTE +: 2*BYTE] = RA_even[2*j*BYTE +: 2*BYTE] | t;
            end
        end
        18: begin //ORI: Or word immediate
            t = {{22{imm_10bit[0]}}, imm_10bit};
            for (int j=0; j<4; j++) begin
                temp[4*j*BYTE +: 4*BYTE] = RA_even[4*j*BYTE +: 4*BYTE] | t;
            end
        end
        19: begin //XOR: bitwise XOR
            for (int j=0; j<4; j++) begin
                temp[4*j*BYTE +: 4*BYTE] = RA_even[4*j*BYTE +: 4*BYTE] ^ RB_even[4*j*BYTE +: 4*BYTE];
            end
        end
        20: begin //XORHI: Xor halfword immediate
            t = {{6{imm_10bit[0]}}, imm_10bit}; 
            for (int j=0; j<8; j++) begin
                temp[2*j*BYTE +: 2*BYTE] = RA_even[2*j*BYTE +: 2*BYTE] ^ t;
            end
        end
        21: begin //XORI: Xor word immediate
            t = {{22{imm_10bit[0]}}, imm_10bit};
            for (int j=0; j<4; j++) begin
                temp[4*j*BYTE +: 4*BYTE] = RA_even[4*j*BYTE +: 4*BYTE] ^ t;
            end
        end
        22: begin //NAND: bitwise NAND
            for (int j=0; j<4; j++) begin
                temp[4*j*BYTE +: 4*BYTE] = ~(RA_even[4*j*BYTE +: 4*BYTE] & RB_even[4*j*BYTE +: 4*BYTE]);
            end             
        end
        23: begin //NOR: bitwise NOR
            for (int j=0; j<4; j++) begin
                temp[4*j*BYTE +: 4*BYTE] = ~(RA_even[4*j*BYTE +: 4*BYTE] | RB_even[4*j*BYTE +: 4*BYTE]);
            end            
        end
        24: begin //CLZ: Count leading zeros
            for (int j=0; j<4; j++) begin
                t = 32'b0;
                u = RA_even[4*j*BYTE +: 4*BYTE];
                for (int m = 0; m<32; m++) begin
                    if (u[m] == 1'b1) begin
                        break;
                    end else begin
                        t = t + 1;
                    end
                end
                temp[4*j*BYTE +: 4*BYTE] = t;
            end
        end

        25: begin //FSMH: Form Select Mask for Halfwords
            s_7bit = RA_even[120:127];
            k = 0;
            for (int j=0; j<8; j++) begin
                if (s_4bit[j] == 1'b0) begin
                    temp[k*BYTE +: 2] = 16'h0000;
                end else begin
                    temp[k*BYTE +: 2] = 16'hFFFF;
                end
                k = k + 2;
            end
        end

        26: begin //FSM: Form Select Mask for Words
            s_4bit = RA_even[124:127];
            k = 0;
            for (int j=0; j<4; j++) begin
                if (s_4bit[j] == 1'b0) begin
                    temp[k*BYTE +: 4*BYTE] = 32'h00000000;
                end else begin
                    temp[k*BYTE +: 4*BYTE] = 32'hFFFFFFFF;
                end
                k = k + 4;
            end
        end

        27: begin //CEQH: Compare Equal Halfword
            for (int i = 0; i < 8; i++) begin
                if (RA_even[2*i*BYTE +: 2*BYTE] == RB_even[2*i*BYTE +: 2*BYTE]) begin
                    temp[2*i*BYTE +: 2*BYTE] = 16'hFFFF;
                end else begin
                    temp[2*i*BYTE +: 2*BYTE] = 16'h0000;
                end
            end
        end

        28: begin //CEQHI: Compare Equal Halfword Immediate
            t = {{6{imm_10bit[0]}}, imm_10bit}; 
            for (int i = 0; i < 8; i++) begin
                if (RA_even[2*i*BYTE +: 2*BYTE] == t) begin
                    temp[2*i*BYTE +: 2*BYTE] = 16'hFFFF;
                end else begin
                    temp[2*i*BYTE +: 2*BYTE] = 16'h0000;
                end
            end
        end

        29: begin //CEQ: Compare Equal Word
            for (int i = 0; i < 4; i++) begin
                if (RA_even[4*i*BYTE +: 4*BYTE] == RB_even[4*i*BYTE +: 4*BYTE]) begin
                    temp[4*i*BYTE +: 4*BYTE] = 32'hFFFFFFFF;
                end else begin
                    temp[4*i*BYTE +: 4*BYTE] = 32'h00000000;
                end
            end
        end

        30: begin //CEQI: Compare Equal Word Immediate
            t = {{22{imm_10bit[0]}}, imm_10bit}; 
            for (int i = 0; i < 4; i++) begin
                if (RA_even[4*i*BYTE +: 4*BYTE] == t) begin
                    temp[4*i*BYTE +: 4*BYTE] = 32'hFFFFFFFF;
                end else begin
                    temp[4*i*BYTE +: 4*BYTE] = 32'h00000000;
                end
            end
        end

        31: begin //CGTH: Compare Greater Than Halfword
            for (int i = 0; i < 8; i++) begin
                if ($signed(RA_even[2*i*BYTE +: 2*BYTE]) > $signed(RB_even[2*i*BYTE +: 2*BYTE])) begin    //signed comparison
                    temp[2*i*BYTE +: 2*BYTE] = 16'hFFFF;
                end else begin
                    temp[2*i*BYTE +: 2*BYTE] = 16'h0000;
                end
            end
        end

        32: begin //CGTHI: Compare Greater Than Halfword Immediate
            t = {{6{imm_10bit[0]}}, imm_10bit}; 
            for (int i = 0; i < 8; i++) begin
                if ($signed(RA_even[2*i*BYTE +: 2*BYTE]) > $signed(t)) begin    //signed comparison
                    temp[2*i*BYTE +: 2*BYTE] = 16'hFFFF;
                end else begin
                    temp[2*i*BYTE +: 2*BYTE] = 16'h0000;
                end
            end
        end

        33: begin //CGT: Compare Greater Than Word
            for (int i = 0; i < 4; i++) begin
                if ($signed(RA_even[4*i*BYTE +: 4*BYTE]) > $signed(RB_even[4*i*BYTE +: 4*BYTE])) begin        //signed comparison
                    temp[4*i*BYTE +: 4*BYTE] = 16'hFFFFFFFF;
                end else begin
                    temp[4*i*BYTE +: 4*BYTE] = 16'h00000000;
                end
            end
        end

        34: begin //CGTI: Compare Greater Than Word Immediate
            t = {{22{imm_10bit[0]}}, imm_10bit}; 
            for (int i = 0; i < 4; i++) begin
                if ($signed(RA_even[4*i*BYTE +: 4*BYTE]) > $signed(t)) begin        //signed comparison
                    temp[4*i*BYTE +: 4*BYTE] = 16'hFFFFFFFF;
                end else begin
                    temp[4*i*BYTE +: 4*BYTE] = 16'h00000000;
                end
            end
        end

        35: begin //CLGTH: Compare Logical Greater Than Halfword
            for (int i = 0; i < 8; i++) begin
                if (RA_even[2*i*BYTE +: 2*BYTE] > RB_even[2*i*BYTE +: 2*BYTE]) begin      //unsigned comparison
                    temp[2*i*BYTE +: 2*BYTE] = 16'hFFFF;
                end else begin
                    temp[2*i*BYTE +: 2*BYTE] = 16'h0000;
                end
            end
        end

        36: begin //CLGTHI: Compare Logical Greater Than Halfword Immediate
            t = {{6{imm_10bit[0]}}, imm_10bit}; 
            for (int i = 0; i < 8; i++) begin
                if (RA_even[2*i*BYTE +: 2*BYTE] > t) begin    //unsigned comparison
                    temp[2*i*BYTE +: 2*BYTE] = 16'hFFFF;
                end else begin
                    temp[2*i*BYTE +: 2*BYTE] = 16'h0000;
                end
            end
        end

        37: begin //CLGT: Compare Logical Greater Than Word
            for (int i = 0; i < 4; i++) begin
                if (RA_even[4*i*BYTE +: 4*BYTE] > RB_even[4*i*BYTE +: 4*BYTE]) begin      //unsigned comparison
                    temp[4*i*BYTE +: 4*BYTE] = 32'hFFFFFFFF;
                end else begin
                    temp[4*i*BYTE +: 4*BYTE] = 32'h00000000;
                end
            end
        end

        38: begin //CLGTI: Compare Logical Greater Than Word Immediate
            t = {{22{imm_10bit[0]}}, imm_10bit}; 
            for (int i = 0; i < 4; i++) begin
                if (RA_even[4*i*BYTE +: 4*BYTE] > t) begin    //unsigned comparison
                    temp[4*i*BYTE +: 4*BYTE] = 32'hFFFFFFFF;
                end else begin
                    temp[4*i*BYTE +: 4*BYTE] = 32'h00000000;
                end
            end
        end

        39: begin //ILH: Immediate Load Halfword
            for (int i = 0; i < 8; i++) begin
                temp[2*i*BYTE +: 2*BYTE] = imm_16bit;
            end
        end

        40: begin //ILHU: Immediate Load Halfword Upper
            for (int i=0; i<4; i++) begin
                temp[4*i*BYTE +: 4*BYTE] = {imm_16bit, 16'b0};
            end
        end

        41: begin //ILW: Immediate Load Word
            for (int i = 0; i < 4; i++) begin
                temp[4*i*BYTE +: 4*BYTE] = imm_16bit;
            end
        end

        42: begin //ILA: Immediate Load Address
            for (int i = 0; i < 4; i++) begin
                temp[4*i*BYTE +: 4*BYTE] = {14'b0, imm_18bit};
            end
        end

        43: begin //IOHL: Immediate Or Halfword Lower
            t = {16'b0, imm_16bit};
            for (int i = 0; i < 4; i++) begin
                temp[4*i*BYTE +: 4*BYTE] = RT_even[4*i*BYTE +: 4*BYTE] | t;
            end
        end

        44: begin //FSMBI: Form Select Mask for BYTEs Immediate
            s = imm_16bit;
            for (int j-0; j<16; j++) begin
                if (s[j] == 1'b0) begin
                    temp[j*BYTE +: BYTE] = 8'h00;
                end else begin
                    temp[j*BYTE +: BYTE] = 8'hFF;
                end
            end
        end

        45: begin //SHLH: Shift left halfword
            for (int j=0; j<8; j++) begin
                s = RB_even [2*j*BYTE +: 2*BYTE] & 16'h001F; // only consider the lower 5 bits for shift amount
                t = RA_even [2*j*BYTE +: 2*BYTE];
                for (int b=0; b<16; b++) begin
                    if (b+s < 16) begin
                        temp[b] = t[b+s];
                    end else begin
                        temp[b] = 1'b0;
                    end
                end
            end
        end

        46: begin //SHLHI: Shift left halfword immediate
            s = {{9{imm_7bit[0]}}, imm_7bit} & 16'h001F; // only consider the lower 5 bits for shift amount
            for (int j=0; j<8; j++) begin
                t = RA_even [2*j*BYTE +: 2*BYTE];
                for (int b=0; b<16; b++) begin
                    if (b+s < 16) begin
                        temp[b] = t[b+s];
                    end else begin
                        temp[b] = 1'b0;
                    end
                end
            end
        end

        47: begin //SHL: Shift left word
            for (int j=0; j<4; j++) begin
                s_32bit = RB_even [4*j*BYTE +: 4*BYTE] & 32'h003F; // only consider the lower 7 bits for shift amount
                t = RA_even [4*j*BYTE +: 4*BYTE];
                for (int b=0; b<32; b++) begin
                    if (b+s < 32) begin
                        temp[b] = t[b+s];
                    end else begin
                        temp[b] = 1'b0;
                    end
                end
            end
        end

        48: begin //SHLI: Shift left word immediate
            s_32bit = {{25{imm_7bit[0]}}, imm_7bit} & 16'h003F; // only consider the lower 7 bits for shift amount
            for (int j=0; j<4; j++) begin
                t = RA_even [4*j*BYTE +: 4*BYTE];
                for (int b=0; b<32; b++) begin
                    if (b+s < 32) begin
                        temp[b] = t[b+s];
                    end else begin
                        temp[b] = 1'b0;
                    end
                end
            end
        end

        49: begin //ROTH: Rotate halfword
            for (int j=0; j<8; j++) begin
                s = RB_even [2*j*BYTE +: 2*BYTE] & 16'h000F; // only consider the lower 5 bits for rotate amount
                t_16bit = RA_even [2*j*BYTE +: 2*BYTE];
                for (int b=0; b<16; b++) begin
                    if (b+s < 16) begin
                        temp[b] = t[b+s];
                    end else begin
                        temp[b] = t[b+s-16];
                    end
                end
            end
        end

        50: begin //ROTHI: Rotate halfword immediate
            s = {{9{imm_7bit[0]}}, imm_7bit} & 16'h000F; // only consider the lower 5 bits for rotate amount
            for (int j=0; j<8; j++) begin
                t_16bit = RA_even [2*j*BYTE +: 2*BYTE];
                for (int b=0; b<16; b++) begin
                    if (b+s < 16) begin
                        temp[b] = t[b+s];
                    end else begin
                        temp[b] = t[b+s-16];
                    end
                end
            end
        end

        51: begin //ROT: Rotate word
            for (int j=0; j<4; j++) begin
                s_32bit = RB_even [4*j*BYTE +: 4*BYTE] & 32'h001F; // only consider the lower 7 bits for rotate amount
                t = RA_even [4*j*BYTE +: 4*BYTE];
                for (int b=0; b<32; b++) begin
                    if (b+s < 32) begin
                        temp[b] = t[b+s];
                    end else begin
                        temp[b] = t[b+s-32];
                    end
                end
            end
        end

        52: begin //ROTI: Rotate word immediate
            s_32bit = {{25{imm_7bit[0]}}, imm_7bit} & 16'h001F; // only consider the lower 7 bits for rotate amount
            for (int j=0; j<4; j++) begin
                t = RA_even [4*j*BYTE +: 4*BYTE];
                for (int b=0; b<32; b++) begin
                    if (b+s < 32) begin
                        temp[b] = t[b+s];
                    end else begin
                        temp[b] = t[b+s-32];
                    end
                end
            end
        end

        53: begin //FA: Floating Add
            temp = $bitstoshortreal(RA_even) + $bitstoshortreal(RB_even);
        end
        
        54: begin //FS: Floating Subtract
            temp = $bitstoshortreal(RA_even) - $bitstoshortreal(RB_even);
        end

        55: begin //FM: Floating Multiply
            temp = $bitstoshortreal(RA_even) * $bitstoshortreal(RB_even);
        end

        56: begin //FMA: Floating Multiply and Add
            temp = ($bitstoshortreal(RA_even) * $bitstoshortreal(RB_even)) + $bitstoshortreal(RC_even);
        end

        57: begin //FMS: Floating Multiply and Subtract
            temp = ($bitstoshortreal(RA_even) * $bitstoshortreal(RB_even)) - $bitstoshortreal(RC_even);
        end

        58: begin //MPY: MUltiply
            for (int i = 0; i<4; i++) begin
                temp[4*i*BYTE +: 4*BYTE] = $signed(RA_even[(4*i + 2)*BYTE +: 2*BYTE]) * $signed(RB_even[(4*i + 2)*BYTE +: 2*BYTE]);
            end
        end

        59: begin //MPYU: Multiply Unsigned
            for (int i = 0; i<4; i++) begin
                temp[4*i*BYTE +: 4*BYTE] = RA_even[(4*i + 2)*BYTE +: 2*BYTE] * RB_even[(4*i + 2)*BYTE +: 2*BYTE];
            end
        end

        60: begin //MPYI: Multiply Immediate
            for (int i = 0; i<4; i++) begin
                temp[4*i*BYTE +: 4*BYTE] = RA_even[(4*i + 2)*BYTE +: 2*BYTE] * $signed({{6{imm_10bit[0]}}, imm_10bit});
            end
        end

        61: begin //MPYUI: Multiply Unsigned Immediate
            for (int i = 0; i<4; i++) begin
                temp[4*i*BYTE +: 4*BYTE] = RA_even[(4*i + 2)*BYTE +: 2*BYTE] * {{6{imm_10bit[0]}}, imm_10bit};
            end
        end

        62: begin //MPYA: Multiply and Add
            for(int i = 0; i < 4; i++) begin
                temp[i*4*BYTE +: 4*BYTE] = $signed(RA_even[(4*i+2)*BYTE +: 2*BYTE]) * 
                $signed(RA_odd[(4*i+2)*BYTE +: 2*BYTE]) +
                $signed(RC_even[i*4*BYTE +: 4*BYTE]);
            end
        end

        63: begin //CNTB: Count Ones in Bytes
            for(int i = 0; i < 16; i++) begin
                int c = 0;
                for(int m = 0; m < 8; m++) begin
                    if (RA_even[i * BYTE + m] == 1) c = c + 1;
                end
                temp[i*BYTE +: BYTE] = c;
            end
        end

        64: begin //ABSDB: Absolute differences of Bytes
            for(int i = 0; i < 16; i++) begin
                temp[i * BYTE +: BYTE] = 
                (RB_even[i * BYTE +: BYTE] > RA_even[i * BYTE +: BYTE]) ? 
                (RB_even[i * BYTE +: BYTE] - RA_even[i * BYTE +: BYTE]) :
                (RA_even[i * BYTE +: BYTE] - RB_even[i * BYTE +: BYTE]);
            end
        end

        65 : begin //AVGB: Average Bytes
             for(int i = 0; i < 16; i++) begin
                temp[i * BYTE +: BYTE] = 
                ({8'b0, RA_even[i * BYTE +: BYTE]} + 
                {8'b0, RB_even[i * BYTE +: BYTE]} + 16'd1)[7:14];
             end

        end

        66: begin //SUMB: Sum BYTEs into Halfwords
            //Handle RB sums
            for(int i = 0; i < 4; i++) begin
                temp[4*i*BYTE +: 2 * BYTE] = 
                RB_even[(4*i+0)*BYTE +: BYTE] +
                RB_even[(4*i+1)*BYTE +: BYTE] +
                RB_even[(4*i+2)*BYTE +: BYTE] +
                RB_even[(4*i+3)*BYTE +: BYTE];
            end
            
            //Handle RA sums
            for(int i = 0; i < 4; i++) begin
                temp[(4*i+2)*BYTE +: 2 * BYTE] = 
                RA_even[(4*i+0)*BYTE +: BYTE] +
                RA_even[(4*i+1)*BYTE +: BYTE] +
                RA_even[(4*i+2)*BYTE +: BYTE] +
                RA_even[(4*i+3)*BYTE +: BYTE];
            end
        end
        
        default: temp = 0;
    endcase
end

endmodule