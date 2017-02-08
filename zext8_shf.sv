/*
author: Hanchen Huang
*/

import lc3b_types::*;

module zext8_shf
(
	input [7:0] in,
	output lc3b_word out
);

assign out = {8'b0,in} << 1;

endmodule : zext8_shf