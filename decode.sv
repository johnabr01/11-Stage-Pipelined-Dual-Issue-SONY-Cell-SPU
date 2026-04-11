module decode_stage (
    input  logic        clk,
    input  logic        rst_n,

    input  logic [0:31] instr_even,
    input  logic [0:31] instr_odd,

    // Even pipe decoded outputs
    output logic [0:6]  RT_even,
    output logic [0:6]  RA_even,
    output logic [0:6]  RB_even,
    output logic [0:6]  RC_even,
    output logic [0:6]  ID_even,
    output logic [0:3]  Latency_even,
    output logic        RegWrite_even

    // Odd pipe decoded outputs
    output logic [0:6]  RT_odd,
    output logic [0:6]  RA_odd,
    output logic [0:6]  RB_odd,
    output logic [0:6]  ID_odd,
    output logic [0:3]  Latency_odd,
    output logic        RegWrite_odd
);

    localparam logic [0:6]
        ID_HWNOP     = 7'd0,
        ID_AH        = 7'd1,   ID_AHI      = 7'd2,   ID_A        = 7'd3,
        ID_AI        = 7'd4,   ID_ADDX     = 7'd5,   ID_CG       = 7'd6,
        ID_SFX       = 7'd7,   ID_BG       = 7'd8,   ID_SFH      = 7'd9,
        ID_SFHI      = 7'd10,  ID_SF       = 7'd11,  ID_SFI      = 7'd12,
        ID_AND       = 7'd13,  ID_ANDHI    = 7'd14,  ID_ANDI     = 7'd15,
        ID_OR        = 7'd16,  ID_ORHI     = 7'd17,  ID_ORI      = 7'd18,
        ID_XOR       = 7'd19,  ID_XORHI    = 7'd20,  ID_XORI     = 7'd21,
        ID_NAND      = 7'd22,  ID_NOR      = 7'd23,  ID_CLZ      = 7'd24,
        ID_FSMH      = 7'd25,  ID_FSM      = 7'd26,  ID_CEQH     = 7'd27,
        ID_CEQHI     = 7'd28,  ID_CEQ      = 7'd29,  ID_CEQI     = 7'd30,
        ID_CGTH      = 7'd31,  ID_CGTHI    = 7'd32,  ID_CGT      = 7'd33,
        ID_CGTI      = 7'd34,  ID_CLGTH    = 7'd35,  ID_CLGTHI   = 7'd36,
        ID_CLGT      = 7'd37,  ID_CLGTI    = 7'd38,  ID_ILH      = 7'd39,
        ID_ILHU      = 7'd40,  ID_IL       = 7'd41,  ID_ILA      = 7'd42,
        ID_IOHL      = 7'd43,  ID_FSMBI    = 7'd44,  ID_SHLH     = 7'd45,
        ID_SHLHI     = 7'd46,  ID_SHL      = 7'd47,  ID_SHLI     = 7'd48,
        ID_ROTH      = 7'd49,  ID_ROTHI    = 7'd50,  ID_ROT      = 7'd51,
        ID_ROTI      = 7'd52,  ID_FA       = 7'd53,  ID_FS       = 7'd54,
        ID_FM        = 7'd55,  ID_FMA      = 7'd56,  ID_FMS      = 7'd57,
        ID_MPY       = 7'd58,  ID_MPYU     = 7'd59,  ID_MPYI     = 7'd60,
        ID_MPYUI     = 7'd61,  ID_MPYA     = 7'd62,  ID_CNTB     = 7'd63,
        ID_ABSDB     = 7'd64,  ID_AVGB     = 7'd65,  ID_SUMB     = 7'd66,
        ID_SHLQBI    = 7'd67,  ID_SHLQBII  = 7'd68,  ID_SHLQBY   = 7'd69,
        ID_SHLQBYI   = 7'd70,  ID_ROTQBY   = 7'd71,  ID_ROTQBYI  = 7'd72,
        ID_ROTQBYBI  = 7'd73,  ID_ROTQBI   = 7'd74,  ID_ROTQBII  = 7'd75,
        ID_GBH       = 7'd76,  ID_GB       = 7'd77,  ID_LQD      = 7'd78,
        ID_LQX       = 7'd79,  ID_LQA      = 7'd80,  ID_STQD     = 7'd81,
        ID_STQX      = 7'd82,  ID_STQA     = 7'd83,  ID_BR       = 7'd84,
        ID_BRA       = 7'd85,  ID_BRSL     = 7'd86,  ID_BRASL    = 7'd87,
        ID_BI        = 7'd88,  ID_BRNZ     = 7'd89,  ID_BRZ      = 7'd90,
        ID_BRHNZ     = 7'd91,  ID_BRHZ     = 7'd92,  ID_BIZ      = 7'd93,
        ID_BINZ      = 7'd94,  ID_BIHZ     = 7'd95,  ID_BIHNZ    = 7'd96,
        ID_NOP       = 7'd97,  ID_LNOP     = 7'd98,  ID_STOP     = 7'd99;
        

    // Even intruction decode
    always_comb begin
        RT_even = 7'h0;
        RA_even = 7'h0;
        RB_even = 7'h0;
        RC_even = 7'h0;
        ID_even = ID_HWNOP;
        RegWrite_even = 1'b1;
        Latency_even = 4'h0;

        casez (instr_even[0:10])
            // -----------------------------------------------------------------
            // RRR (4-bit opcode): RT=[4:10] RB=[11:17] RA=[18:24] RC=[25:31]
            // -----------------------------------------------------------------
            11'b1110???????: begin  // fma
                Latency_even = 7;
                RT_even = instr_even[4:10];  RB_even = instr_even[11:17];
                RA_even = instr_even[18:24]; RC_even = instr_even[25:31];
                ID_even = ID_FMA;
            end
            11'b1111???????: begin  // fms
                Latency_even = 7;
                RT_even = instr_even[4:10];  RB_even = instr_even[11:17];
                RA_even = instr_even[18:24]; RC_even = instr_even[25:31];
                ID_even = ID_FMS;
            end
            11'b1100???????: begin  // mpya
                Latency_even = 8;
                RT_even = instr_even[4:10];  RB_even = instr_even[11:17];
                RA_even = instr_even[18:24]; RC_even = instr_even[25:31];
                ID_even = ID_MPYA;
            end

            // -----------------------------------------------------------------
            // RI18 (7-bit opcode): RT=[25:31]
            // -----------------------------------------------------------------
            11'b0100001????: begin  // ila  //IMPLEMENT IN THE ASSEMBLER
                Latency_even = 3;
                RT_even = instr_even[25:31];
                ID_even = ID_ILA;
            end

            // -----------------------------------------------------------------
            // RI16 (9-bit opcode): RT=[25:31]
            // -----------------------------------------------------------------
            11'b010000011??: begin Latency_even = 3; RT_even = instr_even[25:31]; ID_even = ID_ILH;   end
            11'b010000010??: begin Latency_even = 3; RT_even = instr_even[25:31]; ID_even = ID_ILHU;  end
            11'b010000001??: begin Latency_even = 3; RT_even = instr_even[25:31]; ID_even = ID_IL;    end
            11'b011000001??: begin Latency_even = 3; RT_even = instr_even[25:31]; ID_even = ID_IOHL;  end
            11'b001100101??: begin Latency_even = 3; RT_even = instr_even[25:31]; ID_even = ID_FSMBI; end
            
            
            // -----------------------------------------------------------------
            // RI10 (8-bit opcode): RT=[25:31] RA=[18:24]
            // Bottom 3 bits of window are the top 3 bits of I10 -> don't-care
            // -----------------------------------------------------------------
            11'b00011101???: begin  // ahi
                Latency_even = 3; RT_even = instr_even[25:31]; RA_even = instr_even[18:24]; ID_even = ID_AHI;
            end
            11'b00011100???: begin  // ai
                Latency_even = 3; RT_even = instr_even[25:31]; RA_even = instr_even[18:24]; ID_even = ID_AI;
            end
            11'b00001101???: begin  // sfhi
                Latency_even = 3; RT_even = instr_even[25:31]; RA_even = instr_even[18:24]; ID_even = ID_SFHI;
            end
            11'b00001100???: begin  // sfi
                Latency_even = 3; RT_even = instr_even[25:31]; RA_even = instr_even[18:24]; ID_even = ID_SFI;
            end
            11'b00010101???: begin  // andhi
                Latency_even = 3; RT_even = instr_even[25:31]; RA_even = instr_even[18:24]; ID_even = ID_ANDHI;
            end
            11'b00010100???: begin  // andi
                Latency_even = 3; RT_even = instr_even[25:31]; RA_even = instr_even[18:24]; ID_even = ID_ANDI;
            end
            11'b00000101???: begin  // orhi
                Latency_even = 3; RT_even = instr_even[25:31]; RA_even = instr_even[18:24]; ID_even = ID_ORHI;
            end
            11'b00000100???: begin  // ori
                Latency_even = 3; RT_even = instr_even[25:31]; RA_even = instr_even[18:24]; ID_even = ID_ORI;
            end
            11'b01000101???: begin  // xorhi
                Latency_even = 3; RT_even = instr_even[25:31]; RA_even = instr_even[18:24]; ID_even = ID_XORHI;
            end
            11'b01000100???: begin  // xori
                Latency_even = 3; RT_even = instr_even[25:31]; RA_even = instr_even[18:24]; ID_even = ID_XORI;
            end
            11'b01111101???: begin  // ceqhi
                Latency_even = 3; RT_even = instr_even[25:31]; RA_even = instr_even[18:24]; ID_even = ID_CEQHI;
            end
            11'b01111100???: begin  // ceqi
                Latency_even = 3; RT_even = instr_even[25:31]; RA_even = instr_even[18:24]; ID_even = ID_CEQI;
            end
            11'b01001101???: begin  // cgthi
                Latency_even = 3; RT_even = instr_even[25:31]; RA_even = instr_even[18:24]; ID_even = ID_CGTHI;
            end
            11'b01001100???: begin  // cgti
                Latency_even = 3; RT_even = instr_even[25:31]; RA_even = instr_even[18:24]; ID_even = ID_CGTI;
            end
            11'b01011101???: begin  // clgthi
                Latency_even = 3; RT_even = instr_even[25:31]; RA_even = instr_even[18:24]; ID_even = ID_CLGTHI;
            end
            11'b01011100???: begin  // clgti
                Latency_even = 3; RT_even = instr_even[25:31]; RA_even = instr_even[18:24]; ID_even = ID_CLGTI;
            end
            11'b01110100???: begin  // mpyi
                Latency_even = 8; RT_even = instr_even[25:31]; RA_even = instr_even[18:24]; ID_even = ID_MPYI;
            end
            11'b01110101???: begin  // mpyui
                Latency_even = 8; RT_even = instr_even[25:31]; RA_even = instr_even[18:24]; ID_even = ID_MPYUI;
            end

            // -----------------------------------------------------------------
            // RR (11-bit opcode): RT=[25:31] RA=[18:24] RB=[11:17]
            // -----------------------------------------------------------------
            11'b00011001000: begin
                Latency_even = 3; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_AH;
            end
            11'b00011000000: begin
                Latency_even = 3; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_A;
            end
            11'b01101000000: begin
                Latency_even = 3; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_ADDX;
            end
            11'b00011000010: begin
                Latency_even = 3; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_CG;
            end
            11'b01101000001: begin
                Latency_even = 3; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_SFX;
            end
            11'b00001000010: begin
                Latency_even = 3; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_BG;
            end
            11'b00001001000: begin
                Latency_even = 3; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_SFH;
            end
            11'b00001000000: begin
                Latency_even = 3; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_SF;
            end
            11'b00011000001: begin
                Latency_even = 3; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_AND;
            end
            11'b00001000001: begin
                Latency_even = 3; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_OR;
            end
            11'b01001000001: begin
                Latency_even = 3; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_XOR;
            end
            11'b00011001001: begin
                Latency_even = 3; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_NAND;
            end
            11'b00001001001: begin
                Latency_even = 3; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_NOR;
            end
            11'b01111001000: begin
                Latency_even = 3; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_CEQH;
            end
            11'b01111000000: begin
                Latency_even = 3; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_CEQ;
            end
            11'b01001001000: begin
                Latency_even = 3; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_CGTH;
            end
            11'b01001000000: begin
                Latency_even = 3; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_CGT;
            end
            11'b01011001000: begin
                Latency_even = 3; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_CLGTH;
            end
            11'b01011000000: begin
                Latency_even = 3; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_CLGT;
            end
            11'b00001011111: begin
                Latency_even = 4; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_SHLH;
            end
            11'b00001011011: begin
                Latency_even = 4; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_SHL;
            end
            11'b00001011100: begin
                Latency_even = 4; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_ROTH;
            end
            11'b00001011000: begin
                Latency_even = 4; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_ROT;
            end
            11'b01011000100: begin
                Latency_even = 7; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_FA;
            end
            11'b01011000101: begin
                Latency_even = 7; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_FS;
            end
            11'b01011000110: begin
                Latency_even = 7; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_FM;
            end
            11'b01111000100: begin
                Latency_even = 8; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_MPY;
            end
            11'b01111001100: begin
                Latency_even = 8; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_MPYU;
            end
            11'b00001010011: begin
                Latency_even = 4; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_ABSDB;
            end
            11'b00011010011: begin
                Latency_even = 4; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_AVGB;
            end
            11'b01001010011: begin
                Latency_even = 4; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24];
                RB_even = instr_even[11:17]; ID_even = ID_SUMB;
            end

            // -----------------------------------------------------------------
            // RI7 even-pipe (11-bit opcode): RT=[25:31] RA=[18:24]
            // -----------------------------------------------------------------
            11'b00001111111: begin
                Latency_even = 4; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24]; ID_even = ID_SHLHI;
            end
            11'b00001111011: begin
                Latency_even = 4; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24]; ID_even = ID_SHLI;
            end
            11'b00001111100: begin
                Latency_even = 4; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24]; ID_even = ID_ROTHI;
            end
            11'b00001111000: begin
                Latency_even = 4; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24]; ID_even = ID_ROTI;
            end
            11'b01010100101: begin  // clz
            Latency_even = 3; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24]; ID_even = ID_CLZ;
            end
            11'b00110110101: begin  // fsmh
                Latency_even = 3; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24]; ID_even = ID_FSMH;
            end
            11'b00110110100: begin  // fsm
                Latency_even = 3; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24]; ID_even = ID_FSM;
            end
            11'b01010110100: begin  // cntb
                Latency_even = 4; 
                RT_even = instr_even[25:31]; RA_even = instr_even[18:24]; ID_even = ID_CNTB;
            end

            /// Special (even)
            11'b01000000001: begin RegWrite_even = 0; ID_even = ID_NOP;  end  // nop
            11'b00000000000: begin RegWrite_even = 0; ID_even = ID_STOP; end  // stop

        endcase
    end

    // Odd piipe
    always_comb begin
        RT_odd = 7'h0;
        RA_odd = 7'h0;
        RB_odd = 7'h0;
        ID_odd = ID_HWNOP;
        RegWrite_odd = 1'b1;
        Latency_odd = 4'h0;

        casez (instr_odd[0:10])
            // -----------------------------------------------------------------
            // RI16 (9-bit opcode): RT=[25:31]
            // -----------------------------------------------------------------
            11'b001100001??: begin 
                RT_odd = instr_odd[25:31]; ID_odd = ID_LQA;  
                Latency_odd = 4'h7; 
            end
            11'b001000001??: begin 
                RegWrite_odd = 0; 
                RT_odd = instr_odd[25:31]; ID_odd = ID_STQA; 
                Latency_odd = 4'h7; 
            end
            11'b001100100??: begin 
                RegWrite_odd = 0;
                RT_odd = instr_odd[25:31]; ID_odd = ID_BR;
                Latency_odd = 4'h2;
            end
            11'b001100000??: begin
                RegWrite_odd = 0;
                RT_odd = instr_odd[25:31]; ID_odd = ID_BRA;  
                Latency_odd = 4'h2; 
            end
            11'b001100110??: begin 
                RT_odd = instr_odd[25:31]; 
                ID_odd = ID_BRSL;  
                Latency_odd = 4'h2;
            end
            11'b001100010??: begin 
                RT_odd = instr_odd[25:31]; 
                ID_odd = ID_BRASL; 
                Latency_odd = 4'h2;
            end
            11'b001000010??: begin 
                RegWrite_odd = 0;
                RT_odd = instr_odd[25:31]; 
                ID_odd = ID_BRNZ;
                Latency_odd = 4'h2;  
            end
            11'b001000000??: begin 
                RegWrite_odd = 0;
                RT_odd = instr_odd[25:31]; ID_odd = ID_BRZ;
                Latency_odd = 4'h2;
            end
            11'b001000110??: begin 
                RegWrite_odd = 0; 
                Latency_odd = 4'h2;
                RT_even = instr_even[25:31]; ID_even = ID_BRHNZ; 
            end
            11'b001000100??: begin 
                RegWrite_odd = 0; 
                Latency_odd = 4'h2;
                RT_even = instr_even[25:31]; ID_even = ID_BRHZ;
            end

            // -----------------------------------------------------------------
            // RI10 (8-bit opcode): RT=[25:31] RA=[18:24]
            // -----------------------------------------------------------------
            11'b00110100???: begin  // lqd
                RT_odd = instr_odd[25:31]; RA_odd = instr_odd[18:24]; ID_odd = ID_LQD; Latency_odd = 4'h7;
            end
            11'b00100100???: begin  // stqd
                RegWrite_odd = 0; 
                RT_odd = instr_odd[25:31]; RA_odd = instr_odd[18:24]; ID_odd = ID_STQD; Latency_odd = 4'h7;
            end

            // -----------------------------------------------------------------
            // RR (11-bit opcode): RT=[25:31] RA=[18:24] RB=[11:17]
            // -----------------------------------------------------------------
            11'b00111011011: begin
                RT_odd = instr_odd[25:31]; RA_odd = instr_odd[18:24]; Latency_odd = 4'h4;
                RB_odd = instr_odd[11:17]; ID_odd = ID_SHLQBI;
            end
            11'b00111011111: begin
                RT_odd = instr_odd[25:31]; RA_odd = instr_odd[18:24]; Latency_odd = 4'h4;
                RB_odd = instr_odd[11:17]; ID_odd = ID_SHLQBY;
            end
            11'b00111011100: begin
                RT_odd = instr_odd[25:31]; RA_odd = instr_odd[18:24]; Latency_odd = 4'h4;
                RB_odd = instr_odd[11:17]; ID_odd = ID_ROTQBY;
            end
            11'b00111001100: begin
                RT_odd = instr_odd[25:31]; RA_odd = instr_odd[18:24]; Latency_odd = 4'h4;
                RB_odd = instr_odd[11:17]; ID_odd = ID_ROTQBYBI;
            end
            11'b00111011000: begin
                RT_odd = instr_odd[25:31]; RA_odd = instr_odd[18:24]; Latency_odd = 4'h4;
                RB_odd = instr_odd[11:17]; ID_odd = ID_ROTQBI;
            end
            11'b00111000100: begin
                RT_odd = instr_odd[25:31]; RA_odd = instr_odd[18:24]; Latency_odd = 4'h7;
                RB_odd = instr_odd[11:17]; ID_odd = ID_LQX;
            end
            11'b00101000100: begin
                RegWrite_odd = 0;
                RT_odd = instr_odd[25:31]; RA_odd = instr_odd[18:24]; Latency_odd = 4'h7;
                RB_odd = instr_odd[11:17]; ID_odd = ID_STQX;
            end

            // -----------------------------------------------------------------
            // RI7 (11-bit opcode): RT=[25:31] RA=[18:24]
            // -----------------------------------------------------------------
            11'b00111111011: begin
                RT_odd = instr_odd[25:31]; RA_odd = instr_odd[18:24]; ID_odd = ID_SHLQBII; Latency_odd = 4'h4;
            end
            11'b00111111111: begin
                RT_odd = instr_odd[25:31]; RA_odd = instr_odd[18:24]; ID_odd = ID_SHLQBYI; Latency_odd = 4'h4;
            end
            11'b00111111100: begin
                RT_odd = instr_odd[25:31]; RA_odd = instr_odd[18:24]; ID_odd = ID_ROTQBYI; Latency_odd = 4'h4;
            end
            11'b00111111000: begin
                RT_odd = instr_odd[25:31]; RA_odd = instr_odd[18:24]; ID_odd = ID_ROTQBII; Latency_odd = 4'h4;
            end
            11'b00110101000: begin  // bi  (no RT)
                RegWrite_odd = 0; Latency_odd = 4'h2;
                RA_odd = instr_odd[18:24]; ID_odd = ID_BI;
            end
            11'b00100101000: begin  // biz (no RT)
                RegWrite_odd = 0; Latency_odd = 4'h2;
                RT_odd = instr_odd[25:31]; RA_odd = instr_odd[18:24]; ID_odd = ID_BIZ; 
            end
            11'b00100101001: begin  // binz (no RT)
                RegWrite_odd = 0; Latency_odd = 4'h2;
                RT_odd = instr_odd[25:31]; RA_odd = instr_odd[18:24]; ID_odd = ID_BINZ; 
            end
            11'b00100101010: begin  // bihz (no RT)
                RegWrite_odd = 0; Latency_odd = 4'h2;
                RT_odd = instr_odd[25:31]; RA_odd = instr_odd[18:24]; ID_odd = ID_BIHZ;
            end
            11'b00100101011: begin  // bihnz (no RT)
                RegWrite_odd = 0; Latency_odd = 4'h2;
                RT_odd = instr_odd[25:31]; RA_odd = instr_odd[18:24]; ID_odd = ID_BIHNZ;
            end
            11'b00110110001: begin  // gbh
                RT_odd = instr_odd[25:31]; RA_odd = instr_odd[18:24]; ID_odd = ID_GBH; Latency_odd = 4'h4;
            end
            11'b00110110000: begin  // gb
                RT_odd = instr_odd[25:31]; RA_odd = instr_odd[18:24]; ID_odd = ID_GB; Latency_odd = 4'h4;
            end

            // Special (Odd)
            11'b00000000001: begin 
                RegWrite_odd = 0;
                ID_odd = ID_LNOP; 
            end  // lnop
            11'b00000000000: begin 
                RegWrite_odd = 0;
                ID_odd = ID_STOP; 
            end  // stop

        endcase
    end

endmodule