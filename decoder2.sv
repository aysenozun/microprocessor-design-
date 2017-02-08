/*
author: Hanchen Huang
*/

module decoder2
(
	input in,
	output logic [1:0] f
);

always_comb
begin
	if(in == 0)
		f = 2'b01;
	else 
		f = 2'b10;
end
endmodule : decoder2