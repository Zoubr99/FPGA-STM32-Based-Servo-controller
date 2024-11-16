// Copyright (C) 2020  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and any partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details, at
// https://fpgasoftware.intel.com/eula.

// PROGRAM		"Quartus Prime"
// VERSION		"Version 20.1.1 Build 720 11/11/2020 SJ Lite Edition"
// CREATED		"Sat Mar 04 21:09:51 2023"

module LCD_Logic(
	Reset,
	Clock,
	Clock_fast,
	from_MCU,
	rs,
	rw,
	e,
	data
);


input wire	Reset;
input wire	Clock;
input wire	Clock_fast;
input wire	[8:0] from_MCU;
output wire	rs;
output wire	rw;
output wire	e;
output wire	[7:0] data;

wire	clk;
wire	clk_fast;
wire	[7:0] data_ALTERA_SYNTHESIZED;
wire	[8:0] q;
wire	rst;
wire	SYNTHESIZED_WIRE_0;
wire	[8:0] SYNTHESIZED_WIRE_1;
wire	[2:0] SYNTHESIZED_WIRE_2;





counter	b2v_inst(
	.clk(clk),
	.rst(rst),
	.q(SYNTHESIZED_WIRE_2));
	defparam	b2v_inst.N = 3;


bus_mux	b2v_inst2(
	.select(SYNTHESIZED_WIRE_0),
	.a(SYNTHESIZED_WIRE_1),
	.b(from_MCU),
	.q(q));


LCD_ROM	b2v_inst3(
	.address(SYNTHESIZED_WIRE_2),
	.RDY(SYNTHESIZED_WIRE_0),
	.q(SYNTHESIZED_WIRE_1));


display_controller	b2v_inst8(
	.write(q[8]),
	.rst(rst),
	.clk(clk),
	.ascii_data(q[7:0]),
	.rs(rs),
	.rw(rw),
	.data(data_ALTERA_SYNTHESIZED));


pulse_gen	b2v_inst9(
	.clk(clk_fast),
	.rst(rst),
	.sense(data_ALTERA_SYNTHESIZED),
	.e(e));

assign	clk = Clock;
assign	rst = Reset;
assign	clk_fast = Clock_fast;
assign	data = data_ALTERA_SYNTHESIZED;

endmodule
