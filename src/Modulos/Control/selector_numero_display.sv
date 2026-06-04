module selector_numero_display (
    input logic [1:0] seleccion_display,

    input logic [5:0] numero_a,
    input logic [3:0] numero_b,
    input logic [5:0] cociente,
    input logic [3:0] residuo,

    output logic [5:0] numero_display
);

always_comb begin
    case (seleccion_display)

        2'd0:
            numero_display = numero_a;

        2'd1:
            numero_display = {2'b00, numero_b};

        2'd2:
            numero_display = cociente;

        2'd3:
            numero_display = {2'b00, residuo};

        default:
            numero_display = 6'd0;

    endcase
end

endmodule