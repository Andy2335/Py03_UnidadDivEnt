module binario_a_bcd_fsm(
    input  logic        clk,
    input  logic        rst,
    input  logic [10:0] bin,

    output logic [3:0]  d0,
    output logic [3:0]  d1,
    output logic [3:0]  d2,
    output logic [3:0]  d3
);

    // Lookup table completa para 0-63
    // Sin Double Dabble, sin divisiones, sin loops
    // d3 y d2 siempre 0 para este rango

    always_comb begin
        d3 = 4'd0;
        d2 = 4'd0;
        d1 = 4'd0;
        d0 = 4'd0;

        case (bin[5:0])
            6'd0:  begin d1=4'd0; d0=4'd0; end
            6'd1:  begin d1=4'd0; d0=4'd1; end
            6'd2:  begin d1=4'd0; d0=4'd2; end
            6'd3:  begin d1=4'd0; d0=4'd3; end
            6'd4:  begin d1=4'd0; d0=4'd4; end
            6'd5:  begin d1=4'd0; d0=4'd5; end
            6'd6:  begin d1=4'd0; d0=4'd6; end
            6'd7:  begin d1=4'd0; d0=4'd7; end
            6'd8:  begin d1=4'd0; d0=4'd8; end
            6'd9:  begin d1=4'd0; d0=4'd9; end
            6'd10: begin d1=4'd1; d0=4'd0; end
            6'd11: begin d1=4'd1; d0=4'd1; end
            6'd12: begin d1=4'd1; d0=4'd2; end
            6'd13: begin d1=4'd1; d0=4'd3; end
            6'd14: begin d1=4'd1; d0=4'd4; end
            6'd15: begin d1=4'd1; d0=4'd5; end
            6'd16: begin d1=4'd1; d0=4'd6; end
            6'd17: begin d1=4'd1; d0=4'd7; end
            6'd18: begin d1=4'd1; d0=4'd8; end
            6'd19: begin d1=4'd1; d0=4'd9; end
            6'd20: begin d1=4'd2; d0=4'd0; end
            6'd21: begin d1=4'd2; d0=4'd1; end
            6'd22: begin d1=4'd2; d0=4'd2; end
            6'd23: begin d1=4'd2; d0=4'd3; end
            6'd24: begin d1=4'd2; d0=4'd4; end
            6'd25: begin d1=4'd2; d0=4'd5; end
            6'd26: begin d1=4'd2; d0=4'd6; end
            6'd27: begin d1=4'd2; d0=4'd7; end
            6'd28: begin d1=4'd2; d0=4'd8; end
            6'd29: begin d1=4'd2; d0=4'd9; end
            6'd30: begin d1=4'd3; d0=4'd0; end
            6'd31: begin d1=4'd3; d0=4'd1; end
            6'd32: begin d1=4'd3; d0=4'd2; end
            6'd33: begin d1=4'd3; d0=4'd3; end
            6'd34: begin d1=4'd3; d0=4'd4; end
            6'd35: begin d1=4'd3; d0=4'd5; end
            6'd36: begin d1=4'd3; d0=4'd6; end
            6'd37: begin d1=4'd3; d0=4'd7; end
            6'd38: begin d1=4'd3; d0=4'd8; end
            6'd39: begin d1=4'd3; d0=4'd9; end
            6'd40: begin d1=4'd4; d0=4'd0; end
            6'd41: begin d1=4'd4; d0=4'd1; end
            6'd42: begin d1=4'd4; d0=4'd2; end
            6'd43: begin d1=4'd4; d0=4'd3; end
            6'd44: begin d1=4'd4; d0=4'd4; end
            6'd45: begin d1=4'd4; d0=4'd5; end
            6'd46: begin d1=4'd4; d0=4'd6; end
            6'd47: begin d1=4'd4; d0=4'd7; end
            6'd48: begin d1=4'd4; d0=4'd8; end
            6'd49: begin d1=4'd4; d0=4'd9; end
            6'd50: begin d1=4'd5; d0=4'd0; end
            6'd51: begin d1=4'd5; d0=4'd1; end
            6'd52: begin d1=4'd5; d0=4'd2; end
            6'd53: begin d1=4'd5; d0=4'd3; end
            6'd54: begin d1=4'd5; d0=4'd4; end
            6'd55: begin d1=4'd5; d0=4'd5; end
            6'd56: begin d1=4'd5; d0=4'd6; end
            6'd57: begin d1=4'd5; d0=4'd7; end
            6'd58: begin d1=4'd5; d0=4'd8; end
            6'd59: begin d1=4'd5; d0=4'd9; end
            6'd60: begin d1=4'd6; d0=4'd0; end
            6'd61: begin d1=4'd6; d0=4'd1; end
            6'd62: begin d1=4'd6; d0=4'd2; end
            6'd63: begin d1=4'd6; d0=4'd3; end
            default: begin d1=4'd0; d0=4'd0; end
        endcase
    end

endmodule