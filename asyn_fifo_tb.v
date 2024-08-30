`timescale 1ns/10ps
`include "asyn_FIFO.v"
module asynchronous_fifo_tb ();

parameter addr_width = 4;
parameter data_width = 8;
parameter fifo_depth = 2**addr_width;

parameter write_clk_period = 40;
parameter read_clk_period = 100;

reg write_clk, read_clk, write_rst, read_rst;
reg write_enable, read_enable;
reg [data_width-1:0] write_data;
wire [data_width-1:0] read_data;
wire fifo_full, fifo_empty;

asynchronous_fifo #(
    .address_bus_length(addr_width),
    .data_bus_length(data_width)
) DUT (
    .trans_clk(write_clk),
    .trans_rst(write_rst),
    .write_enable(write_enable),
    .recv_clk(read_clk),
    .recv_rst(read_rst),
    .read_enable(read_enable),
    .fifo_full(fifo_full),
    .fifo_empty(fifo_empty),
    .trans_data(write_data),
    .recv_data(read_data)
);

// Write Clock Generation
initial begin
    write_clk = 1'b0;
    write_rst = 1'b0;
    write_enable = 1'b0;
    repeat (2) begin
        #(write_clk_period/2) write_clk = ~write_clk;
    end
    write_rst = 1'b1;
    forever begin
        #(write_clk_period/2) write_clk = ~write_clk;
    end
end

// Read Clock Generation
initial begin
    read_clk = 1'b0;
    read_rst = 1'b0;
    read_enable = 1'b0;
    repeat (2) begin
        #(read_clk_period/2) read_clk = ~read_clk;
    end
    read_rst = 1'b1;
    forever begin
        #(read_clk_period/2) read_clk = ~read_clk;
    end
end

// Write Data Generation
initial begin
    @(posedge write_rst);  // Wait for reset to be asserted
    @(negedge write_clk); write_enable = 1'b1;
    @(negedge write_clk); write_data = 8'd17;
    @(negedge write_clk); write_data = 8'd18;
    @(negedge write_clk); write_data = 8'd19;
    @(negedge write_clk); write_data = 8'd20;
    @(negedge write_clk); write_data = 8'd21;
    @(negedge write_clk); write_data = 8'd22;
    @(negedge write_clk); write_data = 8'd23;
    @(negedge write_clk); write_data = 8'd24;
    @(negedge write_clk); write_data = 8'd25;
    @(negedge write_clk); write_data = 8'd26;
    @(negedge write_clk); write_data = 8'd27;
    @(negedge write_clk); write_data = 8'd28;
    @(negedge write_clk); write_data = 8'd29;
    @(negedge write_clk); write_data = 8'd30;
    @(negedge write_clk); write_data = 8'd31;
    @(negedge write_clk); write_data = 8'd32;
    @(negedge write_clk); write_enable = 1'b0;
end

// Read Data Generation
initial begin
    @(posedge read_rst);  // Wait for reset to be asserted
    @(negedge read_clk); read_enable = 1'b1;
    repeat (20 * (read_clk_period / 2)) @(posedge read_clk);  // Read for a while
    @(negedge read_clk); read_enable = 1'b0;
end

endmodule
