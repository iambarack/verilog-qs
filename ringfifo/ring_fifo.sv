module ring_fifo #(
    parameter int unsigned DATA_WIDTH = 8,
    parameter int unsigned DEPTH      = 16
) (
    input  logic                  clk,
    input  logic                  rst,
    input  logic [DATA_WIDTH-1:0] in_data,
    input  logic                  in_valid,
    output logic                  in_ready,
    output logic [DATA_WIDTH-1:0] out_data,
    output logic                  out_valid,
    input  logic                  out_ready
);
    localparam int unsigned PTR_WIDTH = (DEPTH < 2) ? 1 : $clog2(DEPTH);
    localparam int unsigned NUM_WIDTH = (DEPTH < 2) ? 1 : $clog2(DEPTH + 1);

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    logic [PTR_WIDTH-1:0]  rd_ptr;
    logic [PTR_WIDTH-1:0]  wr_ptr;
    logic [NUM_WIDTH-1:0]  used;
    logic                  empty;
    logic                  full;
    logic                  push;
    logic                  pop;

    assign empty     = (used == 0);
    assign full      = (used == DEPTH);
    assign out_valid = !empty;
    assign in_ready  = !full || out_ready;
    assign out_data  = mem[rd_ptr];

    assign push = in_valid && in_ready;
    assign pop  = out_valid && out_ready;

    always_ff @(posedge clk) begin
        if (rst) begin
            rd_ptr <= '0;
            wr_ptr <= '0;
            used   <= '0;
        end
        else begin
            if (push) begin
                mem[wr_ptr] <= in_data;
                wr_ptr <= (wr_ptr == DEPTH - 1) ? '0 : wr_ptr + 1'b1;
            end

            if (pop) begin
                rd_ptr <= (rd_ptr == DEPTH - 1) ? '0 : rd_ptr + 1'b1;
            end

            if (push && !pop)
                used <= used + 1'b1;
            else if (pop && !push)
                used <= used - 1'b1;
        end
    end
endmodule
