/*
author: Hanchen Huang
*/

import lc3b_types::*;

module sext #(parameter width = 6)
(
    input [width-1:0] in,
    output lc3b_word out
);

assign out = $signed(in);

endmodule : sext
