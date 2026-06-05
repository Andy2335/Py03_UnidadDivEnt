module display_4dig_mux #(
    parameter integer CLK_FREQ     = 27_000_000,
    parameter integer REFRESH_HZ   = 1000,
    parameter         COMMON_ANODE = 1        // 1 = ánodo común, 0 = cátodo común
)(
    input  logic       clk,
    input  logic       rst,
    input  logic [3:0] d0,    // unidades
    input  logic [3:0] d1,    // decenas
    input  logic [3:0] d2,    // centenas
    input  logic [3:0] d3,    // millares
    output logic [6:0] seg,   // segmentos: orden gfedcba (bit0=a, bit6=g)
    output logic [3:0] dig    // enable por dígito
);

// =============================================================
// Divisor de frecuencia -> Activa cada dígito a 1 kHz (250 Hz por dígito)
// =============================================================
    localparam integer TICKS_PER_DIGIT = CLK_FREQ / (REFRESH_HZ * 4);

    logic [$clog2(TICKS_PER_DIGIT)-1:0] refresh_cnt;
    logic [1:0] sel;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            refresh_cnt <= '0;
            sel         <= 2'd0;
        end else begin
            if (refresh_cnt == TICKS_PER_DIGIT - 1) begin
                refresh_cnt <= '0;
                sel         <= sel + 2'd1;
            end else begin
                refresh_cnt <= refresh_cnt + 1;
            end
        end
    end

// =============================================================
// Selección del dígito activo y su valor 
// =============================================================
    logic [3:0] digit_val;
    logic [3:0] dig_raw;

    always_comb begin
        case (sel)
            2'd0: begin digit_val = d0; dig_raw = 4'b0001; end
            2'd1: begin digit_val = d1; dig_raw = 4'b0010; end
            2'd2: begin digit_val = d2; dig_raw = 4'b0100; end
            2'd3: begin digit_val = d3; dig_raw = 4'b1000; end
            default: begin digit_val = 4'd0; dig_raw = 4'b0001; end
        endcase
    end

// =============================================================
// Decodificador BCD → 7 segmentos (combinacional)
// =============================================================
    logic [6:0] seg_raw;

    always_comb begin
        case (digit_val)
            4'd0: seg_raw = 7'b0111111; // abcdef  encendidos, g apagado
            4'd1: seg_raw = 7'b0000110; // bc
            4'd2: seg_raw = 7'b1011011; // abdeg
            4'd3: seg_raw = 7'b1001111; // abcdg
            4'd4: seg_raw = 7'b1100110; // bcfg
            4'd5: seg_raw = 7'b1101101; // acdfg
            4'd6: seg_raw = 7'b1111101; // acdefg
            4'd7: seg_raw = 7'b0000111; // abc
            4'd8: seg_raw = 7'b1111111; // todos
            4'd9: seg_raw = 7'b1101111; // abcdfg
            default: seg_raw = 7'b0000000; // apagado
        endcase
    end

// =============================================================
// Registros de salida sincrónicos
// =============================================================
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            seg <= (COMMON_ANODE) ? 7'b1111111 : 7'b0000000; // apagado
            dig <= (COMMON_ANODE) ? 4'b1111    : 4'b0000;    // todos deshabilitados
        end else begin
            seg <= COMMON_ANODE ? ~seg_raw : seg_raw;
            dig <= COMMON_ANODE ? ~dig_raw : dig_raw;
        end
    end

endmodule