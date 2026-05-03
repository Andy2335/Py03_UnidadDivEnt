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
    // Barrido de columnas (igual al código de prueba
    // que detectó el 9 correctamente)
    //--------------------------------------------------
    logic [1:0] col_idx;
    logic       phase;

    always_ff @(posedge clk) begin
        if (rst) begin
            col_idx <= 2'd0;
            phase   <= 1'b0;
        end else if (scan_tick) begin
            if (phase == 1'b0) begin
                phase <= 1'b1;
            end else begin
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
    // Sincronizar filas (igual al código de prueba)
    //--------------------------------------------------
    logic [3:0] rows_s1;
    logic [3:0] rows_s2;

    always_ff @(posedge clk) begin
        if (rst) begin
            rows_s1 <= 4'b1111;
            rows_s2 <= 4'b1111;
        end else begin
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
    // Decodificar tecla
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
    // Emitir key_valid con bloqueo anti-repetición
    //--------------------------------------------------
    logic locked;
    logic any_key_this_scan;

    always_ff @(posedge clk) begin
        if (rst) begin
            key_valid         <= 1'b0;
            key_code          <= 4'h0;
            locked            <= 1'b0;
            any_key_this_scan <= 1'b0;
        end else begin
            key_valid <= 1'b0;

            if (scan_tick && phase) begin

                if (row_found) begin
                    any_key_this_scan <= 1'b1;

                    if (!locked) begin
                        key_code  <= cur_key;
                        key_valid <= 1'b1;
                        locked    <= 1'b1;
                    end
                end

                if (col_idx == 2'd3) begin
                    if (!any_key_this_scan && !row_found)
                        locked <= 1'b0;
                    any_key_this_scan <= 1'b0;
                end
            end
        end
    end

endmodule