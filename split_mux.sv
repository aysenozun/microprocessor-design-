/*
author: Hanchen Huang
*/
import lc3b_types::*;

module split_mux
(
	input [2:0] sel,
	input [127:0] in,
	output lc3b_word f
);

always_comb
begin
	case (sel)
		3'b000:
			f = in[15:0];
		3'b001:
			f = in[31:16];
		3'b010:
			f = in[47:32];
		3'b011:
			f = in[63:48];
		3'b100:
			f = in[79:64];
		3'b101:
			f = in[95:80];
		3'b110:
			f = in[111:96];
		3'b111:
			f = in[127:112];
		default : /* default */;
	endcase

end
endmodule : split_mux