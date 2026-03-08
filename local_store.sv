module local_store(
    input clk,
    input [0:10] address,
    input [0:127] write_data,
    input MemWrite,
    output logic [0:127] read_data
);

logic [0:127] mem [0:2047];  //32kB local store, 256 entries of 128 bits each

assign read_data = mem[address];

always_ff @(posedge clk) begin
    if(MemWrite == 1) mem[address] <= write_data;
end

endmodule