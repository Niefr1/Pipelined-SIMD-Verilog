module instr_buffer (
    input wire clk,
    input wire reset,
    output reg [24:0] out
);
    reg [5:0] program_counter = 6'd0; // 64 values
    reg [24:0] instr_mem [63:0]; // 64 instructions, each 25 bits long

    initial begin : init_mem
        integer instr_file;
        integer i;
        integer n;
        integer status;
        reg [8*256-1:0] line_buf;
        reg[31:0] instr_val;
        reg[24:0] instr25;

        $display ("Initializing instruction memory from program.hex");

        // Initialize memory to zeros first
        for (i = 0; i < 64; i = i + 1) instr_mem[i] = 25'b0;

        i = 0;
        instr_file = $fopen("program.hex", "r");

        while ($fgets(line_buf, instr_file) > 0 && i < 64) begin
            // Skip blank, whitespace, /r lines
            status = $sscanf(line_buf, "%h", instr_val);
            if (status == 1) begin
                instr_mem[i] = instr_val[24:0];
                $display("Loaded instruction at address %0d -> 0x%h", i, instr_mem[i]);
                i = i + 1;
            end
        end

        $display("Finished loading %0d instructions", i);
    end

    always @(posedge clk) begin : behavior
        if (reset) begin
            out <= 25'b0;
            program_counter <= 6'b0;
        end else begin
            out <= instr_mem[program_counter];
            program_counter <= program_counter + 1'b1;
        end
    end
endmodule