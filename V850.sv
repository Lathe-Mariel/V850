logic[31:0] PC;    // [31:26] is automatically filled by sign extension. value of PC[0] is always 0.
//logic[31:0][0] r0
logic[31:0] r[31:1];    //general registers. r[1] is r1.