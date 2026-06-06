`timescale 1ns/1ps
 
module tb_binario_a_bcd_fsm;
 
    localparam integer N       = 6;
    localparam real    CLK_PER = 37.037; // 27 MHz
 
    logic           clk;
    logic           rst;
    logic           valid_i;
    logic [N-1:0]   bin_i;
    logic [3:0]     d0, d1, d2, d3;
    logic           done_o;
 
    binario_a_bcd_fsm #(.N_BITS(N)) dut (
        .clk     (clk),
        .rst     (rst),
        .valid_i (valid_i),
        .bin_i   (bin_i),
        .d0      (d0),
        .d1      (d1),
        .d2      (d2),
        .d3      (d3),
        .done_o  (done_o)
    );
 
    initial clk = 0;
    always #(CLK_PER / 2.0) clk = ~clk;
 
    initial begin
        $dumpfile("tb_binario_a_bcd_fsm.vcd");
        $dumpvars(0, tb_binario_a_bcd_fsm);
    end
 
    // Monitor: imprime cada vez que done_o sube
    always @(posedge done_o) begin
        $display("bin=%2d  →  display: %0d%0d%0d%0d",
                 bin_i, d3, d2, d1, d0);
    end
 
    // Tarea: enviar un valor y esperar done
    task automatic convierte(input logic [N-1:0] val);
        @(negedge clk);
        bin_i   = val;
        valid_i = 1'b1;
        @(posedge done_o);
        @(negedge clk);
        valid_i = 1'b0;
        repeat(2) @(posedge clk);
    endtask
 
    initial begin
        rst     = 1'b1;
        valid_i = 1'b0;
        bin_i   = '0;
        repeat(4) @(posedge clk);
        rst = 1'b0;
 
        $display("bin  →  display");
        $display("---------------");
 
        for (int i = 0; i < 64; i++)
            convierte(i[N-1:0]);
 
        $finish;
    end
 
endmodule