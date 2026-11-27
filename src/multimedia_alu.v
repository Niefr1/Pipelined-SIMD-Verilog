module multimedia_alu (
    input wire [24:0] instr,
    input wire [127:0] rs1,
    input wire [127:0] rs2,
    input wire [127:0] rs3,
    output reg [127:0] result,
    output reg reg_write
);

    wire is_li = ~instr[24];
    wire is_R3 = (instr[24] && ~instr[23]);
    wire is_R4 = (instr[24] && instr[23]);

    // Shared fields
    wire [4:0] rs3i = instr[19:15];
    wire [4:0] rs2i = instr[14:10];
    wire [4:0] rs1i = instr[9:5];
    wire [4:0] rdi = instr[4:0];

    // Load immediate instruction fields
    wire [2:0] li_index = instr[23:21];
    wire [15:0] li_immediate = instr[20:5];

    // R4 instruction fields
    wire [2:0] r4_op = instr[22:20]; 
    wire r4_long = r4_op[2];
    wire r4_sub = r4_op[1];
    wire r4_high = r4_op[0];

    // R3 instruction fields
    wire [7:0] r3_opcode = instr[22:15];

    // Scratch
    reg [15:0] ma16, mb16; // 16 bit multiplicands
    reg [31:0] ma32, mb32; // 32 bit multiplicands
    reg [31:0] prod32; // 32 bit product
    reg [63:0] prod64; // 64 bit product
    reg [32:0] acc33, prod33, mac33; // accumulator, product, multiply-accumulate sign extended
    reg [64:0] acc65, prod65, mac65; // mac is full precision sum before saturation
    reg [7:0] aa8, ab8; 
    reg [16:0] s17;
    reg found;
    integer count;

    // R3 opcode parameters
    localparam [3:0] NOP = 4'd0, ABSDB = 4'd1, AU = 4'd2, CNT1W = 4'd3,
        AHS = 4'd4, AND = 4'd5, BCW = 4'd6, MAXWS = 4'd7, MINWS = 4'd8,
        MLHU = 4'd9, MLHCU = 4'd10, OR = 4'd11, CNTLZ = 4'd12, ROTW = 4'd13,
        SFWU = 4'd14, SFHS = 4'd15;

    always @ (*) begin
        // Default
        result = 128'd0;
        reg_write = 1'b1;

        // Check instruction type
        if (is_li) begin
            result = rs1;
            result[li_index*16 +: 16] = li_immediate;
        end else if (is_R4) begin
            if (!r4_long) begin // 16 bit fields
                for (int i = 0; i < 4; i = i + 1) begin
                    ma16 = (r4_high) ? (rs3[i*32+16 +: 16]) : (rs3[i*32 +: 16]);
                    mb16 = (r4_high) ? (rs2[i*32+16 +: 16]) : (rs2[i*32 +: 16]);
                    prod32 = ma16 * mb16;
                    acc33 = {rs1[i*32+31], rs1[i*32 +: 32]}; // Sign extend rs1
                    prod33 = {prod32[31], prod32}; // Sign extend prod32
                    mac33 = r4_sub ? (acc33 - prod33) : (acc33 + prod33); // Add or subtract
                    case (mac33[32:31]) 
                        2'b01 : result[i*32 +: 32] = 32'h7FFFFFFF; // overflow; clamp on highest value
                        2'b10 : result[i*32 +: 32] = 32'h80000000; // underflow; clamp on lowest value
                        default : result[i*32 +: 32] = mac33[31:0];
                    endcase
                end
            end else begin // 32 bit fields
                for (int i = 0; i < 2; i = i + 1) begin
                    ma32 = (r4_high) ? (rs3[i*64+32 +: 32]) : (rs3[i*64 +: 32]);
                    mb32 = (r4_high) ? (rs2[i*64+32 +: 32]) : (rs2[i*64 +: 32]);
                    prod64 = ma32 * mb32;
                    acc65 = {rs1[i*64+63], rs1[i*64 +: 64]};
                    prod65 = {prod64[63], prod64};
                    mac65 = r4_sub ? (acc65 - prod65) : (acc65 + prod65);
                    case (mac65[64:63])
                        2'b01 : result[i*64 +: 64] = 64'h7FFF_FFFF_FFFF_FFFF;
                        2'b10 : result[i*64 +: 64] = 64'h8000_0000_0000_0000;
                        default : result[i*32 +: 32] = mac65[31:0];
                    endcase
                end
            end
        end else if (is_R3) begin
            case (r3_opcode[3:0])
                NOP : reg_write = 1'b0;
                ABSDB : begin
                    for (int i = 0; i < 16; i = i + 1)
                        result[i*8 +: 8] = (rs1[i*8 +: 8] > rs2[i*8 +: 8]) ? 
                            (rs1[i*8 +: 8] - rs2[i*8 +: 8]) : (rs2[i*8 +: 8] - rs1[i*8 +: 8]);
                end
                AU : begin
                    for (int i = 0; i < 4; i = i + 1) begin
                        result[i*32 +: 32] = rs1[i*32 +: 32] + rs2[i*32 +: 32]; 
                    end
                end
                CNT1W : begin
                    for (int i = 0; i < 4; i = i + 1) begin
                        for (int j = 0; j < 32; j = j + 1) begin
                            if (rs1[i*32 + j] == 1'b1) result[i*32 +: 32] = result[i*32 +: 32] + 32'd1;
                        end
                    end
                end
                AHS : begin
                    for (int i = 0; i < 8; i = i + 1) begin
                        s17 = {rs1[i*16 + 15], rs1[i*16 +: 16]} + {rs2[i*16 + 15], rs2[i*16 +: 16]};
                    
                        case ({s17[16], s17[15]})
                            2'b01 : result[i*16 +: 16] = 16'h7FFF; // Overflow
                            2'b10 : result[i*16 +: 16] = 16'h8000; // Underflow
                            default : result[i*16 +: 16] = s17[15:0];
                        endcase
                    end
                end
                AND : result = rs1 & rs2;
                BCW : begin 
                    for (int i = 0; i < 4; i = i + 1)
                        result[i*32 +: 32] = rs1[31:0];
                end
                MAXWS : begin
                    for (int i = 0; i < 4; i = i + 1) 
                        result[i*32 +: 32] = ($signed(rs1[i*32 +: 32]) > $signed(rs2[i*32 +: 32])) 
                            ? (rs1[i*32 +: 32]) : (rs2[i*32 +: 32]);
                end
                MINWS : begin
                    for (int i = 0; i < 4; i = i + 1) 
                        result[i*32 +: 32] = ($signed(rs1[i*32 +: 32]) < $signed(rs2[i*32 +: 32])) 
                            ? (rs1[i*32 +: 32]) : (rs2[i*32 +: 32]);
                end
                MLHU : begin
                    for (int i = 0; i < 4; i = i + 1)
                        result[i*32 +: 32] = rs1[i*32 +: 16] * rs2[i*32 +: 16];
                end
                MLHCU : begin
                    for (int i = 0; i < 4; i = i + 1)
                        result[i*32 +: 32] = rs1[i*32 +: 16] * instr[14:10];
                end 
                OR : result = rs1 | rs2;
                CNTLZ : begin
                    for (int i = 0; i < 4; i = i + 1) begin
                        count = 0;
                        found = 1'b0; 
                        for (int j = 31; j >= 0; j = j - 1) begin
                            if (!found) begin
                               if (rs1[i*32 + j]) found = 1'b1;
                               else count = count + 1; 
                            end
                        end
                        result[i*32 +: 32] = count;
                    end 
                end
                ROTW : begin
                    for (int i = 0; i < 4; i = i + 1) begin
                        // reused count
                        for (count = {27'd0, rs2[i*32 +: 5]}; count > 0; count = count - 1)
                            result[i*32 +: 32] = {rs1[i*32], rs1[i*32+1 +: 31]};
                    end
                end
                SFWU : begin
                    for (int i = 0; i < 4; i = i + 1) begin
                        result[i*32 +: 32] = rs2[i*32 +: 32] - rs1[i*32 +: 32];
                    end
                end
                SFHS : begin
                    for (int i = 0; i < 8; i = i + 1) begin
                        s17 = {rs2[i*16 + 15], rs2[i*16 +: 16]} - {rs1[i*16 + 15], rs1[i*16 +: 16]};

                        case ({s17[16], s17[15]})
                            2'b01 : result[i*16 +: 16] = 16'h7FFF; // Overflow
                            2'b10 : result[i*16 +: 16] = 16'h8000; // Underflow
                            default : result[i*16 +: 16] = s17[15:0];
                        endcase
                    end 
                end
            endcase
        end
    end
endmodule