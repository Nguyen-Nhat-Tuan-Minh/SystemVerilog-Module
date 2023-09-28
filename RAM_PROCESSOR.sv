//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

module RAM_PROCESSOR(Clock, Resetn, Run, Done, LEDs, R0_o, R1_o, R2_o, R3_o, R4_o, R5_o, R6_o, R7_o, G_o, A_o, IR_o, GF_o, AF_o);
	
	input Clock, Resetn, Run;
	output Done;
	output [8:0] LEDs;
	output [8:0] R0_o, R1_o, R2_o, R3_o, R4_o, R5_o, R6_o, R7_o, G_o, A_o, IR_o, GF_o, AF_o;
	
	//assign IR_o = IR_Q;

	logic [8:0] DIN, ADDR, DOUT;
	logic W;
	logic A8, A7, wr_en_Memory, enable_LED;


	assign A8 = ADDR[8];
	assign A7 = ADDR[7];
	assign wr_en_Memory = !(A8 | A7) & W;
	assign enable_LED = !(A8 | !A7) & W;

	CPU_RAM Processor(.DIN(DIN),.Clock(Clock),.Resetn(Resetn),.Run(Run),.ADDR(ADDR),.DOUT(DOUT),.Done(Done),.W(W)
	,.R0_t(R0_o),.R1_t(R1_o),.R2_t(R2_o),.R3_t(R3_o),.R4_t(R4_o),.R5_t(R5_o),.R6_t(R6_o),.R7_t(R7_o),.G_t(G_o),.A_t(A_o),.IR_t(IR_o),.AF_t(AF_o),.GF_t(GF_o));
	ram memory(.addr(ADDR[6:0]),.data(DOUT),.wren(wr_en_Memory),.clock(Clock),.q(DIN));
	NineBitRegister LED(.clk(Clock),.enable(enable_LED),.R(DOUT),.Q(LEDs));

endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

/*module RAM(addr, data, wr_en, clk, q);

	input logic [6:0] addr;
	input logic [8:0] data;
	input logic wr_en;
	input logic clk;
	output logic [8:0] q;

	logic [8:0] memory [0:127]; // 128 words of 9-bit memory

	initial begin
	$readmemb("Ram.mif",memory);
	end

	always_ff @ (posedge clk) begin
		if (wr_en) begin
			memory[addr] <= data;
	    end
			q = memory[addr];
	end

endmodule*/

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

module CPU_RAM(DIN, Clock, Run, Resetn, ADDR, DOUT, Done, W, R0_t, R1_t, R2_t, R3_t, R4_t, R5_t, R6_t, R7_t, G_t, A_t, GF_t, AF_t, IR_t);

	input [8:0] DIN;
	input Clock, Run, Resetn;
	output [8:0] ADDR, DOUT;
	output Done, W;
	output [8:0] R0_t, R1_t, R2_t, R3_t, R4_t, R5_t, R6_t, R7_t, G_t, A_t, IR_t, GF_t, AF_t;
				
	logic [8:0] Bus;
	logic [7:0] Rout, Rin;
	logic Gout, DINout, IRin, Ain, Gin, AddSub;
	logic [8:0] IR_Q;
	logic [8:0] G_Q, A_Q;
	logic [8:0] R0_Q, R1_Q, R2_Q, R3_Q, R4_Q, R5_Q, R6_Q, R7_Q;
	logic [8:0] AddSub_Result;
	logic gz;
	logic incr_pc, ADDRin, DOUTin, W_D;
	logic GFout, AFin, GFin, AddSubF;
	logic [8:0] GF_Q, AF_Q;
	logic [8:0] AddSubF_Result;

	assign gz = G_Q == 0;
	
	assign R0_t = R0_Q; 
	assign R1_t = R1_Q;
	assign R2_t = R2_Q;
	assign R3_t = R3_Q;
	assign R4_t = R4_Q;
	assign R5_t = R5_Q;
	assign R6_t = R6_Q;
	assign R7_t = R7_Q;
	assign G_t = G_Q; 
	assign A_t = A_Q; 
	assign GF_t = GF_Q; 
	assign AF_t = AF_Q;
	assign IR_t = IR_Q;

	Control_unit FSM(.Clock(Clock),.Run(Run),.Resetn(Resetn),.gz(gz),.IR(IR_Q),.IRin(IRin),.Rout(Rout),.Gout(Gout),.DINout(DINout),.Rin(Rin),.Ain(Ain),.Gin(Gin),.AddSub(AddSub),.incr_pc(incr_pc),.ADDRin(ADDRin),.DOUTin(DOUTin),.W_D(W_D),.Done(Done));

	NineBitRegister IR(.clk(Clock),.enable(IRin),.R(DIN),.Q(IR_Q));
	NineBitRegister GB(.clk(Clock),.enable(Gin),.R(AddSub_Result),.Q(G_Q));
	NineBitRegister AB(.clk(Clock),.enable(Ain),.R(Bus),.Q(A_Q));
	NineBitRegister R0(.clk(Clock),.enable(Rin[0]),.R(Bus),.Q(R0_Q));
	NineBitRegister R1(.clk(Clock),.enable(Rin[1]),.R(Bus),.Q(R1_Q));
	NineBitRegister R2(.clk(Clock),.enable(Rin[2]),.R(Bus),.Q(R2_Q));
	NineBitRegister R3(.clk(Clock),.enable(Rin[3]),.R(Bus),.Q(R3_Q));
	NineBitRegister R4(.clk(Clock),.enable(Rin[4]),.R(Bus),.Q(R4_Q));
	NineBitRegister R5(.clk(Clock),.enable(Rin[5]),.R(Bus),.Q(R5_Q));
	NineBitRegister R6(.clk(Clock),.enable(Rin[6]),.R(Bus),.Q(R6_Q));
	NineBitRegister GF(.clk(Clock),.enable(GFin),.R(AddSubF_Result),.Q(GF_Q));
	NineBitRegister AF(.clk(Clock),.enable(AFin),.R(Bus),.Q(AF_Q));
	PC R7(.clk(Clock),.enable(Rin[7]),.incr_pc(incr_pc),.Resetn(Resetn),.R(Bus),.Q(R7_Q));
	NineBitRegister ff_ADDR(.clk(Clock),.enable(ADDRin),.R(Bus),.Q(ADDR));
	NineBitRegister ff_DOUT(.clk(Clock),.enable(DOUTin),.R(Bus),.Q(DOUT));
	OneBitRegister ff_W(.clk(Clock),.R(W_D),.Q(W));

	AddSub ALU(.A(A_Q),.B(Bus),.AddSub(AddSub),.Result(AddSub_Result));
	FLOATING_POINT ALUF(.A(AF_Q),.B(Bus),.S(AddSubF),.Result(AddSubF_Result));
	Multiplexer_11x1 select(.DIN(DIN),.R0(R0_Q),.R1(R1_Q),.R2(R2_Q),.R3(R3_Q),.R4(R4_Q),.R5(R5_Q),.R6(R6_Q),.R7(R7_Q),.G(G_Q),.GF(GF_Q),.Rout(Rout),.DINout(DINout),.Gout(Gout),.GFout(GFout),.Bus(Bus));

endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

module Control_unit(Resetn, Clock, Run, IR, gz, Rout, DINout, Gout, IRin, Ain, Gin, AddSub, incr_pc, ADDRin, DOUTin, GFout, AFin, GFin, AddSubF, W_D, Rin, Done);

	input Resetn, Clock, Run;
	input [8:0] IR;
	input gz;
	output [7:0] Rout;
	output DINout, Gout;
	output IRin, Ain, Gin, AddSub;
	output incr_pc, ADDRin, DOUTin, W_D;
	output [7:0] Rin;
	output GFout;
	output AFin, GFin, AddSubF;
	output Done;

	logic [2:0] Tstep_Q, Tstep_D;
	logic [2:0] III, XXX, YYY;
	logic [7:0] RXin_temp, RXout_temp, RYout_temp;

	assign III = IR[8:6];
	assign XXX = IR[5:3];
	assign YYY = IR[2:0]; 

	Decoder_3x8 rxin(.W(XXX),.Y(RXin_temp));
	Decoder_3x8 rxout(.W(XXX),.Y(RXout_temp));
	Decoder_3x8 ryout(.W(YYY),.Y(RYout_temp));

parameter T0 = 3'b000, T1 = 3'b001, T2 = 3'b010, T3 = 3'b011, T4 = 3'b100, T5 = 3'b101;

    // Control FSM state table
    always @(Tstep_Q, Run, Done)
        case (Tstep_Q)
            T0: // instruction fetch
                if (~Run) Tstep_D = T0;
                else Tstep_D = T1;
            T1: // wait cycle for synchronous memory
                Tstep_D = T2;
            T2: // this time step stores the instruction word in IR
                Tstep_D = T3;
            T3: // some instructions end after this time step
                if (Done) Tstep_D = T0;
                else Tstep_D = T4;
            T4: // always go to T5 after this
                Tstep_D = T5;
            T5: // instructions end after this time step
                Tstep_D = T0;
            default: Tstep_D = 3'bxxx;
        endcase
		 
parameter mv = 3'b000, mvi = 3'b001, add = 3'b010, sub = 3'b011, ld = 3'b100, st = 3'b101, mvnz = 3'b110, addf = 3'b111;		 
// Control FSM outputs
always @(*) begin
Done = 1'b0; Ain = 1'b0; Gin = 1'b0; AddSub = 1'b0; IRin = 1'b0; Rin = 8'b0;
DINout = 1'b0; Gout = 1'b0; Rout = 8'b0;
incr_pc = 1'b0; ADDRin = 1'b0; DOUTin = 1'b0; W_D = 1'b0;
GFout = 1'b0; AFin = 1'b0; GFin = 1'b0; AddSubF = 1'b0;
		case (Tstep_Q)
            T0: begin // fetch the instruction
                Rout = 8'b10000000; // put pc onto the internal bus
                ADDRin = 1'b1;
                incr_pc = Run; // to increment pc
            end
            T1: // wait cycle for synchronous memory
                ;				
				T2: // store instruction on DIN in IR 
                IRin = 1'b1;
            T3: // define signals in T3
                case (III)
                    mv: begin
                        Rout = RYout_temp;
								Rin = RXin_temp;
								Done = 1'b1;
                    end
                    mvi: begin
								Rout = 8'b10000000;
								ADDRin = 1'b1;
								incr_pc = 1'b1;
                    end
                    add, sub: begin
                        Rout = RXout_temp;
								Ain = 1'b1;
                    end
						  ld, st: begin
								Rout = RYout_temp;
								ADDRin = 1'b1;
						  end
                    mvnz: begin
								if (!gz) begin
									Rout = RYout_temp;
									Rin = RXin_temp;
									Done = 1'b1;
									end
								else
									Done = 1'b1;
						  end
						  addf: begin
                        Rout = RXout_temp;
								AFin = 1'b1;
                    end
						  default: begin
										Done = 1'b0; Ain = 1'b0; Gin = 1'b0;
										AddSub = 1'b0; IRin = 1'b0; Rin = 8'b0;
										DINout = 1'b0; Gout = 1'b0; Rout = 8'b0;
										incr_pc = 1'b0; ADDRin = 1'b0; DOUTin = 1'b0; W_D = 1'b0;
										GFout = 1'b0; AFin = 1'b0; GFin = 1'b0; AddSubF = 1'b0;
										end
                endcase
            T4: // define signals T4
                case (III)
                    add: begin
                        Rout = RYout_temp;
								Gin = 1'b1;
                    end
                    sub: begin
                        Rout = RYout_temp;
								Gin = 1'b1;
								AddSub = 1'b1;
                    end
						  mvi: // wait cycle for synchronous memory
								;
						  ld: // wait cycle for synchronous memory
                        ;
                    st: begin
                        Rout = RXout_temp;
								DOUTin = 1'b1;
								W_D = 1'b1;
                    end
						  addf: begin
                        Rout = RYout_temp;
								GFin = 1'b1;
                    end
                    default: begin
										Done = 1'b0; Ain = 1'b0; Gin = 1'b0;
										AddSub = 1'b0; IRin = 1'b0; Rin = 8'b0;
										DINout = 1'b0; Gout = 1'b0; Rout = 8'b0;
										incr_pc = 1'b0; ADDRin = 1'b0; DOUTin = 1'b0; W_D = 1'b0;
										GFout = 1'b0; AFin = 1'b0; GFin = 1'b0; AddSubF = 1'b0;
										end 
                endcase
            T5: // define T5
                case (III)
                    add, sub: begin
                        Gout = 1'b1;
								Rin = RXin_temp;
								Done = 1'b1;
                    end
						  mvi: begin
								DINout = 1'b1;
								Rin = RXin_temp;
								Done = 1'b1;
						  end
						  ld: begin
                        DINout = 1'b1;
								Rin = RXin_temp;
								Done = 1'b1;
                    end
                    st: // wait cycle for synhronous memory
                        Done = 1'b1;
						  addf: begin
                        GFout = 1'b1;
								Rin = RXin_temp;
								Done = 1'b1;
						  end
                    default: begin
										Done = 1'b0; Ain = 1'b0; Gin = 1'b0;
										AddSub = 1'b0; IRin = 1'b0; Rin = 8'b0;
										DINout = 1'b0; Gout = 1'b0; Rout = 8'b0;
										incr_pc = 1'b0; ADDRin = 1'b0; DOUTin = 1'b0; W_D = 1'b0;
										GFout = 1'b0; AFin = 1'b0; GFin = 1'b0; AddSubF = 1'b0;
										end
                endcase
        endcase
    end

// Control FSM flip-flops
always @(posedge Clock, negedge Resetn)
		if (!Resetn)
			Tstep_Q <= T0;
		else
         Tstep_Q <= Tstep_D;
endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

module NineBitRegister(clk, enable, R, Q);
	
	input clk, enable;
	input [8:0] R;
	output [8:0] Q;

	always@(posedge clk) begin
		if (enable) 
			Q <= R;
		else
			;
	end
endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

module PC(clk, enable, incr_pc, Resetn, R, Q);

	input clk, enable;
	input incr_pc, Resetn;
	input [8:0] R;
	output [8:0] Q;
		
	always@(posedge clk) begin
			if (!Resetn)
				Q <= 9'b0;
			else if (enable)
				Q <= R;
			else if (incr_pc)
				Q <= Q + 1'b1;
	end
	
endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

module OneBitRegister(clk, R, Q);

	input clk;
	input R;
	output Q;
	
	always@(posedge clk) begin 
			Q <= R;
	end
	
endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

module AddSub(A, B, AddSub, Result);

	input [8:0] A, B;
	input AddSub;
	output [8:0] Result;

	always_comb begin
		if(!AddSub) Result <= A + B;
		else Result <= A - B;
	end
	
endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

module Multiplexer_11x1(DIN, R0, R1, R2, R3, R4, R5, R6, R7, G, GF, Rout, DINout, Gout, GFout, Bus);

	input [8:0] DIN;
	input [8:0] R0, R1, R2, R3, R4, R5, R6, R7;
	input [8:0] G, GF;
	input [7:0] Rout;
	input DINout, Gout, GFout;
	output [8:0] Bus;

	logic [10:0] Sel;

	assign Sel = {Rout, DINout, Gout, GFout};

	always_comb begin
		case (Sel)
			11'b10000000000: Bus = R7;
			11'b01000000000: Bus = R6;
			11'b00100000000: Bus = R5;
			11'b00010000000: Bus = R4;
			11'b00001000000: Bus = R3;
			11'b00000100000: Bus = R2;
			11'b00000010000: Bus = R1;
			11'b00000001000: Bus = R0;
			11'b00000000100: Bus = DIN;
			11'b00000000010: Bus = G;
			11'b00000000001: Bus = GF;
		default: Bus = '0;
		endcase
	end
endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

module Decoder_3x8(W, Y);
	input [2:0] W;
	output [7:0] Y;
	
	always_comb begin
		case (W)
			3'b000: Y = 8'b00000001;
			3'b001: Y = 8'b00000010;
			3'b010: Y = 8'b00000100;
			3'b011: Y = 8'b00001000;
			3'b100: Y = 8'b00010000;
			3'b101: Y = 8'b00100000;
			3'b110: Y = 8'b01000000;
			3'b111: Y = 8'b10000000;
		endcase
	end
endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

module FLOATING_POINT(S, A, B, Result, OV, Z);

	input S;
	input [8:0] A, B;
	output [8:0] Result;
	output OV;
	output Z;

	logic Sign_A, sign_B;
	logic [3:0] Exp_A, Exp_B;
	logic [3:0] Manti_A, Manti_B;
	logic [3:0] Bigger_exp;
	logic [4:0] Exp_diff;
	logic [4:0] Manti_diff;
	logic [3:0] Bigger_mantissas, Smaller_mantissas;
	logic [5:0] Shifted_mantissas;
	logic [5:0] SixBitBigger_mantissas;
	logic [5:0] Neg_Shifted_mantissas;
	logic [5:0] Unshifted_Result_Mantissas;
	logic [3:0] Result_mantissas;
	logic [3:0] Result_exp;
	logic Result_sign;

	assign Sign_A = A[8];
	assign Exp_A = A[7:4];
	assign Manti_A = A[3:0];
	assign Sign_B = B[8];
	assign Exp_B = B[7:4];
	assign Manti_B = B[3:0];

	Exponent exponent(.Exp_A(Exp_A),.Exp_B(Exp_B),.Bigger_exp(Bigger_exp),.Exp_diff(Exp_diff));

	Mantissas manti(.Manti_A(Manti_A),.Manti_B(Manti_B),.Exp_diff(Exp_diff),.Bigger_mantissas(Bigger_mantissas),.Smaller_mantissas(Smaller_mantissas),.Manti_diff(Manti_diff));

	Shift shift(.Smaller_mantissas(Smaller_mantissas),.Exp_diff(Exp_diff),.Shifted_mantissas(Shifted_mantissas));

	assign SixBitBigger_mantissas = {2'b01, Bigger_mantissas};
	assign Neg_Shifted_mantissas = -Shifted_mantissas;

	AddSub_Mantissas Manti_Arith(.Sign_A(Sign_A),.Sign_B(Sign_B),.S(S),.Shifted_mantissas(Shifted_mantissas),.SixBitBigger_mantissas(SixBitBigger_mantissas),.Unshifted_Result_Mantissas(Unshifted_Result_Mantissas));

	Exp_Manti expmantissas(.Unshifted_Result_Mantissas(Unshifted_Result_Mantissas),.Bigger_exp(Bigger_exp),.Result_mantissas(Result_mantissas),.Result_exp(Result_exp),.OV(OV));

	Sign sign(.Exp_diff(Exp_diff),.Manti_diff(Manti_diff),.Sign_A(Sign_A),.Sign_B(Sign_B),.S(S),.Result_sign(Result_sign));

	Result result(.A(A),.B(B),.S(S),.Result_sign(Result_sign),.Result_exp(Result_exp),.Result_mantissas(Result_mantissas),.Result(Result),.Z(Z));

endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

module Exponent(Exp_A, Exp_B, Bigger_exp, Exp_diff);

	input [3:0] Exp_A, Exp_B;
	output [3:0] Bigger_exp;
	output [4:0] Exp_diff;

	assign Exp_diff = Exp_A - Exp_B;

	always_comb begin
		if (Exp_diff[4] == 0) 
			Bigger_exp <= Exp_A;
		else 
			Bigger_exp <= Exp_B;
	end

endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

module Mantissas(Manti_A, Manti_B, Exp_diff, Bigger_mantissas, Smaller_mantissas, Manti_diff);
 
	input [3:0] Manti_A, Manti_B;
	input [4:0] Exp_diff;
	output [3:0] Bigger_mantissas, Smaller_mantissas;
	output [4:0] Manti_diff;

	assign Manti_diff = Manti_A - Manti_B;

	always_comb begin
		if (Exp_diff == 0) begin			//Exp_A = Exp_B
			if (Manti_diff[4] == 0) begin
				Bigger_mantissas <= Manti_A;
				Smaller_mantissas <= Manti_B;
			end	
			else begin
				Bigger_mantissas <= Manti_B;
				Smaller_mantissas <= Manti_A;
			end
		end
		
		else begin							//Exp_A <> Exp_B
			if (Exp_diff[4] == 0) begin
				Bigger_mantissas <= Manti_A;
				Smaller_mantissas <= Manti_B;
			end
			else begin
				Bigger_mantissas <= Manti_B;
				Smaller_mantissas <= Manti_A;
			end
		end
	end

endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

module Shift(Smaller_mantissas, Exp_diff, Shifted_mantissas);

	input  logic [3:0] Smaller_mantissas;
	input logic [4:0] Exp_diff; 
	output logic [5:0] Shifted_mantissas;

	logic [4:0] Shift_amount, Hidden_mantissas;

	always_comb begin	    
		if (Exp_diff[4] == 0) 
			Shift_amount = Exp_diff;
		else	 
			Shift_amount = -Exp_diff;	 
	end

	assign Hidden_mantissas = {1'b1, Smaller_mantissas};
	assign Shifted_mantissas = Hidden_mantissas >> Shift_amount;	 

endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

module AddSub_Mantissas(Sign_A, Sign_B, S, Shifted_mantissas, SixBitBigger_mantissas, Unshifted_Result_Mantissas);

	input Sign_A, Sign_B, S;
	input [5:0] Shifted_mantissas, SixBitBigger_mantissas;
	output [5:0] Unshifted_Result_Mantissas;

	logic Same_sign;

	assign Same_sign = Sign_A ~^ Sign_B;

	always_comb begin
		if (S == 1) begin
			if (Same_sign == 1)
				Unshifted_Result_Mantissas <= SixBitBigger_mantissas - Shifted_mantissas;
			else
				Unshifted_Result_Mantissas <= SixBitBigger_mantissas + Shifted_mantissas;
			end
		else begin
			if (Same_sign == 1)
				Unshifted_Result_Mantissas <= SixBitBigger_mantissas + Shifted_mantissas;
			else
				Unshifted_Result_Mantissas <= SixBitBigger_mantissas - Shifted_mantissas;
			end
	end

endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

module Exp_Manti(Unshifted_Result_Mantissas, Bigger_exp, Result_exp, Result_mantissas, OV);

	input [5:0] Unshifted_Result_Mantissas;
	input [3:0] Bigger_exp;
	output [3:0] Result_exp, Result_mantissas;
	output OV;

	always_comb begin
		if (Unshifted_Result_Mantissas[5] == 1) begin
			if (Bigger_exp <= 14) begin
				Result_exp <= Bigger_exp + 1;
				Result_mantissas <= Unshifted_Result_Mantissas[4:1];
				OV <= 1'b0;
				end
			else begin
				OV <= 1'b1;
				Result_exp <= 4'b1111;
				Result_mantissas <= 4'b0000;
				end
			end
			
		else if (Unshifted_Result_Mantissas[4] == 1) begin
			Result_exp <= Bigger_exp;
			Result_mantissas <= Unshifted_Result_Mantissas[3:0];
			OV <= 1'b0;
			end
			
		else if (Unshifted_Result_Mantissas[3] == 1) begin
			if (Bigger_exp >= 1) begin
				Result_exp <= Bigger_exp - 1;
				Result_mantissas <= {Unshifted_Result_Mantissas[2:0] , 1'b0};
				OV <= 1'b0;
				end
			else begin
				OV <= 1'b1;
				Result_exp <= 4'b1111;
				Result_mantissas <= 4'b0000;
				end
			end
			
		else if (Unshifted_Result_Mantissas[2] == 1) begin
			if (Bigger_exp >= 2) begin
				Result_exp <= Bigger_exp - 2;
				Result_mantissas <= {Unshifted_Result_Mantissas[1:0] , 2'b0};
				OV <= 1'b0;
				end
			else begin
				OV <= 1'b1;
				Result_exp <= 4'b1111;
				Result_mantissas <= 4'b0000;
				end
			end
			
		else if (Unshifted_Result_Mantissas[1] == 1) begin
			if (Bigger_exp >= 3) begin
				Result_exp <= Bigger_exp - 3;
				Result_mantissas <= {Unshifted_Result_Mantissas[0] , 3'b0};
				OV <= 1'b0;
				end
			else begin
				OV <= 1'b1;
				Result_exp <= 4'b1111;
				Result_mantissas <= 4'b0000;
				end
			end
			
		else if (Unshifted_Result_Mantissas[0] == 1) begin
			if (Bigger_exp >= 4) begin
				Result_exp <= Bigger_exp - 4;
				Result_mantissas <= 4'b0;
				OV <= 1'b0;
				end
			else begin
				OV <= 1'b1;
				Result_exp <= 4'b1111;
				Result_mantissas <= 4'b0000;
				end
			end
			
			else begin
				OV <= 1'b0;
				Result_exp <= 4'b0000;
				Result_mantissas <= 4'b0000;
				end
			end

endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

module Sign(Exp_diff, Manti_diff, Sign_A, Sign_B, S, Result_sign);

	input [4:0] Exp_diff, Manti_diff;
	input Sign_A, Sign_B, S;
	output Result_sign;

	always_comb begin
		if (S == 0) begin
			if (Exp_diff == 0) begin
				if (Manti_diff[4] == 0) Result_sign <= Sign_A;
				else Result_sign <= Sign_B;
				end
			else if (Exp_diff[4] == 0) Result_sign <= Sign_A;
			else Result_sign <= Sign_B;
		end
		
		else begin
			if (Exp_diff == 0) begin
				if (Manti_diff[4] == 0) Result_sign <= Sign_A;
				else Result_sign <= ~Sign_B;
				end
			else if (Exp_diff[4] == 0) Result_sign <= Sign_A;
			else Result_sign <= ~Sign_B;
		end
	end
	
endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////		

module Result(A, B, Result_sign, S, Result_exp, Result_mantissas, Z, Result);

	input [8:0] A, B;
	input Result_sign, S;
	input [3:0] Result_exp, Result_mantissas;
	output Z;
	output [8:0] Result;

	always_comb begin
		if ((A[7:0] == B[7:0] && A[8] != B[8] && S == 0) | (A[8:0] == B[8:0] && S == 1)) begin
			Z <= 1'b1;
			Result <= '0;
			end
		else begin
			Z <= 1'b0;
			Result <= {Result_sign, Result_exp, Result_mantissas};
			end
	end

endmodule