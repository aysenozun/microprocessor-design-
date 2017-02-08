/*
author: Hanchen Huang
*/

import lc3b_types::*;

module zext4
(
	input [3:0] in,
	output lc3b_word out
);

assign out = {12'b0,in};

endmodule : zext4