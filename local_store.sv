module local_store(
    input clk,
    input [0:31] address,
    input [0:127] write_data,
    input MemWrite,
    output logic [0:127] read_data
);

logic [0:127] mem [0:2047];  //32kB local store, 256 entries of 128 bits each

initial begin
    //Matrix A
    mem [0] = 128'h00000000_3F800000_40000000_40400000; // 0.0, 1.0, 2.0, 3.0
    mem [1] = 128'h40800000_40A00000_40C00000_40E00000; // 4.0, 5.0, 6.0, 7.0
    mem [2] = 128'h41000000_41100000_41200000_41300000; // 8.0, 9.0, 10.0, 11.0
    mem [3] = 128'h41400000_41500000_41600000_41700000; // 12.0, 13.0, 14.0, 15.0
    //Matrix B
    mem [4] = 128'h41800000_41880000_41900000_41980000; // 16.0, 17.0, 18.0, 19.0
    mem [5] = 128'h41A00000_41A80000_41B00000_41B80000; // 20.0, 21.0, 22.0, 23.0
    mem [6] = 128'h41C00000_41C80000_41D00000_41D80000; // 24.0, 25.0, 26.0, 27.0
    mem [7] = 128'h41E00000_41E80000_41F00000_41F80000; // 28.0, 29.0, 30.0, 31.0
end
assign read_data = mem[address];

always @(posedge clk) begin
    if(MemWrite == 1) mem[address] <= write_data;
end

endmodule