/*
author: Hanchen Huang
*/

import lc3b_types::*; /* Import types defined in lc3b_types.sv */

module nzp
(
	input lc3b_nzp nzp,
	input lc3b_reg in,
	output logic f
);

always_comb
begin
	if (nzp[0] && in[0])
		f = 1;
	else if(nzp[1] && in[1])
		f = 1;
	else if(nzp[2] && in[2])
		f = 1;
	else
		f = 0;
end

endmodule : nzp