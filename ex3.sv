module ex3
(input  logic        clk,
 input  logic        rstN,
 input  logic        en_a, en_b,
 input  logic [7:0]  a, b,
 output logic [15:0] p
);
  
  logic [7:0]  a_temp, b_temp;
  logic [15:0] p_temp;
   
  always_ff @(posedge clk or negedge rstN) begin
    if (!rstN) begin
      a_temp <= '0;
    end
    else if (en_a) begin
      a_temp <= a;
    end
  end
  
  always_ff @(posedge clk or negedge rstN) begin
    if (!rstN) begin
      b_temp <= '0;
    end
    else if (en_b) begin
      b_temp <= b;
    end
  end
  
  always_ff @(posedge clk or negedge rstN)
    if (!rstN)
      p <= '0;
    else
      p <= p_temp;
      
////////////////////////////////////////////////
////////////                        ////////////
//////////// ARRAY MULTIPLIER LOGIC ////////////
////////////                        ////////////
////////////////////////////////////////////////

  logic [7:0] b0, b1, b2, b3, b4, b5, b6, b7;
 
  assign b0 = {8{b_temp[0]}};
  assign b1 = {8{b_temp[1]}};
  assign b2 = {8{b_temp[2]}};
  assign b3 = {8{b_temp[3]}};
  assign b4 = {8{b_temp[4]}};
  assign b5 = {8{b_temp[5]}};
  assign b6 = {8{b_temp[6]}};
  assign b7 = {8{b_temp[7]}};
  
  logic [7:0] ab0, ab1, ab2, ab3, ab4, ab5, ab6, ab7;
  
  assign ab0 = a_temp & b0;
  assign ab1 = a_temp & b1;
  assign ab2 = a_temp & b2;
  assign ab3 = a_temp & b3;
  assign ab4 = a_temp & b4;
  assign ab5 = a_temp & b5;
  assign ab6 = a_temp & b6;
  assign ab7 = a_temp & b7; 

  logic c0,  c1,  c2,  c3,  c4,  c5,  c6;
  logic c7,  c8,  c9,  c10, c11, c12, c13;
  logic c14, c15, c16, c17, c18, c19, c20;
  logic c21, c22, c23, c24, c25, c26, c27;
  logic c28, c29, c30, c31, c32, c33, c34;
  logic c35, c36, c37, c38, c39, c40, c41;
  logic c42, c43, c44, c45, c46, c47, c48;
  logic c49, c50, c51, c52, c53, c54, c55;
  
  logic s0,  s1,  s2,  s3,  s4,  s5,  s6;
  logic s7,  s8,  s9,  s10, s11, s12, s13;
  logic s14, s15, s16, s17, s18, s19, s20;
  logic s21, s22, s23, s24, s25, s26, s27;
  logic s28, s29, s30, s31, s32, s33, s34;
  logic s35, s36, s37, s38, s39, s40, s41;
  logic s42, s43, s44, s45, s46, s47, s48;
  logic s49, s50, s51, s52, s53, s54, s55;
  
  logic p_0;
  assign p_0 = ab0[0];
  
  /* ab0[0] is for p0 */
  
  half_adder ha0 (.a(ab0[1]), .b(ab1[0]), .s(s0), .co(c0));
  half_adder ha1 (.a(ab0[2]), .b(ab1[1]), .s(s1), .co(c1));
  half_adder ha2 (.a(ab0[3]), .b(ab1[2]), .s(s2), .co(c2));
  half_adder ha3 (.a(ab0[4]), .b(ab1[3]), .s(s3), .co(c3));
  half_adder ha4 (.a(ab0[5]), .b(ab1[4]), .s(s4), .co(c4));
  half_adder ha5 (.a(ab0[6]), .b(ab1[5]), .s(s5), .co(c5));
  half_adder ha6 (.a(ab0[7]), .b(ab1[6]), .s(s6), .co(c6));
  
  full_adder fa0 (.a(s1), .b(ab2[0]), .ci(c0), .s(s7),  .co(c7));
  full_adder fa1 (.a(s2), .b(ab2[1]), .ci(c1), .s(s8),  .co(c8));
  full_adder fa2 (.a(s3), .b(ab2[2]), .ci(c2), .s(s9),  .co(c9)); 
  full_adder fa3 (.a(s4), .b(ab2[3]), .ci(c3), .s(s10), .co(c10));
  full_adder fa4 (.a(s5), .b(ab2[4]), .ci(c4), .s(s11), .co(c11));
  full_adder fa5 (.a(s6), .b(ab2[5]), .ci(c5), .s(s12), .co(c12));
  full_adder fa6 (.a(ab1[7]), .b(ab2[6]), .ci(c6), .s(s13), .co(c13));
  
  full_adder fa7  (.a(s8),  .b(ab3[0]), .ci(c7),  .s(s14), .co(c14));
  full_adder fa8  (.a(s9),  .b(ab3[1]), .ci(c8),  .s(s15), .co(c15));
  full_adder fa9  (.a(s10), .b(ab3[2]), .ci(c9),  .s(s16), .co(c16)); 
  full_adder fa10 (.a(s11), .b(ab3[3]), .ci(c10), .s(s17), .co(c17));
  full_adder fa11 (.a(s12), .b(ab3[4]), .ci(c11), .s(s18), .co(c18));
  full_adder fa12 (.a(s13), .b(ab3[5]), .ci(c12), .s(s19), .co(c19));
  full_adder fa13 (.a(ab2[7]), .b(ab3[6]), .ci(c13), .s(s20), .co(c20));
  
  full_adder fa14 (.a(s15), .b(ab4[0]), .ci(c14), .s(s21), .co(c21));
  full_adder fa15 (.a(s16), .b(ab4[1]), .ci(c15), .s(s22), .co(c22));
  full_adder fa16 (.a(s17), .b(ab4[2]), .ci(c16), .s(s23), .co(c23)); 
  full_adder fa17 (.a(s18), .b(ab4[3]), .ci(c17), .s(s24), .co(c24));
  full_adder fa18 (.a(s19), .b(ab4[4]), .ci(c18), .s(s25), .co(c25));
  full_adder fa19 (.a(s20), .b(ab4[5]), .ci(c19), .s(s26), .co(c26));
  full_adder fa20 (.a(ab3[7]), .b(ab4[6]), .ci(c20), .s(s27), .co(c27));
  
  full_adder fa21 (.a(s22), .b(ab5[0]), .ci(c21), .s(s28), .co(c28));
  full_adder fa22 (.a(s23), .b(ab5[1]), .ci(c22), .s(s29), .co(c29));
  full_adder fa23 (.a(s24), .b(ab5[2]), .ci(c23), .s(s30), .co(c30)); 
  full_adder fa24 (.a(s25), .b(ab5[3]), .ci(c24), .s(s31), .co(c31));
  full_adder fa25 (.a(s26), .b(ab5[4]), .ci(c25), .s(s32), .co(c32));
  full_adder fa26 (.a(s27), .b(ab5[5]), .ci(c26), .s(s33), .co(c33));
  full_adder fa27 (.a(ab4[7]), .b(ab5[6]), .ci(c27), .s(s34), .co(c34));
  
  full_adder fa28 (.a(s29), .b(ab6[0]), .ci(c28), .s(s35), .co(c35));
  full_adder fa29 (.a(s30), .b(ab6[1]), .ci(c29), .s(s36), .co(c36));
  full_adder fa30 (.a(s31), .b(ab6[2]), .ci(c30), .s(s37), .co(c37)); 
  full_adder fa31 (.a(s32), .b(ab6[3]), .ci(c31), .s(s38), .co(c38));
  full_adder fa32 (.a(s33), .b(ab6[4]), .ci(c32), .s(s39), .co(c39));
  full_adder fa33 (.a(s34), .b(ab6[5]), .ci(c33), .s(s40), .co(c40));
  full_adder fa34 (.a(ab5[7]), .b(ab6[6]), .ci(c34), .s(s41), .co(c41));
  
  full_adder fa35 (.a(s36), .b(ab7[0]), .ci(c35), .s(s42), .co(c42));
  full_adder fa36 (.a(s37), .b(ab7[1]), .ci(c36), .s(s43), .co(c43));
  full_adder fa37 (.a(s38), .b(ab7[2]), .ci(c37), .s(s44), .co(c44)); 
  full_adder fa38 (.a(s39), .b(ab7[3]), .ci(c38), .s(s45), .co(c45));
  full_adder fa39 (.a(s40), .b(ab7[4]), .ci(c39), .s(s46), .co(c46));
  full_adder fa40 (.a(s41), .b(ab7[5]), .ci(c40), .s(s47), .co(c47));
  full_adder fa41 (.a(ab6[7]), .b(ab7[6]), .ci(c41), .s(s48), .co(c48));
  
  half_adder ha7  (.a(s43), .b(c42), .s(s49), .co(c49));
  full_adder fa42 (.a(s44), .b(c49), .ci(c43), .s(s50), .co(c50));
  full_adder fa43 (.a(s45), .b(c50), .ci(c44), .s(s51), .co(c51)); 
  full_adder fa44 (.a(s46), .b(c51), .ci(c45), .s(s52), .co(c52));
  full_adder fa45 (.a(s47), .b(c52), .ci(c46), .s(s53), .co(c53));
  full_adder fa46 (.a(s48), .b(c53), .ci(c47), .s(s54), .co(c54));
  full_adder fa47 (.a(ab7[7]), .b(c54), .ci(c48), .s(s55), .co(c55));
   
  assign p_temp = {c55, s55, s54, s53, s52, s51, s50, s49, s42, s35, s28, s21, s14, s7, s0, p_0};
  
endmodule: ex3

module full_adder
(input  logic a, b, ci,
 output logic s, co
);

  assign s  = a ^ b ^ ci;
  assign co = (a ^ b) & ci | (a & b);

endmodule: full_adder

module half_adder
(input  logic a, b,
 output logic s, co
);

  assign s  = a ^ b;
  assign co = a & b;

endmodule: half_adder 