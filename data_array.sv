/*
author: Hanchen Huang
*/

module data_array #(parameter width = 16)
(
    input clk,
    input load,
    input [2:0] index,
    input [width-1:0] in,
    output logic [width-1:0] out
);

logic [7:0] [width-1:0] data;

/* Altera device data_arrays are 0 at power on. Specify this
 * so that Modelsim works as expected.
 */
initial
begin
    data = 1'b0;
end

always_ff @(posedge clk)
begin
    if (load)
    begin
        data[index] = in;
    end
end

always_comb
begin
    out = data[index];
end

endmodule : data_array
