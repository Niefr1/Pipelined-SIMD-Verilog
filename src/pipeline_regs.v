module IF_ID (
    input wire clk,
    input wire instr_in[24:0],
    output wire instr_out[24:0],
);

endmodule

module ID_EX (
    input wire clk,
    input wire rs1[127:0],
    input wire rs2[127:0],
    input wire rs3[127:0],
    input wire instr_in[24:0],
    output wire instr_out[24:0]
);

endmodule

module EX_WB (
    input wire clk,
);

endmodule