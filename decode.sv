module decode_stage #(
    localparam ODDTYPE = 0,
    localparam EVENTYPE = 1,
    localparam STOP = 2
)(
    input  logic        clk,
    input  logic        rst_n,

    input  logic [0:31] instr,

    //decoded outputs
    output logic [0:6]  RT,
    output logic [0:6]  RA,
    output logic [0:6]  RB,
    output logic [0:6]  RC,
    output logic [0:6]  ID,
    output logic [0:3]  Latency,
    output logic        RegWrite,
    output logic        Instr_type,

    output logic        RT_source,
    output logic        RA_source,
    output logic        RB_source,
    output logic        RC_source
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
        

    // intruction decode
    always_comb begin
        RT = 7'h0;
        RA = 7'h0;
        RB = 7'h0;
        RC = 7'h0;
        ID = ID_HWNOP;
        RegWrite = 1'b1;
        Latency = 4'h0;

        RT_source = 0;
        RA_source = 1;
        RB_source = 1;
        RC_source = 0;

        //Note: default - RA & RB sources, RT and RC not sources
        casez (instr[0:10])
            // -----------------------------------------------------------------
            // RRR (4-bit opcode): RT=[4:10] RB=[11:17] RA=[18:24] RC=[25:31]
            // -----------------------------------------------------------------
            11'b1110???????: begin  // fma
                RC_source = 1;
                Latency = 7;
                RT = instr[4:10];  RB = instr[11:17];
                RA = instr[18:24]; RC = instr[25:31];
                ID = ID_FMA; Instr_type = EVENTYPE;
            end
            11'b1111???????: begin  // fms
                RC_source = 1;
                Latency = 7;
                RT = instr[4:10];  RB = instr[11:17];
                RA = instr[18:24]; RC = instr[25:31];
                ID = ID_FMS; Instr_type = EVENTYPE;
            end
            11'b1100???????: begin  // mpya
                RC_source = 1;
                Latency = 8;
                RT = instr[4:10];  RB = instr[11:17];
                RA = instr[18:24]; RC = instr[25:31];
                ID = ID_MPYA; Instr_type = EVENTYPE;
            end

            // -----------------------------------------------------------------
            // RI18 (7-bit opcode): RT=[25:31]
            // -----------------------------------------------------------------
            11'b0100001????: begin  // ila  //IMPLEMENT IN THE ASSEMBLER
                RA_source = 0;
                RB_source = 0;
                Latency = 3;
                RT = instr[25:31];
                ID = ID_ILA; Instr_type = EVENTYPE;
            end

            // -----------------------------------------------------------------
            // RI16 (9-bit opcode): RT=[25:31]
            // -----------------------------------------------------------------
            11'b010000011??: begin 
                RA_source = 0; RB_source = 0;
                Latency = 3; RT = instr[25:31]; ID = ID_ILH; Instr_type = EVENTYPE;   
            end
            11'b010000010??: begin 
                RA_source = 0; RB_source = 0;
                Latency = 3; RT = instr[25:31]; ID = ID_ILHU; Instr_type = EVENTYPE;  
            end
            11'b010000001??: begin 
                RA_source = 0; RB_source = 0;
                Latency = 3; RT = instr[25:31]; ID = ID_IL; Instr_type = EVENTYPE;    
            end
            11'b011000001??: begin 
                RT_source = 1;
                RA_source = 0; RB_source = 0;
                Latency = 3; RT = instr[25:31]; ID = ID_IOHL; Instr_type = EVENTYPE;  
            end
            11'b001100101??: begin 
                RA_source = 0; RB_source = 0;
                Latency = 3; RT = instr[25:31]; ID = ID_FSMBI; Instr_type = EVENTYPE; 
            end
            
            
            // -----------------------------------------------------------------
            // RI10 (8-bit opcode): RT=[25:31] RA=[18:24]
            // Bottom 3 bits of window are the top 3 bits of I10 -> don't-care
            // -----------------------------------------------------------------
            11'b00011101???: begin  // ahi
                RB_source = 0;
                Latency = 3; RT = instr[25:31]; RA = instr[18:24]; ID = ID_AHI; Instr_type = EVENTYPE;
            end
            11'b00011100???: begin  // ai
                RB_source = 0;
                Latency = 3; RT = instr[25:31]; RA = instr[18:24]; ID = ID_AI; Instr_type = EVENTYPE;
            end
            11'b00001101???: begin  // sfhi
                RB_source = 0;
                Latency = 3; RT = instr[25:31]; RA = instr[18:24]; ID = ID_SFHI; Instr_type = EVENTYPE;
            end
            11'b00001100???: begin  // sfi
                RB_source = 0;
                Latency = 3; RT = instr[25:31]; RA = instr[18:24]; ID = ID_SFI; Instr_type = EVENTYPE;
            end
            11'b00010101???: begin  // andhi
                RB_source = 0;
                Latency = 3; RT = instr[25:31]; RA = instr[18:24]; ID = ID_ANDHI; Instr_type = EVENTYPE;
            end
            11'b00010100???: begin  // andi
                RB_source = 0;
                Latency = 3; RT = instr[25:31]; RA = instr[18:24]; ID = ID_ANDI; Instr_type = EVENTYPE;
            end
            11'b00000101???: begin  // orhi
                RB_source = 0;
                Latency = 3; RT = instr[25:31]; RA = instr[18:24]; ID = ID_ORHI; Instr_type = EVENTYPE;
            end
            11'b00000100???: begin  // ori
                RB_source = 0;
                Latency = 3; RT = instr[25:31]; RA = instr[18:24]; ID = ID_ORI; Instr_type = EVENTYPE;
            end
            11'b01000101???: begin  // xorhi
                RB_source = 0;
                Latency = 3; RT = instr[25:31]; RA = instr[18:24]; ID = ID_XORHI; Instr_type = EVENTYPE;
            end
            11'b01000100???: begin  // xori
                RB_source = 0;
                Latency = 3; RT = instr[25:31]; RA = instr[18:24]; ID = ID_XORI; Instr_type = EVENTYPE;
            end
            11'b01111101???: begin  // ceqhi
                RB_source = 0;
                Latency = 3; RT = instr[25:31]; RA = instr[18:24]; ID = ID_CEQHI; Instr_type = EVENTYPE;
            end
            11'b01111100???: begin  // ceqi
                RB_source = 0;
                Latency = 3; RT = instr[25:31]; RA = instr[18:24]; ID = ID_CEQI; Instr_type = EVENTYPE;
            end
            11'b01001101???: begin  // cgthi
                RB_source = 0;
                Latency = 3; RT = instr[25:31]; RA = instr[18:24]; ID = ID_CGTHI; Instr_type = EVENTYPE;
            end
            11'b01001100???: begin  // cgti
                RB_source = 0;
                Latency = 3; RT = instr[25:31]; RA = instr[18:24]; ID = ID_CGTI; Instr_type = EVENTYPE;
            end
            11'b01011101???: begin  // clgthi
                RB_source = 0;
                Latency = 3; RT = instr[25:31]; RA = instr[18:24]; ID = ID_CLGTHI; Instr_type = EVENTYPE;
            end
            11'b01011100???: begin  // clgti
                RB_source = 0;
                Latency = 3; RT = instr[25:31]; RA = instr[18:24]; ID = ID_CLGTI; Instr_type = EVENTYPE;
            end
            11'b01110100???: begin  // mpyi
                RB_source = 0;
                Latency = 8; RT = instr[25:31]; RA = instr[18:24]; ID = ID_MPYI; Instr_type = EVENTYPE;
            end
            11'b01110101???: begin  // mpyui
                RB_source = 0;
                Latency = 8; RT = instr[25:31]; RA = instr[18:24]; ID = ID_MPYUI; Instr_type = EVENTYPE;
            end

            // -----------------------------------------------------------------
            // RR (11-bit opcode): RT=[25:31] RA=[18:24] RB=[11:17]
            // -----------------------------------------------------------------
            11'b00011001000: begin
                Latency = 3; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_AH; Instr_type = EVENTYPE;
            end
            11'b00011000000: begin
                Latency = 3; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_A; Instr_type = EVENTYPE;
            end
            11'b01101000000: begin
                RT_source = 1;
                Latency = 3; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_ADDX; Instr_type = EVENTYPE;
            end
            11'b00011000010: begin
                Latency = 3; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_CG; Instr_type = EVENTYPE;
            end
            11'b01101000001: begin
                RT_source = 1;
                Latency = 3; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_SFX; Instr_type = EVENTYPE;
            end
            11'b00001000010: begin
                Latency = 3; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_BG; Instr_type = EVENTYPE;
            end
            11'b00001001000: begin
                Latency = 3; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_SFH; Instr_type = EVENTYPE;
            end
            11'b00001000000: begin
                Latency = 3; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_SF; Instr_type = EVENTYPE;
            end
            11'b00011000001: begin
                Latency = 3; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_AND; Instr_type = EVENTYPE;
            end
            11'b00001000001: begin
                Latency = 3; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_OR; Instr_type = EVENTYPE;
            end
            11'b01001000001: begin
                Latency = 3; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_XOR; Instr_type = EVENTYPE;
            end
            11'b00011001001: begin
                Latency = 3; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_NAND; Instr_type = EVENTYPE;
            end
            11'b00001001001: begin
                Latency = 3; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_NOR; Instr_type = EVENTYPE;
            end
            11'b01111001000: begin
                Latency = 3; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_CEQH; Instr_type = EVENTYPE;
            end
            11'b01111000000: begin
                Latency = 3; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_CEQ; Instr_type = EVENTYPE;
            end
            11'b01001001000: begin
                Latency = 3; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_CGTH; Instr_type = EVENTYPE;
            end
            11'b01001000000: begin
                Latency = 3; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_CGT; Instr_type = EVENTYPE;
            end
            11'b01011001000: begin
                Latency = 3; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_CLGTH; Instr_type = EVENTYPE;
            end
            11'b01011000000: begin
                Latency = 3; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_CLGT; Instr_type = EVENTYPE;
            end
            11'b00001011111: begin
                Latency = 4; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_SHLH; Instr_type = EVENTYPE;
            end
            11'b00001011011: begin
                Latency = 4; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_SHL; Instr_type = EVENTYPE;
            end
            11'b00001011100: begin
                Latency = 4; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_ROTH; Instr_type = EVENTYPE;
            end
            11'b00001011000: begin
                Latency = 4; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_ROT; Instr_type = EVENTYPE;
            end
            11'b01011000100: begin
                Latency = 7; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_FA; Instr_type = EVENTYPE;
            end
            11'b01011000101: begin
                Latency = 7; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_FS; Instr_type = EVENTYPE;
            end
            11'b01011000110: begin
                Latency = 7; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_FM; Instr_type = EVENTYPE;
            end
            11'b01111000100: begin
                Latency = 8; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_MPY; Instr_type = EVENTYPE;
            end
            11'b01111001100: begin
                Latency = 8; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_MPYU; Instr_type = EVENTYPE;
            end
            11'b00001010011: begin
                Latency = 4; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_ABSDB; Instr_type = EVENTYPE;
            end
            11'b00011010011: begin
                Latency = 4; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_AVGB; Instr_type = EVENTYPE;
            end
            11'b01001010011: begin
                Latency = 4; 
                RT = instr[25:31]; RA = instr[18:24];
                RB = instr[11:17]; ID = ID_SUMB; Instr_type = EVENTYPE;
            end

            // -----------------------------------------------------------------
            // RI7 even-pipe (11-bit opcode): RT=[25:31] RA=[18:24]
            // -----------------------------------------------------------------
            11'b00001111111: begin
                RB_source = 0;
                Latency = 4; 
                RT = instr[25:31]; RA = instr[18:24]; ID = ID_SHLHI; Instr_type = EVENTYPE;
            end
            11'b00001111011: begin
                RB_source = 0;
                Latency = 4; 
                RT = instr[25:31]; RA = instr[18:24]; ID = ID_SHLI; Instr_type = EVENTYPE;
            end
            11'b00001111100: begin
                RB_source = 0;
                Latency = 4; 
                RT = instr[25:31]; RA = instr[18:24]; ID = ID_ROTHI; Instr_type = EVENTYPE;
            end
            11'b00001111000: begin
                RB_source = 0;
                Latency = 4; 
                RT = instr[25:31]; RA = instr[18:24]; ID = ID_ROTI; Instr_type = EVENTYPE;
            end
            11'b01010100101: begin  // clz
                RB_source = 0;
                Latency = 3; 
                RT = instr[25:31]; RA = instr[18:24]; ID = ID_CLZ; Instr_type = EVENTYPE;
            end
            11'b00110110101: begin  // fsmh
                RB_source = 0;
                Latency = 3; 
                RT = instr[25:31]; RA = instr[18:24]; ID = ID_FSMH; Instr_type = EVENTYPE;
            end
            11'b00110110100: begin  // fsm
                RB_source = 0;
                Latency = 3; 
                RT = instr[25:31]; RA = instr[18:24]; ID = ID_FSM; Instr_type = EVENTYPE;
            end
            11'b01010110100: begin  // cntb
                RB_source = 0;
                Latency = 4; 
                RT = instr[25:31]; RA = instr[18:24]; ID = ID_CNTB; Instr_type = EVENTYPE;
            end
            
            // -----------------------------------------------------------------
            // ODD-INSTRUCTIONS
            // -----------------------------------------------------------------

            // -----------------------------------------------------------------
            // RI16 (9-bit opcode): RT=[25:31]
            // -----------------------------------------------------------------
            11'b001100001??: begin 
                RA_source = 0; RB_source = 0;
                RT = instr[25:31]; ID = ID_LQA;  
                Latency = 4'h7; Instr_type = ODDTYPE;  
            end
            11'b001000001??: begin 
                RA_source = 0; RB_source = 0;
                RegWrite = 0; 
                RT = instr[25:31]; ID = ID_STQA; 
                Latency = 4'h7; Instr_type = ODDTYPE;  
            end
            11'b001100100??: begin 
                RA_source = 0; RB_source = 0;
                RegWrite = 0;
                RT = instr[25:31]; ID = ID_BR;
                Latency = 4'h2; Instr_type = ODDTYPE; 
            end
            11'b001100000??: begin
                RA_source = 0; RB_source = 0;
                RegWrite = 0;
                RT = instr[25:31]; ID = ID_BRA;  
                Latency = 4'h2; Instr_type = ODDTYPE;  
            end
            11'b001100110??: begin 
                RA_source = 0; RB_source = 0;
                RT = instr[25:31]; Instr_type = ODDTYPE; 
                ID = ID_BRSL;  
                Latency = 4'h2;
            end
            //UP TO HERE TO RESUME AGAIN FOR SOURCE REGISTERS
            11'b001100010??: begin 
                RA_source = 0; RB_source = 0;
                RT = instr[25:31];  Instr_type = ODDTYPE;  
                ID = ID_BRASL; 
                Latency = 4'h2;
            end
            11'b001000010??: begin 
                RT_source = 1;
                RA_source = 0; RB_source = 0;
                RegWrite = 0;
                RT = instr[25:31]; Instr_type = ODDTYPE;  
                ID = ID_BRNZ;
                Latency = 4'h2;  
            end
            11'b001000000??: begin 
                RT_source = 1;
                RA_source = 0; RB_source = 0;
                RegWrite = 0; Instr_type = ODDTYPE; 
                RT = instr[25:31]; ID = ID_BRZ;
                Latency = 4'h2;
            end
            11'b001000110??: begin 
                RT_source = 1;
                RA_source = 0; RB_source = 0;
                RegWrite = 0; 
                Latency = 4'h2; Instr_type = ODDTYPE; 
                RT = instr[25:31]; ID = ID_BRHNZ; 
            end
            11'b001000100??: begin 
                RT_source = 1;
                RA_source = 0; RB_source = 0;
                RegWrite = 0; 
                Latency = 4'h2; Instr_type = ODDTYPE; 
                RT = instr[25:31]; ID = ID_BRHZ;
            end

            // -----------------------------------------------------------------
            // RI10 (8-bit opcode): RT=[25:31] RA=[18:24]
            // -----------------------------------------------------------------
            11'b00110100???: begin  // lqd
                RB_source = 0;
                RT = instr[25:31]; RA = instr[18:24]; ID = ID_LQD; Latency = 4'h7; Instr_type = ODDTYPE; 
            end
            11'b00100100???: begin  // stqd
                RT_source = 1;
                RB_source = 0;
                RegWrite = 0; 
                RT = instr[25:31]; RA = instr[18:24]; ID = ID_STQD; Latency = 4'h7; Instr_type = ODDTYPE; 
            end

            // -----------------------------------------------------------------
            // RR (11-bit opcode): RT=[25:31] RA=[18:24] RB=[11:17]
            // -----------------------------------------------------------------
            11'b00111011011: begin

                RT = instr[25:31]; RA = instr[18:24]; Latency = 4'h4;
                RB = instr[11:17]; ID = ID_SHLQBI; Instr_type = ODDTYPE; 
            end
            11'b00111011111: begin
                RT = instr[25:31]; RA = instr[18:24]; Latency = 4'h4;
                RB = instr[11:17]; ID = ID_SHLQBY; Instr_type = ODDTYPE; 
            end
            11'b00111011100: begin
                RT = instr[25:31]; RA = instr[18:24]; Latency = 4'h4;
                RB = instr[11:17]; ID = ID_ROTQBY; Instr_type = ODDTYPE; 
            end
            11'b00111001100: begin
                RT = instr[25:31]; RA = instr[18:24]; Latency = 4'h4;
                RB = instr[11:17]; ID = ID_ROTQBYBI; Instr_type = ODDTYPE; 
            end
            11'b00111011000: begin
                RT = instr[25:31]; RA = instr[18:24]; Latency = 4'h4;
                RB = instr[11:17]; ID = ID_ROTQBI; Instr_type = ODDTYPE; 
            end
            11'b00111000100: begin
                RT = instr[25:31]; RA = instr[18:24]; Latency = 4'h7;
                RB = instr[11:17]; ID = ID_LQX; Instr_type = ODDTYPE; 
            end
            11'b00101000100: begin
                RT_source = 1;
                RegWrite = 0;
                RT = instr[25:31]; RA = instr[18:24]; Latency = 4'h7;
                RB = instr[11:17]; ID = ID_STQX; Instr_type = ODDTYPE; 
            end

            // -----------------------------------------------------------------
            // RI7 (11-bit opcode): RT=[25:31] RA=[18:24]
            // -----------------------------------------------------------------
            11'b00111111011: begin
                RB_source = 0;
                RT = instr[25:31]; RA = instr[18:24]; ID = ID_SHLQBII; Latency = 4'h4; Instr_type = ODDTYPE; 
            end
            11'b00111111111: begin
                RB_source = 0;
                RT = instr[25:31]; RA = instr[18:24]; ID = ID_SHLQBYI; Latency = 4'h4; Instr_type = ODDTYPE; 
            end
            11'b00111111100: begin
                RB_source = 0;
                RT = instr[25:31]; RA = instr[18:24]; ID = ID_ROTQBYI; Latency = 4'h4; Instr_type = ODDTYPE; 
            end
            11'b00111111000: begin
                RB_source = 0;
                RT = instr[25:31]; RA = instr[18:24]; ID = ID_ROTQBII; Latency = 4'h4; Instr_type = ODDTYPE; 
            end
            11'b00110101000: begin  // bi  (no RT)
                RB_source = 0;
                RegWrite = 0; Latency = 4'h2;
                RA = instr[18:24]; ID = ID_BI; Instr_type = ODDTYPE; 
            end
            11'b00100101000: begin  // biz (no RT)
                RT_source = 1; RB_source = 0;
                RegWrite = 0; Latency = 4'h2;
                RT = instr[25:31]; RA = instr[18:24]; ID = ID_BIZ; Instr_type = ODDTYPE;  
            end
            11'b00100101001: begin  // binz (no RT)
                RT_source = 1; RB_source = 0;
                RegWrite = 0; Latency = 4'h2;
                RT = instr[25:31]; RA = instr[18:24]; ID = ID_BINZ; Instr_type = ODDTYPE; 
            end
            11'b00100101010: begin  // bihz (no RT)
                RT_source = 1; RB_source = 0;
                RegWrite = 0; Latency = 4'h2;
                RT = instr[25:31]; RA = instr[18:24]; ID = ID_BIHZ; Instr_type = ODDTYPE; 
            end
            11'b00100101011: begin  // bihnz (no RT)
                RT_source = 1; RB_source = 0;
                RegWrite = 0; Latency = 4'h2;
                RT = instr[25:31]; RA = instr[18:24]; ID = ID_BIHNZ; Instr_type = ODDTYPE; 
            end
            11'b00110110001: begin  // gbh
                RB_source = 0;
                RT = instr[25:31]; RA = instr[18:24]; ID = ID_GBH; Latency = 4'h4; Instr_type = ODDTYPE; 
            end
            11'b00110110000: begin  // gb
                RB_source = 0;
                RT = instr[25:31]; RA = instr[18:24]; ID = ID_GB; Latency = 4'h4; Instr_type = ODDTYPE; 
            end

            // Special (Odd)
            11'b00000000001: begin 
                RA_source = 0; RB_source = 0;
                RegWrite = 0;
                ID = ID_LNOP; Instr_type = ODDTYPE;  
            end  // lnop

            /// Special (even)
            11'b01000000001: begin 
                RA_source = 0; RB_source = 0;
                RegWrite = 0; ID = ID_NOP; Instr_type = EVENTYPE; 
            end  // nop

            //STOP (both even and odd)
            11'b00000000000: begin 
                RA_source = 0; RB_source = 0;
                RegWrite = 0; ID = ID_STOP; Instr_type = STOP; 
            end  // stop 
        endcase
    end
endmodule