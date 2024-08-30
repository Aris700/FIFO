module synchronous_fifo(
    clk, reset, write_enable, read_enable, 
    write_data, read_data, fifo_full, fifo_empty
);

parameter addr_width = 4;
parameter data_width = 8;
parameter fifo_depth = 2**addr_width;

input clk, reset;
input write_enable, read_enable;
input [data_width-1:0] write_data;
output [data_width-1:0] read_data;
output fifo_full, fifo_empty;

reg [data_width-1:0] fifo_mem[fifo_depth-1:0];

reg [addr_width:0] write_ptr, read_ptr;

// Write and Read Logic
always @(posedge clk) begin
    if (reset) begin
        write_ptr <= 5'b00000;
        read_ptr <= 5'b00000;
    end else begin
        if (~fifo_full & write_enable) begin
            fifo_mem[write_ptr[addr_width-1:0]] <= write_data;
            write_ptr <= write_ptr + 1;
        end
        if (~fifo_empty & read_enable) begin
            read_ptr <= read_ptr + 1;
        end
    end
end

assign read_data = fifo_mem[read_ptr[addr_width-1:0]];

// FIFO Full and Empty Flags
assign fifo_full = ((write_ptr[addr_width-1:0] == read_ptr[addr_width-1:0]) && 
                    (write_ptr[addr_width] ^ read_ptr[addr_width]));
assign fifo_empty = ((read_ptr[addr_width-1:0] == write_ptr[addr_width-1:0]) && 
                     (~(read_ptr[address_bus_length] ^ write_ptr[address_bus_length])));

endmodule
