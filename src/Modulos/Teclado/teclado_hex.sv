module teclado_hex(
    input  logic       clk,
    input  logic       rst,
    input  logic       scan_tick,
    input  logic [3:0] rows_async,

    output logic [3:0] cols,
    output logic       key_valid,
    output logic [3:0] key_code
);

    //--------------------------------------------------
    // Teclado matricial 4x4 activo en bajo
    // cols: una columna en 0 a la vez
    // rows_async: fila en 0 cuando hay tecla presionada
    //--------------------------------------------------

    logic [1:0] col_idx;
    logic       phase;       // 0 = dejar columna estable, 1 = muestrear filas

    wire sample_now;
    assign sample_now = scan_tick && phase;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            col_idx <= 2'd0;
            phase   <= 1'b0;
        end
        else if (scan_tick) begin
            if (!phase) begin
                // Mantiene la columna activa un tick completo antes de leer filas
                phase <= 1'b1;
            end
            else begin
                // Después de muestrear, pasa a la siguiente columna
                phase <= 1'b0;
                if (col_idx == 2'd3)
                    col_idx <= 2'd0;
                else
                    col_idx <= col_idx + 2'd1;
            end
        end
    end

    always_comb begin
        case (col_idx)
            2'd0: cols = 4'b1110;
            2'd1: cols = 4'b1101;
            2'd2: cols = 4'b1011;
            2'd3: cols = 4'b0111;
            default: cols = 4'b1111;
        endcase
    end

    //--------------------------------------------------
    // Sincronización de filas
    //--------------------------------------------------

    logic [3:0] rows_s1;
    logic [3:0] rows_s2;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            rows_s1 <= 4'b1111;
            rows_s2 <= 4'b1111;
        end
        else begin
            rows_s1 <= rows_async;
            rows_s2 <= rows_s1;
        end
    end

    //--------------------------------------------------
    // Detectar fila activa
    //--------------------------------------------------

    logic       row_found;
    logic [1:0] row_idx;

    always_comb begin
        row_found = 1'b0;
        row_idx   = 2'd0;

        if      (rows_s2[0] == 1'b0) begin row_found = 1'b1; row_idx = 2'd0; end
        else if (rows_s2[1] == 1'b0) begin row_found = 1'b1; row_idx = 2'd1; end
        else if (rows_s2[2] == 1'b0) begin row_found = 1'b1; row_idx = 2'd2; end
        else if (rows_s2[3] == 1'b0) begin row_found = 1'b1; row_idx = 2'd3; end
    end

    //--------------------------------------------------
    // Mapa de teclado
    //--------------------------------------------------

    logic [3:0] cur_key;

    always_comb begin
        case ({row_idx, col_idx})
            {2'd0, 2'd0}: cur_key = 4'h1;
            {2'd0, 2'd1}: cur_key = 4'h2;
            {2'd0, 2'd2}: cur_key = 4'h3;
            {2'd0, 2'd3}: cur_key = 4'hA;

            {2'd1, 2'd0}: cur_key = 4'h4;
            {2'd1, 2'd1}: cur_key = 4'h5;
            {2'd1, 2'd2}: cur_key = 4'h6;
            {2'd1, 2'd3}: cur_key = 4'hB;

            {2'd2, 2'd0}: cur_key = 4'h7;
            {2'd2, 2'd1}: cur_key = 4'h8;
            {2'd2, 2'd2}: cur_key = 4'h9;
            {2'd2, 2'd3}: cur_key = 4'hC;

            {2'd3, 2'd0}: cur_key = 4'hE;
            {2'd3, 2'd1}: cur_key = 4'h0;
            {2'd3, 2'd2}: cur_key = 4'hF;
            {2'd3, 2'd3}: cur_key = 4'hD;

            default: cur_key = 4'h0;
        endcase
    end

    //--------------------------------------------------
    // Escaneo completo + antirrebote
    // No genera key_valid apenas ve una columna.
    // Primero termina las 4 columnas y luego confirma que
    // la misma tecla aparezca en dos escaneos completos seguidos.
    //--------------------------------------------------

    logic       scan_has_key;
    logic [3:0] scan_key;

    logic       prev_scan_pressed;
    logic [3:0] prev_scan_key;

    logic       locked;

    logic       candidate_pressed;
    logic [3:0] candidate_key;

    always_comb begin
        candidate_pressed = scan_has_key || row_found;
        candidate_key     = scan_has_key ? scan_key : cur_key;
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            key_valid         <= 1'b0;
            key_code          <= 4'h0;

            scan_has_key      <= 1'b0;
            scan_key          <= 4'h0;

            prev_scan_pressed <= 1'b0;
            prev_scan_key     <= 4'h0;

            locked            <= 1'b0;
        end
        else begin
            key_valid <= 1'b0;

            if (sample_now) begin
                // Guarda la primera tecla encontrada durante este escaneo completo
                if (row_found && !scan_has_key) begin
                    scan_has_key <= 1'b1;
                    scan_key     <= cur_key;
                end

                // Al terminar columna 3, se terminó un escaneo completo
                if (col_idx == 2'd3) begin
                    // Antirrebote: acepta solo si dos escaneos seguidos coinciden
                    if ((candidate_pressed == prev_scan_pressed) &&
                        (!candidate_pressed || (candidate_key == prev_scan_key))) begin

                        if (candidate_pressed) begin
                            if (!locked) begin
                                key_code  <= candidate_key;
                                key_valid <= 1'b1;
                                locked    <= 1'b1;
                            end
                        end
                        else begin
                            locked <= 1'b0;
                        end
                    end

                    prev_scan_pressed <= candidate_pressed;
                    prev_scan_key     <= candidate_key;

                    scan_has_key <= 1'b0;
                    scan_key     <= 4'h0;
                end
            end
        end
    end

endmodule
