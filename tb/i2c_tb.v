//==========================================================================
////   Description:
////
////
////==========================================================================
////  Revision History:
////  Date          By            Revision    Change Description
////--------------------------------------------------------------------------
////  2022/05/01   morrishe         1.1         Original
////*************************************************************************
module i2c_tb();

parameter   SYS_PERIOD = 20;  //20ns cycle time
parameter   RST_TIME   = 100;  // 5 cycle rst

reg     sys_clk  ;
reg     rst_n ;
reg     key1 ;
wire 	i2c_sda;
pullup  (i2c_sda);
wire	i2c_scl;
pullup  (i2c_scl);
wire [3:0] led;
//integer fd, i,j,k;

//--reset
initial begin
    sys_clk = 0;
    key1 = 0;
    rst_n = 1;
    #10 rst_n = 0;
    #RST_TIME rst_n = 1;
end

//clk
always sys_clk = #(SYS_PERIOD/2) ~sys_clk;

//key1 
always key1 = #((SYS_PERIOD/2)+307003) ~key1;


//status monitor

initial begin
    #RST_TIME;
    #20000_000;
    $finish();
end

/*
//waveform dump
`ifdef DUMP_FSDB
initial 
begin
    $fsdbDumpfile("i2cvcs.fsdb");
    //$fsdbDumpvars(0,i2c_tb);
    $fsdbDumpvars();
end
`endif 
*/
initial 
begin
    $fsdbDumpfile("i2c.fsdb");
    //$fsdbDumpvars(0,i2c_tb);
    $fsdbDumpvars();
end

i2c_eeprom_test i2c_eeprom_test_DUT (
	.sys_clk	(sys_clk	),       //system clock 50Mhz on board
	.rst_n		(rst_n		),         //reset ,low active
	.key1		(key1		),          //user key on board
	.i2c_sda	(i2c_sda	),       // i2c data
	.i2c_scl	(i2c_scl	),       // i2c clock
	.led		(led		)           //user leds on board
);

endmodule
