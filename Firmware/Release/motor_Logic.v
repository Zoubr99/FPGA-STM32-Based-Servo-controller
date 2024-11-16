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
// CREATED		"Tue Apr 25 12:33:44 2023"

module motor_Logic(
	Reset,
	CLK_50,
	D,
	hallIn,
	data_in,
	motorCW,
	motorACW,
	busy
);


input wire	Reset;
input wire	CLK_50;
input wire	D;
input wire	hallIn;
input wire	[15:0] data_in;
output wire	motorCW;
output wire	motorACW;
output wire	busy;

wire	clk_22k;
wire	demux_Q;
wire	demux_Y;
wire	e;
wire	flag;
wire	[10:0] Q;
wire	Q11;
wire	Q12;
wire	rst;





ANDGate	b2v_inst(
	.A(demux_Y),
	.B(flag),
	.Y(motorCW));


ANDGate	b2v_inst1(
	.A(demux_Q),
	.B(flag),
	.Y(motorACW));


demux	b2v_inst2(
	.D(D),
	.SEL(Q11),
	.Y(demux_Y),
	.Q(demux_Q));


motor_pulse	b2v_inst3(
	.sense(Q12),
	.clk(clk_22k),
	.rst(rst),
	.e(e));


rotationCount	b2v_inst4(
	.hallIn(hallIn),
	.change(e),
	.RESET(rst),
	.cin(Q),
	.flag(flag));


Motor_register	b2v_inst5(
	.clk(CLK_50),
	.reset(rst),
	.data_in(data_in),
	.direction(Q11),
	.change(Q12),
	.data_out(Q));


clock_divider2	b2v_inst6(
	.clk(CLK_50),
	.rst(rst),
	.q(clk_22k));

assign	rst = Reset;
assign	busy = flag;

endmodule
