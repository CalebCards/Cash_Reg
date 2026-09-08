`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2026 12:02:57 PM
// Design Name: 
// Module Name: CLA_UNIT
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CLA_UNIT(
    input [11:0] A,B,
    input sub,
    output [11:0] sum,
    output co
    );
    wire c6,ci;
    wire [11:0] B_new;
    assign B_new[0] = B[0] ^ sub;
    assign B_new[1] = B[1] ^ sub;
    assign B_new[2] = B[2] ^ sub;
    assign B_new[3] = B[3] ^ sub;
    assign B_new[4] = B[4] ^ sub;
    assign B_new[5] = B[5] ^ sub;
    assign B_new[6] = B[6] ^ sub;
    assign B_new[7] = B[7] ^ sub;
    assign B_new[8] = B[8] ^ sub;
    assign B_new[9] = B[9] ^ sub;
    assign B_new[10] = B[10] ^ sub;
    assign B_new[11] = B[11] ^ sub;
    assign ci = sub;
    six_bit_CLA CLA0(.A(A[5:0]),.B(B_new[5:0]),.ci(ci),.sum(sum[5:0]),.co(c6));
    six_bit_CLA CLA1(.A(A[11:6]),.B(B_new[11:6]),.ci(c6),.sum(sum[11:6]),.co(co));
endmodule

module sum_g_p(
    input a,b,
    output g,p
    );
    assign g = a&b;
    assign p = a^b;
endmodule

module cla_logic(
    input [5:0] g,p,
    input ci,
    output [6:0] c
    );
    assign c[0] = ci;
    assign c[1] = g[0] | (p[0] & ci);
    assign c[2] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & ci);
    assign c[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1]  & g[0]) | (p[2] & p[1] & p[0] & ci);
    assign c[4] = g[3] | (p[3] & g[2]) | (p[3] & p[2]  & g[1]) | (p[3] & p[2] & p[1] & g[0]) | (p[3] & p[2] & p[1] & p[0] & ci);
    assign c[5] = g[4] | (p[4] & g[3]) | (p[4] & p[3] & g[2]) | (p[4] & p[3] & p[2] & g[1]) | (p[4] & p[3] & p[2] & p[1] & g[0]) | (p[4] & p[3] & p[2] & p[1] & p[0] & ci);
    assign c[6] = g[5] | (p[5] & g[4]) | (p[5] & p[4] & g[3]) | (p[5] & p[4] & p[3] & g[2]) | (p[5] & p[4] & p[3] & p[2] & g[1]) | (p[5] & p[4] & p[3] & p[2] & p[1] & g[0]) | (p[5] & p[4] & p[3] & p[2] & p[1] & p[0] & ci);

endmodule

module six_bit_CLA(
    input [5:0] A,B,
    input ci,
    output [5:0] sum,
    output co
);
    wire [5:0] G,P;
    
    sum_g_p U0 (.a(A[0]),.b(B[0]),.g(G[0]),.p(P[0]));
    sum_g_p U1 (.a(A[1]),.b(B[1]),.g(G[1]),.p(P[1]));
    sum_g_p U2 (.a(A[2]),.b(B[2]),.g(G[2]),.p(P[2]));
    sum_g_p U3 (.a(A[3]),.b(B[3]),.g(G[3]),.p(P[3]));
    sum_g_p U4 (.a(A[4]),.b(B[4]),.g(G[4]),.p(P[4]));
    sum_g_p U5 (.a(A[5]),.b(B[5]),.g(G[5]),.p(P[5]));
    
    wire [6:0] C;
    
    cla_logic CL (.g(G),.p(P),.ci(ci),.c(C));
    
    assign sum[0] = A[0] ^ B[0] ^ C[0];
    assign sum[1] = A[1] ^ B[1] ^ C[1];
    assign sum[2] = A[2] ^ B[2] ^ C[2];
    assign sum[3] = A[3] ^ B[3] ^ C[3];
    assign sum[4] = A[4] ^ B[4] ^ C[4];
    assign sum[5] = A[5] ^ B[5] ^ C[5];
    
    assign co = C[6];
endmodule
    
    