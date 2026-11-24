module register_file (
    input wire [24:0] instr_in,
    input wire regWrt,
    input wire [4:0] rd_index,
    input wire [2:0] load_index,
    input wire clk,
    input wire reset,
    input wire [127:0] ALU_result,
    output reg [127:0] rs1,
    output reg [127:0] rs2,
    output reg [127:0] rs3
);
    reg [127:0] registers [0:31] ;
    
    always @ (*) begin : Reads
        rs1 = 128'd0;
        rs2 = 128'd0;
        rs3 = 128'd0;

        if (instr_in[24:23] == 2'b10) begin
            rs1 = registers[instr_in[9:5]];
            rs2 = registers[instr_in[14:10]]; 
            rs3 = registers[instr_in[19:15]]; 
        end

        if (instr_in[24:23] == 2'b11) begin
            rs1 = registers[instr_in[9:5]];
            rs2 = registers[instr_in[14:10]];
        end

    end

    integer i;
    always @ (posedge clk) begin : Writes
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 128'd0;
            end
        end else if (regWrt == 1'b1) begin
            registers[rd_index] <= ALU_result;
        end
    end
endmodule