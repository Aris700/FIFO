module asynchronous_fifo(
    write_clk, write_rst, write_enable, 
    read_clk, read_rst, read_enable, 
    fifo_full, fifo_empty, write_data, read_data
);

parameter addr_width = 4;
parameter data_width = 8;
parameter fifo_depth = 2**addr_width;

input write_clk, read_clk, write_rst, read_rst;
input write_enable, read_enable;
input [data_width-1:0] write_data;
output [data_width-1:0] read_data;
output fifo_full, fifo_empty;

reg [data_width-1:0] fifo_mem[fifo_depth-1:0];

reg [addr_width:0] write_ptr, read_ptr;
wire [addr_width:0] write_ptr_gray, read_ptr_gray;
reg [addr_width:0] write_ptr_gray_sync1, write_ptr_gray_sync2;
reg [addr_width:0] read_ptr_gray_sync1, read_ptr_gray_sync2;
wire [addr_width:0] write_ptr_sync, read_ptr_sync;


// Write Logic
always @(posedge write_clk or negedge write_rst) begin
    if (~write_rst)
        write_ptr <= 5'b00000;
    else if (~fifo_full & write_enable) begin
        fifo_mem[write_ptr[addr_width-1:0]] <= write_data;
        write_ptr <= write_ptr + 1;
    end
end

// Read Logic
assign read_data = fifo_mem[read_ptr[addr_width-1:0]];
always @(posedge read_clk or negedge read_rst) begin
    if (~read_rst)
        read_ptr <= 5'b00000;
    else if (~fifo_empty & read_enable)
        read_ptr <= read_ptr + 1;
end

// Convert binary pointers to Gray code
assign write_ptr_gray = write_ptr ^ (write_ptr >> 1);
assign read_ptr_gray = read_ptr ^ (read_ptr >> 1);

// Synchronize read pointer to write clock domain
always @(posedge write_clk) begin
    if (~write_rst) begin
        read_ptr_gray_sync1 <= 5'b00000;
        read_ptr_gray_sync2 <= 5'b00000;
    end else begin
        read_ptr_gray_sync1 <= read_ptr_gray;
        read_ptr_gray_sync2 <= read_ptr_gray_sync1;
    end
end

// Synchronize write pointer to read clock domain
always @(posedge read_clk) begin
    if (~read_rst) begin
        write_ptr_gray_sync1 <= 5'b00000;
        write_ptr_gray_sync2 <= 5'b00000;
    end else begin
        write_ptr_gray_sync1 <= write_ptr_gray;
        write_ptr_gray_sync2 <= write_ptr_gray_sync1;
    end
end

// Convert synchronized Gray code pointers back to binary
assign write_ptr_sync = write_ptr_gray_sync2 ^ (write_ptr_gray_sync2 >> 1) ^ (write_ptr_gray_sync2 >> 2) ^ (write_ptr_gray_sync2 >> 3);
assign read_ptr_sync = read_ptr_gray_sync2 ^ (read_ptr_gray_sync2 >> 1) ^ (read_ptr_gray_sync2 >> 2) ^ (read_ptr_gray_sync2 >> 3);

// FIFO full and empty status flags
assign fifo_full = ((write_ptr[addr_width-1:0] == read_ptr_sync[addr_width-1:0]) && 
                    (write_ptr[addr_width] ^ read_ptr_sync[addr_width]));

assign fifo_empty = ((read_ptr[addr_width-1:0] == write_ptr_sync[addr_width-1:0]) && 
                     (~(read_ptr[addr_width] ^ write_ptr_sync[addr_width])));

endmodule
