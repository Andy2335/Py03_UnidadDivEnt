// binario_a_bcd_fsm.sv
// LUT combinacional para 0-127 → BCD de 3 dígitos
// d3 siempre 0 (máximo valor es 127 → centenas = 1, decenas ≤ 2)
// Para el rango extra se usa d2 para centenas.

module binario_a_bcd_fsm(
    input  logic        clk,
    input  logic        rst,
    input  logic [10:0] bin,   // Puerto original de 11 bits; sólo usamos [6:0]

    output logic [3:0]  d0,    // unidades
    output logic [3:0]  d1,    // decenas
    output logic [3:0]  d2,    // centenas (0 ó 1)
    output logic [3:0]  d3     // siempre 0
);

    always_comb begin
        d3 = 4'd0;
        d2 = 4'd0;
        d1 = 4'd0;
        d0 = 4'd0;

        case (bin[6:0])
            // 0-9
            7'd0:   begin d2=4'd0; d1=4'd0; d0=4'd0; end
            7'd1:   begin d2=4'd0; d1=4'd0; d0=4'd1; end
            7'd2:   begin d2=4'd0; d1=4'd0; d0=4'd2; end
            7'd3:   begin d2=4'd0; d1=4'd0; d0=4'd3; end
            7'd4:   begin d2=4'd0; d1=4'd0; d0=4'd4; end
            7'd5:   begin d2=4'd0; d1=4'd0; d0=4'd5; end
            7'd6:   begin d2=4'd0; d1=4'd0; d0=4'd6; end
            7'd7:   begin d2=4'd0; d1=4'd0; d0=4'd7; end
            7'd8:   begin d2=4'd0; d1=4'd0; d0=4'd8; end
            7'd9:   begin d2=4'd0; d1=4'd0; d0=4'd9; end
            // 10-19
            7'd10:  begin d2=4'd0; d1=4'd1; d0=4'd0; end
            7'd11:  begin d2=4'd0; d1=4'd1; d0=4'd1; end
            7'd12:  begin d2=4'd0; d1=4'd1; d0=4'd2; end
            7'd13:  begin d2=4'd0; d1=4'd1; d0=4'd3; end
            7'd14:  begin d2=4'd0; d1=4'd1; d0=4'd4; end
            7'd15:  begin d2=4'd0; d1=4'd1; d0=4'd5; end
            7'd16:  begin d2=4'd0; d1=4'd1; d0=4'd6; end
            7'd17:  begin d2=4'd0; d1=4'd1; d0=4'd7; end
            7'd18:  begin d2=4'd0; d1=4'd1; d0=4'd8; end
            7'd19:  begin d2=4'd0; d1=4'd1; d0=4'd9; end
            // 20-29
            7'd20:  begin d2=4'd0; d1=4'd2; d0=4'd0; end
            7'd21:  begin d2=4'd0; d1=4'd2; d0=4'd1; end
            7'd22:  begin d2=4'd0; d1=4'd2; d0=4'd2; end
            7'd23:  begin d2=4'd0; d1=4'd2; d0=4'd3; end
            7'd24:  begin d2=4'd0; d1=4'd2; d0=4'd4; end
            7'd25:  begin d2=4'd0; d1=4'd2; d0=4'd5; end
            7'd26:  begin d2=4'd0; d1=4'd2; d0=4'd6; end
            7'd27:  begin d2=4'd0; d1=4'd2; d0=4'd7; end
            7'd28:  begin d2=4'd0; d1=4'd2; d0=4'd8; end
            7'd29:  begin d2=4'd0; d1=4'd2; d0=4'd9; end
            // 30-39
            7'd30:  begin d2=4'd0; d1=4'd3; d0=4'd0; end
            7'd31:  begin d2=4'd0; d1=4'd3; d0=4'd1; end
            7'd32:  begin d2=4'd0; d1=4'd3; d0=4'd2; end
            7'd33:  begin d2=4'd0; d1=4'd3; d0=4'd3; end
            7'd34:  begin d2=4'd0; d1=4'd3; d0=4'd4; end
            7'd35:  begin d2=4'd0; d1=4'd3; d0=4'd5; end
            7'd36:  begin d2=4'd0; d1=4'd3; d0=4'd6; end
            7'd37:  begin d2=4'd0; d1=4'd3; d0=4'd7; end
            7'd38:  begin d2=4'd0; d1=4'd3; d0=4'd8; end
            7'd39:  begin d2=4'd0; d1=4'd3; d0=4'd9; end
            // 40-49
            7'd40:  begin d2=4'd0; d1=4'd4; d0=4'd0; end
            7'd41:  begin d2=4'd0; d1=4'd4; d0=4'd1; end
            7'd42:  begin d2=4'd0; d1=4'd4; d0=4'd2; end
            7'd43:  begin d2=4'd0; d1=4'd4; d0=4'd3; end
            7'd44:  begin d2=4'd0; d1=4'd4; d0=4'd4; end
            7'd45:  begin d2=4'd0; d1=4'd4; d0=4'd5; end
            7'd46:  begin d2=4'd0; d1=4'd4; d0=4'd6; end
            7'd47:  begin d2=4'd0; d1=4'd4; d0=4'd7; end
            7'd48:  begin d2=4'd0; d1=4'd4; d0=4'd8; end
            7'd49:  begin d2=4'd0; d1=4'd4; d0=4'd9; end
            // 50-59
            7'd50:  begin d2=4'd0; d1=4'd5; d0=4'd0; end
            7'd51:  begin d2=4'd0; d1=4'd5; d0=4'd1; end
            7'd52:  begin d2=4'd0; d1=4'd5; d0=4'd2; end
            7'd53:  begin d2=4'd0; d1=4'd5; d0=4'd3; end
            7'd54:  begin d2=4'd0; d1=4'd5; d0=4'd4; end
            7'd55:  begin d2=4'd0; d1=4'd5; d0=4'd5; end
            7'd56:  begin d2=4'd0; d1=4'd5; d0=4'd6; end
            7'd57:  begin d2=4'd0; d1=4'd5; d0=4'd7; end
            7'd58:  begin d2=4'd0; d1=4'd5; d0=4'd8; end
            7'd59:  begin d2=4'd0; d1=4'd5; d0=4'd9; end
            // 60-69
            7'd60:  begin d2=4'd0; d1=4'd6; d0=4'd0; end
            7'd61:  begin d2=4'd0; d1=4'd6; d0=4'd1; end
            7'd62:  begin d2=4'd0; d1=4'd6; d0=4'd2; end
            7'd63:  begin d2=4'd0; d1=4'd6; d0=4'd3; end
            7'd64:  begin d2=4'd0; d1=4'd6; d0=4'd4; end
            7'd65:  begin d2=4'd0; d1=4'd6; d0=4'd5; end
            7'd66:  begin d2=4'd0; d1=4'd6; d0=4'd6; end
            7'd67:  begin d2=4'd0; d1=4'd6; d0=4'd7; end
            7'd68:  begin d2=4'd0; d1=4'd6; d0=4'd8; end
            7'd69:  begin d2=4'd0; d1=4'd6; d0=4'd9; end
            // 70-79
            7'd70:  begin d2=4'd0; d1=4'd7; d0=4'd0; end
            7'd71:  begin d2=4'd0; d1=4'd7; d0=4'd1; end
            7'd72:  begin d2=4'd0; d1=4'd7; d0=4'd2; end
            7'd73:  begin d2=4'd0; d1=4'd7; d0=4'd3; end
            7'd74:  begin d2=4'd0; d1=4'd7; d0=4'd4; end
            7'd75:  begin d2=4'd0; d1=4'd7; d0=4'd5; end
            7'd76:  begin d2=4'd0; d1=4'd7; d0=4'd6; end
            7'd77:  begin d2=4'd0; d1=4'd7; d0=4'd7; end
            7'd78:  begin d2=4'd0; d1=4'd7; d0=4'd8; end
            7'd79:  begin d2=4'd0; d1=4'd7; d0=4'd9; end
            // 80-89
            7'd80:  begin d2=4'd0; d1=4'd8; d0=4'd0; end
            7'd81:  begin d2=4'd0; d1=4'd8; d0=4'd1; end
            7'd82:  begin d2=4'd0; d1=4'd8; d0=4'd2; end
            7'd83:  begin d2=4'd0; d1=4'd8; d0=4'd3; end
            7'd84:  begin d2=4'd0; d1=4'd8; d0=4'd4; end
            7'd85:  begin d2=4'd0; d1=4'd8; d0=4'd5; end
            7'd86:  begin d2=4'd0; d1=4'd8; d0=4'd6; end
            7'd87:  begin d2=4'd0; d1=4'd8; d0=4'd7; end
            7'd88:  begin d2=4'd0; d1=4'd8; d0=4'd8; end
            7'd89:  begin d2=4'd0; d1=4'd8; d0=4'd9; end
            // 90-99
            7'd90:  begin d2=4'd0; d1=4'd9; d0=4'd0; end
            7'd91:  begin d2=4'd0; d1=4'd9; d0=4'd1; end
            7'd92:  begin d2=4'd0; d1=4'd9; d0=4'd2; end
            7'd93:  begin d2=4'd0; d1=4'd9; d0=4'd3; end
            7'd94:  begin d2=4'd0; d1=4'd9; d0=4'd4; end
            7'd95:  begin d2=4'd0; d1=4'd9; d0=4'd5; end
            7'd96:  begin d2=4'd0; d1=4'd9; d0=4'd6; end
            7'd97:  begin d2=4'd0; d1=4'd9; d0=4'd7; end
            7'd98:  begin d2=4'd0; d1=4'd9; d0=4'd8; end
            7'd99:  begin d2=4'd0; d1=4'd9; d0=4'd9; end
            // 100-109
            7'd100: begin d2=4'd1; d1=4'd0; d0=4'd0; end
            7'd101: begin d2=4'd1; d1=4'd0; d0=4'd1; end
            7'd102: begin d2=4'd1; d1=4'd0; d0=4'd2; end
            7'd103: begin d2=4'd1; d1=4'd0; d0=4'd3; end
            7'd104: begin d2=4'd1; d1=4'd0; d0=4'd4; end
            7'd105: begin d2=4'd1; d1=4'd0; d0=4'd5; end
            7'd106: begin d2=4'd1; d1=4'd0; d0=4'd6; end
            7'd107: begin d2=4'd1; d1=4'd0; d0=4'd7; end
            7'd108: begin d2=4'd1; d1=4'd0; d0=4'd8; end
            7'd109: begin d2=4'd1; d1=4'd0; d0=4'd9; end
            // 110-119
            7'd110: begin d2=4'd1; d1=4'd1; d0=4'd0; end
            7'd111: begin d2=4'd1; d1=4'd1; d0=4'd1; end
            7'd112: begin d2=4'd1; d1=4'd1; d0=4'd2; end
            7'd113: begin d2=4'd1; d1=4'd1; d0=4'd3; end
            7'd114: begin d2=4'd1; d1=4'd1; d0=4'd4; end
            7'd115: begin d2=4'd1; d1=4'd1; d0=4'd5; end
            7'd116: begin d2=4'd1; d1=4'd1; d0=4'd6; end
            7'd117: begin d2=4'd1; d1=4'd1; d0=4'd7; end
            7'd118: begin d2=4'd1; d1=4'd1; d0=4'd8; end
            7'd119: begin d2=4'd1; d1=4'd1; d0=4'd9; end
            // 120-127
            7'd120: begin d2=4'd1; d1=4'd2; d0=4'd0; end
            7'd121: begin d2=4'd1; d1=4'd2; d0=4'd1; end
            7'd122: begin d2=4'd1; d1=4'd2; d0=4'd2; end
            7'd123: begin d2=4'd1; d1=4'd2; d0=4'd3; end
            7'd124: begin d2=4'd1; d1=4'd2; d0=4'd4; end
            7'd125: begin d2=4'd1; d1=4'd2; d0=4'd5; end
            7'd126: begin d2=4'd1; d1=4'd2; d0=4'd6; end
            7'd127: begin d2=4'd1; d1=4'd2; d0=4'd7; end
            default: begin d2=4'd0; d1=4'd0; d0=4'd0; end
        endcase
    end

endmodule