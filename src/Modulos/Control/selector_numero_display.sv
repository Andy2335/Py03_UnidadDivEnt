module selector_numero_display (
    input  logic [1:0] seleccion_display,
    input  logic       sel_resultado,

    input  logic [5:0] numero_a,
    input  logic [3:0] numero_b,
    input  logic [5:0] cociente,
    input  logic [3:0] residuo,

    output logic [5:0] numero_display,
    output logic       display_error
);

    always_comb begin
        numero_display = 6'd0;
        display_error  = 1'b0;

        case (seleccion_display)

            2'd0: begin
                numero_display = numero_a;
            end

            2'd1: begin
                numero_display = {2'b00, numero_b};
            end

            2'd2: begin
                if (sel_resultado)
                    numero_display = {2'b00, residuo};
                else
                    numero_display = cociente;
            end

            2'd3: begin
                numero_display = 6'd0;
                display_error  = 1'b1;
            end

            default: begin
                numero_display = 6'd0;
                display_error  = 1'b0;
            end

        endcase
    end

endmodule