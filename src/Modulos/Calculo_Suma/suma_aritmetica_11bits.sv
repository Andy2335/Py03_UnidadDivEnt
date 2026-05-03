module suma_aritmetica_11bits (
    input  logic        clk,        // Reloj del sistema
    input  logic        rst,        // Reset
    input  logic [10:0] dato_a,     // Primer dato (11 bits)
    input  logic [10:0] dato_b,     // Segundo dato (11 bits)
    output logic [10:0] resultado,  // Resultado en 11 bits
    output logic        overflow    // Carry de desbordamiento
);

    logic [11:0] suma_extendida; // 12 bits para capturar el carry

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            resultado <= 11'b00000000000;
            overflow  <= 1'b0;
        end else begin
            suma_extendida = {1'b0, dato_a} + {1'b0, dato_b}; // suma completa
            resultado      <= suma_extendida[10:0];           // 11 bits bajos
            overflow       <= suma_extendida[11];             // carry-out
        end
    end

endmodule