module instruction_memory(
    input [0:31] address, //word
    output logic [0:31] instr1,
    ouptut logic [0:31] instr2
);
    
    logic [0:31] ram[0:511]; //2 kB instruction memory

    initial begin
        $readmemh("instructions.txt", ram);
    end

    assign instr1 = ram[address];
    assign instr2 = ram[address+1];

endmodule