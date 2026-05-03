module reset_inicio #(
    parameter int CICLOS = 5_000_000
)(
    input  logic clk,
    input  logic rst_n,
    output logic rst
);

    logic [22:0] contador;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            contador <= 23'd0;
            rst      <= 1'b1;
        end else begin
            if (contador < CICLOS) begin
                contador <= contador + 23'd1;
                rst      <= 1'b1;
            end else begin
                rst      <= 1'b0;
            end
        end
    end

endmodule