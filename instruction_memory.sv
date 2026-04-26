module instruction_memory(
    input [0:31] address, //word
    output logic [0:31] instr1,
    output logic [0:31] instr2
);
    
    logic [0:31] ram[0:511]; //2 kB instruction memory

    initial begin
        $readmemh("instructions.txt", ram);
    end

    assign instr1 = ram[address[0:29]];
    assign instr2 = ram[address[0:29] + 1];

endmodule