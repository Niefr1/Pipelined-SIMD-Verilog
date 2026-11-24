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
    wire [4:0] rs3 = instr[19:15];
    wire [4:0] rs2 = instr[14:10];
    wire [4:0] rs1 = instr[9:5];
    wire [4:0] rd = instr[4:0];

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

    always @ (*) begin
        // Default
        result = 128'd0;
        reg_write = 1'b1;

        // Check instruction type
        if (is_li) begin
            result = rs1;
            result[li_index*16 +: 16] = li_immediate;
        end else if (is_r4) begin
            
        end else if (is_r3) begin
            
        end

    end

endmodule