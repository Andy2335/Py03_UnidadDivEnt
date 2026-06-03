module selector_numero_display (
    input  logic [1:0] seleccion_display,
    input  logic       sel_resultado,    // 0=cociente, 1=residuo

    input  logic [5:0] numero_a,         // dividendo (max 63)
    input  logic [3:0] numero_b,         // divisor   (max 15)
    input  logic [5:0] cociente,         // resultado: cociente (max 63)
    input  logic [3:0] residuo,          // resultado: residuo  (max 15)

    output logic [5:0] numero_display,   // valor numerico hacia el BCD
    output logic       display_error     // 1 = mostrar "Err" en display
);

    always_comb begin
        numero_display = 6'd0;
        display_error  = 1'b0;

        case (seleccion_display)
            2'd0: numero_display = numero_a;
            2'd1: numero_display = {2'b00, numero_b};
            2'd2: numero_display = sel_resultado ? {2'b00, residuo} : cociente;
            2'd3: display_error  = 1'b1;   // senal al display para mostrar "Err"
            default: ;
        endcase
    end

endmodule