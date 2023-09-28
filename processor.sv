module CPU
(input  logic       Resetn,
 input  logic       Run,
 input  logic       Clock,
 input  logic [8:0] DIN,
 output logic [8:0] BUS,
 output logic       Done
);

  logic R0in, R1in, R2in, R3in, R4in, R5in, R6in, R7in;
  logic R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out;
  logic IRin, Ain, Gin, IRout, Aout, Gout;
  
  logic AddSub;
  
  logic [8:0] IR_bus, A_bus, G_bus, R0_bus, R1_bus, R2_bus, R3_bus, R4_bus, R5_bus, R6_bus, R7_bus; // output bus of register 
  logic [8:0] Bus;
  
  logic [9:0] data_selector;
  assign data_selector = {R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out, IRout, Gout};
  
  register_9bit IR_reg (.D(DIN), .Q(IR_bus), .Enable(IRin), .*);
  register_9bit A_reg  (.D(Bus), .Q(A_bus),  .Enable(Ain), .*);
  register_9bit G_reg  (.D(addsub_result), .Q(G_bus),  .Enable(Gin), .*);

  register_9bit R0_reg (.D(Bus), .Q(R0_bus), .Enable(R0in), .*);
  register_9bit R1_reg (.D(Bus), .Q(R1_bus), .Enable(R1in), .*);
  register_9bit R2_reg (.D(Bus), .Q(R2_bus), .Enable(R2in), .*);
  register_9bit R3_reg (.D(Bus), .Q(R3_bus), .Enable(R3in), .*);
  register_9bit R4_reg (.D(Bus), .Q(R4_bus), .Enable(R4in), .*);
  register_9bit R5_reg (.D(Bus), .Q(R5_bus), .Enable(R5in), .*);
  register_9bit R6_reg (.D(Bus), .Q(R6_bus), .Enable(R6in), .*);
  register_9bit R7_reg (.D(Bus), .Q(R7_bus), .Enable(R7in), .*);
  
  logic [8:0] addsub_result;
  Addsub arithmetic_unit (.A(A_bus), .B(Bus), .S(addsub_result), .*);
  
  Multiplexers MUX_data (.Select(data_selector), .*);
  
  logic Rx_i, Rx_o, Ry_o;
  
  Control_unit FSM (.*); 
  
  assign BUS = Bus;
  
endmodule: CPU

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////

module Control_unit
(input  logic [8:0] IR_bus,
 input  logic       Run,
 input  logic       Resetn,
 input  logic       Clock,
 output logic       R0in, R1in, R2in, R3in, R4in, R5in, R6in, R7in,
 output logic       R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out,
 output logic       IRin, Ain, Gin, IRout, Aout, Gout,
 output logic       AddSub,
 output logic       Done
);

  logic [2:0] III, Rx, Ry;
  assign III = IR_bus[8:6];
  assign Rx  = IR_bus[5:3];
  assign Ry  = IR_bus[2:0];
  
  logic Rx_i, Rx_o, Ry_o;
  
  parameter mv = 3'b000, mvi = 3'b001, add = 3'b010, sub = 3'b011, ld = 3'b100, st = 3'b101, mvnz = 3'b110;
 
  typedef enum logic [1:0] {T0 = 2'b00,
							T1 = 2'b01,
							T2 = 2'b10,
							T3 = 2'b11
						   } state_t;
  
  state_t present_state, next_state;
  
  always_ff @(posedge Clock or negedge Resetn)
    if (!Resetn)
      present_state <= T0;
    else
      present_state <= next_state;
      
  always_comb begin
    next_state = T0;
    case (present_state)
      T0: 
        if (Run)
        next_state = T1;
        else
        next_state = T0;
      T1: 
        case (III)
          mv:  
            next_state = T0;
          mvi: 
            next_state = T0;
          add:
            next_state = T2;
          sub:
            next_state = T2;
          default: 
            next_state = T0;  
        endcase
      T2: 
        case (III)
          add:
            next_state = T3;
          sub:
            next_state = T3; 
          default: next_state = T0; 
        endcase 
      T3: 
        next_state = T0;  
    endcase
  end
  
  always_comb begin
    IRin  = '0;
    IRout = '0;
    Rx_i  = '0;
    Rx_o  = '0;
    Done  = '0;
    Ry_o  = '0;
    Ain   = '0;
    Aout  = '0;
    Gin   = '0;
    Gout  = '0;
    AddSub = '0;
    case (present_state) 
      T0: 
        if (Run) begin
            IRin = '1;
        end
      T1: 
        case (III)
          mv: 
            begin
              Ry_o = '1;
              Rx_i = '1;
              Done = '1;
            end
          mvi:
            begin
              IRout = '1;
              Rx_i  = '1; 
              Done  = '1;
            end
          add:
            begin
              Rx_o = '1;
              Ain  = '1;
            end
          sub:
            begin
              Rx_o = '1;
              Ain  = '1;
            end
        endcase
      T2: 
        case (III)
          add:
            begin
              Ry_o = '1;
              Gin  = '1;
              AddSub = '0;
            end
          sub:
            begin
              Ry_o = '1;
              Gin  = '1;
              AddSub = '1;
            end
        endcase
      T3: 
        case (III)
          add:
            begin
              Gout = '1;
              Rx_i = '1;
              Done = '1;
            end
          sub:
            begin
              Gout = '1;
              Rx_i = '1;
              Done = '1;
            end
        endcase
    endcase
  end
  
  always_comb begin
     {R0in, R1in, R2in, R3in, R4in, R5in, R6in, R7in} = '0;
     if (Rx_i) begin
       case (Rx) 
         3'b000: R0in = '1;
         3'b001: R1in = '1;
         3'b010: R2in = '1;
         3'b011: R3in = '1;
         3'b100: R4in = '1;
         3'b101: R5in = '1;
         3'b110: R6in = '1;
         3'b111: R7in = '1;
       endcase
     end
   end
   
   always_comb begin
     {R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out} = '0;
     if (Ry_o) begin
       case (Ry) 
         3'b000: {R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out} = 8'b1000_0000;
         3'b001: {R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out} = 8'b0100_0000;
         3'b010: {R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out} = 8'b0010_0000;
         3'b011: {R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out} = 8'b0001_0000;
         3'b100: {R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out} = 8'b0000_1000;
         3'b101: {R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out} = 8'b0000_0100;
         3'b110: {R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out} = 8'b0000_0010;
         3'b111: {R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out} = 8'b0000_0001;
       endcase
     end
     else if (Rx_o) begin
       case (Rx) 
         3'b000: {R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out} = 8'b1000_0000;
         3'b001: {R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out} = 8'b0100_0000;
         3'b010: {R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out} = 8'b0010_0000;
         3'b011: {R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out} = 8'b0001_0000;
         3'b100: {R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out} = 8'b0000_1000;
         3'b101: {R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out} = 8'b0000_0100;
         3'b110: {R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out} = 8'b0000_0010;
         3'b111: {R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out} = 8'b0000_0001;
       endcase
     end
   end

endmodule: Control_unit

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////

module register_9bit
(input  logic       Clock,
 input  logic       Resetn,
 input  logic       Enable,
 input  logic [8:0] D,
 output logic [8:0] Q
);

  always_ff @(posedge Clock or negedge Resetn) begin
    if (!Resetn) begin
      Q <= '0;
    end
    else if (Enable) begin
      Q <= D;
    end
  end
  
endmodule: register_9bit 
  
module Addsub
(input  logic [8:0] A, B,
 input  logic       AddSub,
 output logic [8:0] S
); 

  always_comb begin
    S = '0;
    case (AddSub)
      1'b0: S = A + B;
      1'b1: S = A - B;
    endcase
  end

endmodule: Addsub

module Multiplexers
(input  logic [9:0] Select,
 input  logic [8:0] DIN, G_bus, R0_bus, R1_bus, R2_bus, R3_bus, R4_bus, R5_bus, R6_bus, R7_bus,
 output logic [8:0] Bus
);

  always_comb begin
    unique case (Select)
      10'b10000_00000: Bus = R0_bus;
      10'b01000_00000: Bus = R1_bus;
      10'b00100_00000: Bus = R2_bus;
      10'b00010_00000: Bus = R3_bus;
      10'b00001_00000: Bus = R4_bus;
      10'b00000_10000: Bus = R5_bus;
      10'b00000_01000: Bus = R6_bus;
      10'b00000_00100: Bus = R7_bus;
      10'b00000_00010: Bus = DIN;
      10'b00000_00001: Bus = G_bus;
    endcase
  end
  
endmodule: Multiplexers

module MyRAM
#(parameter width = 9,
  parameter depth = 32,
  parameter intFile = "inst_mem.txt",
  parameter addrBits = 5)

(input logic        CLK,
 input  logic [4:0] ADDRESS,
 output logic [8:0] DATAOUT
);

  logic [8:0] ram [0:31];
  // initialise RAM contents
  initial begin
    $readmemb("inst_mem.txt", ram);
  end
  
  always_ff @ (posedge CLK) begin
    DATAOUT <= ram[ADDRESS];
  end
  
endmodule: MyRAM

module processor 
(input  logic       CLK,
 input  logic       Run,
 input  logic       Resetn,
 input  logic [4:0] ADDRESS,
 output logic [8:0] DATA,
 output logic       Done
);
  
  logic [8:0] DATAOUT;
  
  MyRAM U0 (.CLK(CLK), .ADDRESS(ADDRESS), .DATAOUT(DATAOUT)); 
  CPU CPU (.DIN(DATAOUT), .Clock(CLK), .BUS(DATA), .*);

endmodule: processor