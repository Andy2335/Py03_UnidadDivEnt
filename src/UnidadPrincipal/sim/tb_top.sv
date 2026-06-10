`timescale 1ns/1ps

module tb_top;

    logic clk;
    logic rst;

    logic [5:0] A;
    logic [3:0] B;
    logic valid;

    logic [5:0] cociente;
    logic [3:0] residuo;
    logic done;

    subsistema_division dut (
        .clk(clk),
        .rst(rst),
        .A(A),
        .B(B),
        .valid(valid),
        .cociente(cociente),
        .residuo(residuo),
        .done(done)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    task automatic test_case(
        input [5:0] a,
        input [3:0] b,
        input [5:0] q_exp,
        input [3:0] r_exp
    );
    begin
        @(posedge clk);

        A = a;
        B = b;
        valid = 1'b1;

        @(posedge clk);
        valid = 1'b0;

        wait(done);

        if ((cociente == q_exp) &&
            (residuo  == r_exp))
        begin
            $display("PASS: %0d / %0d = %0d R %0d",
                     a,b,cociente,residuo);
        end
        else begin
            $display("FAIL: %0d / %0d",a,b);
            $display("Esperado Q=%0d R=%0d",
                     q_exp,r_exp);
            $display("Obtenido Q=%0d R=%0d",
                     cociente,residuo);
        end

        repeat(2) @(posedge clk);
    end
    endtask

    initial begin

        rst = 1;
        valid = 0;
        A = 0;
        B = 0;

        repeat(5) @(posedge clk);

        rst = 0;

        test_case(25,5,5,0);
        test_case(63,15,4,3);
        test_case(17,4,4,1);
        test_case(9,2,4,1);
        test_case(8,8,1,0);

        //--------------------------------------------------
        // División por cero
        //--------------------------------------------------

        @(posedge clk);

        A = 10;
        B = 0;
        valid = 1;

        @(posedge clk);

        valid = 0;

        wait(done);

        if (cociente == 6'b111111)
            $display("PASS DIV0");
        else
            $display("FAIL DIV0");


        $finish;
    end

endmodule