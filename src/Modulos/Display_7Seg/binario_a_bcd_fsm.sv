module binario_a_bcd_fsm #(
    parameter integer N_BITS = 6   // ajustar según el número a convertir
)(
    input  logic                 clk,
    input  logic                 rst,
    input  logic                 valid_i,   // dato de entrada válido
    input  logic [N_BITS-1:0]   bin_i,     // número binario a convertir
    output logic [3:0]           d0,        // unidades
    output logic [3:0]           d1,        // decenas
    output logic [3:0]           d2,        // centenas
    output logic [3:0]           d3,        // millares (siempre 0 para N_BITS<=6)
    output logic                 done_o     // resultado estable
);

// =============================================================
// Definición de estados FSM
// =============================================================
    typedef enum logic [1:0] {
        S_IDLE  = 2'd0,
        S_SHIFT = 2'd1,
        S_DONE  = 2'd2
    } state_t;

    state_t state_r, state_nx;

// =============================================================
// Registros de datos de salida
// Se actualizan solo al llegar a S_DONE para evitar glitches
// =============================================================
    // Registro de desplazamiento: [BCD(16 bits) | binario(N_BITS bits)]
    logic [15:0]       bcd_r,  bcd_nx;
    logic [N_BITS-1:0] bin_r,  bin_nx;
    logic [3:0]        cnt_r,  cnt_nx;   // contador de iteraciones (0 a N_BITS)

// =============================================================
// Función: add-3 por nibble (Double Dabble)
// Si un nibble BCD >= 5, sumarle 3 antes del shift
// =============================================================
    function automatic logic [15:0] add3_if_gte5(input logic [15:0] bcd);
        logic [15:0] result;
        result = bcd;
        if (result[3:0]   >= 4'd5) result[3:0]   = result[3:0]   + 4'd3;
        if (result[7:4]   >= 4'd5) result[7:4]   = result[7:4]   + 4'd3;
        if (result[11:8]  >= 4'd5) result[11:8]  = result[11:8]  + 4'd3;
        if (result[15:12] >= 4'd5) result[15:12] = result[15:12] + 4'd3;
        return result;
    endfunction

// =============================================================
// Registro de estado y datos (bloque secuencial)
// =============================================================
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state_r <= S_IDLE;
            bcd_r   <= '0;
            bin_r   <= '0;
            cnt_r   <= '0;
        end else begin
            state_r <= state_nx;
            bcd_r   <= bcd_nx;
            bin_r   <= bin_nx;
            cnt_r   <= cnt_nx;
        end
    end

// =============================================================
// Lógica de próximo estado y ruta de datos (bloque combinacional)
// =============================================================
    always_comb begin
        // Valores por defecto: mantener estado
        state_nx = state_r;
        bcd_nx   = bcd_r;
        bin_nx   = bin_r;
        cnt_nx   = cnt_r;
        done_o   = 1'b0;

        case (state_r)

            S_IDLE: begin
                done_o = 1'b0;
                if (valid_i) begin
                    // Cargar el dato, limpiar BCD, empezar conteo
                    bin_nx   = bin_i;
                    bcd_nx   = '0;
                    cnt_nx   = '0;
                    state_nx = S_SHIFT;
                end
            end

            S_SHIFT: begin
                // Paso 1: aplicar add-3 a cada nibble que sea >= 5
                // Paso 2: desplazar todo a la izquierda 1 bit,
                //         entrando el MSB de bin_r por la derecha del BCD
                logic [15:0] bcd_adjusted;
                bcd_adjusted = add3_if_gte5(bcd_r);

                bcd_nx = {bcd_adjusted[14:0], bin_r[N_BITS-1]};
                bin_nx = {bin_r[N_BITS-2:0], 1'b0};
                cnt_nx = cnt_r + 4'd1;

                if (cnt_r == N_BITS - 1) begin
                    state_nx = S_DONE;
                end
            end

            S_DONE: begin
                done_o   = 1'b1;
                // Esperar a que valid_i baje antes de volver a IDLE
                // (handshake: el bloque anterior baja valid cuando ve done)
                if (!valid_i) begin
                    state_nx = S_IDLE;
                end
            end

            default: state_nx = S_IDLE;

        endcase
    end

// =============================================================
// Salidas registradas de los dígitos BCD
// Solo se actualizan al llegar a S_DONE para evitar glitches
// =============================================================
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            d0 <= '0;
            d1 <= '0;
            d2 <= '0;
            d3 <= '0;
        end else if (state_nx == S_DONE && state_r == S_SHIFT) begin
            // Capturar el resultado en el ciclo en que termina S_SHIFT
            d0 <= bcd_nx[3:0];
            d1 <= bcd_nx[7:4];
            d2 <= bcd_nx[11:8];
            d3 <= bcd_nx[15:12];
        end
    end

endmodule