module IF_ID (
    input wire clk,
    input wire [24:0] instr_in,
    output reg [24:0] instr_out,
);

    always @ (posedge clk) begin
        instr_out <= instr_in;
    end

endmodule

module ID_EX (
    input wire clk,
    input wire [127:0] rs1_in,
    input wire [127:0] rs2_in,
    input wire [127:0] rs3_in,
    input wire [127:0] rd_in,
    input wire [24:0] instr_in,
    input wire [4:0] rd_index_in,
    output reg [127:0] rs1_out,
    output reg [127:0] rs2_out,
    output reg [127:0] rs3_out,
    output reg [24:0] instr_out,
    output reg [127:0] rd_out,
    output reg [4:0] rd_index_out
);

    always @ (posedge clk) begin
        instr_out <= instr_in;
        rd_out <= rd_in;
        rs1_out <= rs1_in;
        rs2_out <= rs2_in;
        rs3_out <= rs3_in;
        rd_index_out <= rd_index_in;
    end

endmodule

module EX_WB (
    input wire clk,
    input wire regwrt_in,
    input wire [127:0] result_in,
    output reg regwrt_out,
    output reg [127:0] result_out
);

    always @ (posedge clk) begin
        result_out <= result_in;
        regwrt_out <= regwrt_in;
    end

endmodule