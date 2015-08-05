// dummy module for ram megafunction
module BET (
        clk,
        aclr,
        arrd,
        wren,
        data,
        q
);
input clk, aclr, wren, data;
input [11:0] data;

output q;

endmodule;
