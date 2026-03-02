module even_pipe(
    input clk,
    input rst_n,
    input [127:0] RA_even, 
    input [127:0] RB_even,
    input [127:0] RC_even,
    input [6:0] RT_even_addr,
    input [6:0] imm_6bit,
    input [9:0] imm_10bit,
    input [15:0] imm_16bit,
    input [17:0] imm_18bit,
    input [6:0] ID_even, //there are 100 instructions
    input [3:0] Latency_even, //max latency is 8
    input [127:0] RT_even,
    input RegWrite_even,
    output [6:0] RT_even_dest_addr,
    output [127:0] RT_even_dest_data
);

logic [15:0] s;
logic [31:0] t;
logic [32:0] t_33bit; // for carry generate

always_comb begin 
    case (ID_even)
        0: begin
            //hardware NOP
        end 
        1: begin //AH: Add halfword
            for (int j=0; j<8; j++) begin
                temp[2*j:2*j+1] = RA_even[2*j:2*j+1] + RB_even[2*j:2*j+1];
            end
        end
        2: begin //AHI: Add halfword immediate
            s = {{6{imm_10bit[9]}}, imm_10bit[9:0]}; 
            for (int j=0; j<8; j++) begin
                temp[2*j:2*j+1] = RA_even[2*j:2*j+1] + s;
            end
        end
        3: begin //A: Add word
            for (int j=0; j<4; j++) begin
                temp[4*j:4*j+3] = RA_even[4*j:4*j+3] + RB_even[4*j:4*j+3];
            end
        end
        4: begin //AI: add word immediate
            t = {{22{imm_10bit[9]}}, imm_10bit[9:0]};
            for (int j=0; j<4; j++) begin
                temp[4*j:4*j+3] = RA_even[4*j:4*j+3] + t;
            end
        end
        5: begin //ADDX: add extended
            for (int j = 0; j < 4; j++) begin
                temp[j*4 +: 4] = RA_even[j*4 +: 4] + RB_even[j*4 +: 4] + RT_even[32*j + 31];
            end
        end
        6: begin //CG: Carry generate
            for (int j=0; j<16; j+=4) begin
                t_33bit = {1'b0, RA[j +: 4]} + {1'b0, RB[j +: 4]};
                temp[j +: 4] = {32'b0,t[31]}; 
            end
        end
        7: begin //SFX: subtract from extended
            for (int j = 0; j< 4; j++) begin
                temp[j*4 +: 4] = RA_even[j*4 +: 4] + (~RB_even[j*4 +: 4]) + RT_even[32*j + 31];
            end
        end
        8: begin //BG: Borrow generate
            for (int j=0; j<16; j+=4) begin
                if (RB_even[j +: 4] > RA_even[j +: 4]) begin
                    temp[j +: 4] = 4'b1111; // borrow generated
                end else begin
                    temp[j +: 4] = 4'b0000; // no borrow
                end
            end
        end
        9: begin // SFH: Subtract from halfword
            for (int j=0; j<8; j++) begin
                temp[2*j:2*j+1] = RB_even[2*j:2*j+1] + (~RA_even[2*j:2*j+1]) + 1; // two's complement subtraction
            end
        end
        10: begin // SFHI: Subtract from halfword immediate
            t = {{6{imm_10bit[9]}}, imm_10bit[9:0]}; 
            for (int j=0; j<8; j++) begin
                temp[2*j:2*j+1] = t + (~RA_even[2*j:2*j+1]) + 1; // two's complement subtraction
            end
        end
        11: begin //SF: Subtract from word
            for (int j=0; j<4; j++) begin
                temp[4*j:4*j+3] = RB_even[4*j:4*j+3] + (~RA_even[4*j:4*j+3]) + 1; // two's complement subtraction
            end
        end
        12: begin // SFI: Subtract from word immediate
            t = {{22{imm_10bit[9]}}, imm_10bit[9:0]};
            for (int j=0; j<4; j++) begin
                temp[4*j:4*j+3] = t + (~RA_even[4*j:4*j+3]) + 1; // two's complement subtraction
            end
        end
        13: begin //AND: bitwise AND
            for (int j=0; j<4; j++) begin
                temp[4*j:4*j+3] = RA_even[4*j:4*j+3] & RB_even[4*j:4*j+3];
            end
        end
        14: begin //ANDHI: And halfword immediate
            t = {{6{imm_10bit[9]}}, imm_10bit[9:0]}; 
            for (int j=0; j<8; j++) begin
                temp[2*j:2*j+1] = RA_even[2*j:2*j+1] & t;
            end
        end
        15: begin //ANDI: And word immediate
            t = {{22{imm_10bit[9]}}, imm_10bit[9:0]};
            for (int j=0; j<4; j++) begin
                temp[4*j:4*j+3] = RA_even[4*j:4*j+3] & t;
            end
        end
        16: begin //OR: bitwise OR
            for (int j=0; j<4; j++) begin
                temp[4*j:4*j+3] = RA_even[4*j:4*j+3] | RB_even[4*j:4*j+3];
            end
        end
        17: begin //ORHI: Or halfword immediate
            t = {{6{imm_10bit[9]}}, imm_10bit[9:0]}; 
            for (int j=0; j<8; j++) begin
                temp[2*j:2*j+1] = RA_even[2*j:2*j+1] | t;
            end
        end
        18: begin //ORI: Or word immediate
            t = {{22{imm_10bit[9]}}, imm_10bit[9:0]};
            for (int j=0; j<4; j++) begin
                temp[4*j:4*j+3] = RA_even[4*j:4*j+3] | t;
            end
        end
        19: begin //XOR: bitwise XOR
            for (int j=0; j<4; j++) begin
                temp[4*j:4*j+3] = RA_even[4*j:4*j+3] ^ RB_even[4*j:4*j+3];
            end
        end
        20: begin //XORHI: Xor halfword immediate
            t = {{6{imm_10bit[9]}}, imm_10bit[9:0]}; 
            for (int j=0; j<8; j++) begin
                temp[2*j:2*j+1] = RA_even[2*j:2*j+1] ^ t;
            end
        end
        21: begin //XORI: Xor word immediate
            t = {{22{imm_10bit[9]}}, imm_10bit[9:0]};
            for (int j=0; j<4; j++) begin
                temp[4*j:4*j+3] = RA_even[4*j:4*j+3] ^ t;
            end
        end
        22: begin //NAND: bitwise NAND
            for (int j=0; j<4; j++) begin
                temp[4*j:4*j+3] = ~(RA_even[4*j:4*j+3] & RB_even[4*j:4*j+3]);
            end             
        end
        23: begin //NOR: bitwise NOR
            for (int j=0; j<4; j++) begin
                temp[4*j:4*j+3] = ~(RA_even[4*j:4*j+3] | RB_even[4*j:4*j+3]);
            end            
        end
        24: begin //CLZ: Count leading zeros
            for (int j=0; j<4; j++) begin
                t = 32'b0;
                u = 
            end
        end
        default: temp = 0;
    endcase
end

endmodule