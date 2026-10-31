module ring_fifo_tb;
    localparam int DATA_WIDTH = 8;
    localparam int DEPTH      = 3;

    logic clk = 1'b0;
    logic rst;
    logic [DATA_WIDTH-1:0] in_data;
    logic                  in_valid;
    logic                  in_ready;
    logic [DATA_WIDTH-1:0] out_data;
    logic                  out_valid;
    logic                  out_ready;

    int expected[$];

    ring_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (.*);

    always #5 clk = ~clk;

    task automatic drive_push(input int value);
        begin
            @(negedge clk);
            in_data  = value[DATA_WIDTH-1:0];
            in_valid = 1'b1;
            do @(posedge clk); while (!in_ready);
            expected.push_back(value);
            @(negedge clk);
            in_valid = 1'b0;
        end
    endtask

    task automatic drive_pop;
        int value;
        begin
            @(negedge clk);
            out_ready = 1'b1;
            do @(posedge clk); while (!out_valid);
            value = out_data;
            if (expected.size() == 0 || value != expected.pop_front()) begin
                $fatal(1, "unexpected output %0d", value);
            end
            @(negedge clk);
            out_ready = 1'b0;
        end
    endtask

    initial begin
        rst       = 1'b1;
        in_data   = '0;
        in_valid  = 1'b0;
        out_ready = 1'b0;

        repeat (2) @(posedge clk);
        rst = 1'b0;

        drive_push(8'h11);
        drive_push(8'h22);
        drive_push(8'h33);
        if (in_ready !== 1'b0) begin
            $fatal(1, "FIFO should be full");
        end

        drive_pop();
        drive_pop();
        drive_push(8'h44);
        drive_pop();
        drive_pop();

        @(negedge clk);
        in_data   = 8'haa;
        in_valid  = 1'b1;
        out_ready = 1'b1;
        @(posedge clk);
        if (!in_ready || out_valid) begin
            $fatal(1, "empty FIFO handshake behavior is incorrect");
        end
        expected.push_back(8'haa);
        @(negedge clk);
        in_valid  = 1'b0;
        out_ready = 1'b0;
        drive_pop();

        drive_push(8'h55);
        drive_push(8'h66);
        @(negedge clk);
        in_data   = 8'h77;
        in_valid  = 1'b1;
        out_ready = 1'b1;
        @(posedge clk);
        if (!in_ready || !out_valid || out_data != 8'h55) begin
            $fatal(1, "simultaneous push/pop behavior is incorrect");
        end
        expected.push_back(8'h77);
        expected.pop_front();
        @(negedge clk);
        in_valid  = 1'b0;
        out_ready = 1'b0;

        drive_pop();
        drive_pop();

        $display("ring_fifo test passed");
        $finish;
    end
endmodule
