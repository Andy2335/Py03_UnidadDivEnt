module selector_numero_display(
    input  logic [1:0]  seleccion_display,

    input  logic [10:0] numero_a,
    input  logic [10:0] numero_b,
    input  logic [10:0] resultado,

    output logic [10:0] numero_display
);

    always_comb begin
        case (seleccion_display)
            2'd0: numero_display = numero_a;
            2'd1: numero_display = numero_b;
            2'd2: numero_display = resultado;
            default: numero_display = 11'd0;
        endcase
    end

endmodule