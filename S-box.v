`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.07.2025 18:15:13
// Design Name: 
// Module Name: sbox
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
// Code your design here
module sbox(input [7:0]a, input ctrl,output [7:0]y);
  wire [7:0]w1,w2;
  
  preprocess p1(.w(a),.x(w1),.mode1(ctrl));
  inversion i1(.l(w1),.m(w2));
  postprocess p3(.n(w2),.o(y),.mode2(ctrl));
endmodule

//preprocess
module preprocess(input [7:0]w, input mode1, output [7:0]x);
  wire t00,t01,t02,t03;
  
  xor v0(t00,w[7],w[3],w[2]);
  xor v1(t01,w[6],w[1]);
  xor v2(t02,w[7],w[2]);
  xor v3(t03,w[7],w[5]);
  
  wire [7:0]t1,t2; //inputs to 2:1 mux
  buf x7(t1[7],t03);  // encryption path
  xor x8(t1[6],t00,t01,w[4]);
  xor x9(t1[5],t00,w[5]);
  xor x10(t1[4],t1[5],w[1]);
  xor x11(t1[3],t02,t01);
  xor x12(t1[2],t00,w[4],w[1]);
  xor x13(t1[1],t01,w[4]);
  xor x14(t1[0],w[0],t01);
  xor x15(t2[7],t01,t02); //decryption path
  xor x16(t2[6],t00,t01,w[0],1'b1);
  xnor x17(t2[5],w[6],w[5],w[4],w[0]);
  xnor x18(t2[4],w[5],w[4],w[3]);
  xor x19(t2[3],t03,1'b1);
  xor x20(t2[2],t01,t03,w[2],1'b1);
  xor x21(t2[1],w[5],w[3],w[1]);
  xor x22(t2[0],t02,w[6],1'b1);
 mux21 m21(.i0(t1),.i1(t2),.sel(mode1),.op(x));
endmodule




//2:1 mux design
module mux21(input [7:0]i0,i1,input sel, output [7:0]op);
  assign op=(sel==1'b0)?i0:i1;
endmodule

//GF multiplier module
module mul(input [3:0]d,e, output [3:0]f);
  
  wire f1,f2,f3,f4,f5,f6,f7,f8,f9,f10;
  
  xor y1(f1,e[3],e[2]);
  xor y2(f2,d[3],d[2]);
  xor y3(f3,d[1],d[0]);
  xor y4(f4,e[1],e[0]);
  and y5(f5,e[2],d[0]);
  and y6(f6,e[2],d[2]);
  and y7(f7,e[3],d[3]);
  and y8(f8,e[0],d[0]);
  and y9(f9,e[0],d[2]);
  and y10(f10,f1,f2);
  xor y11(f[3],f10,(f1&f3),(f4&f2),f5,f9,f6);
  xor y12(f[2],f7,(e[3]&d[1]),(e[1]&d[3]),f6,f5,f9);
  xor y13(f[1],f10,f7,(f4&f3),f8);
  xor y14(f[0],f10,f6,(e[1]&d[1]),f8);
endmodule

//GF inversion in GF(2^4)
module inv4(input [3:0]g,output [3:0]h);
  wire h1,h2,h3,h4,h5,h6,h7,h8,h9,h10;
  not n1(h7,g[0]);
  not n2(h8,g[1]);
  not n3(h9,g[2]);
  not n4(h10,g[3]);
  and n5(h1,h10,g[2]);
  and n6(h2,h8,g[2]);
  and n7(h3,h9,g[1]);
  and n8(h4,h9,g[3]);
  and n9(h5,g[3],g[0]);
  and n10(h6,h10,g[1]);
  or n11(h[3],h1,(h2&g[0]),(g[2]&g[1]&h7),(h4&h7));
  or n12(h[2],(g[3]&g[2]),h5,h2);
  or n13(h[1],(h1&h8&h7),(h4&h8),(h5&h8),(h4&g[0]),(h10&h3),(h6&g[0]));
  or n14(h[0],(h6&h7),(h1&g[1]),(h3&h5),(h10&h9&h8&g[0]),(g[2]&h7));
endmodule

//4 bit xor module

module xor4(input [3:0]i,j,output [3:0]k);
  xor i1(k[3],i[3],j[3]);
  xor i2(k[2],i[2],j[2]);
  xor i3(k[1],i[1],j[1]);
  xor i4(k[0],i[0],j[0]);
endmodule

//inversion module
module inversion(input [7:0]l,output [7:0]m);
  wire [3:0]b1,b2,b3,b4,b5;
  wire b6;
  
  xor i1(b6,l[4],l[5]);
  xor i2(b2[3],b6,l[6]);
  xor i3(b2[2],l[7],l[4]);
  and i4(b2[1],l[7],1'b1);
  xor i5(b2[0],l[7],l[6]);
  xor4 i6(.i(l[3:0]),.j(l[7:4]),.k(b1));
  mul i7(.d(b1),.e(l[3:0]),.f(b3));
  xor4 i8(.i(b2),.j(b3),.k(b4));
  inv4 i9(.g(b4),.h(b5));
  mul i10(.d(b5),.e(l[7:4]),.f(m[7:4]));
  mul i11(.d(b1),.e(b5),.f(m[3:0]));
endmodule


//post processing
module postprocess(input [7:0]n,input mode2,output [7:0]o);
  
  wire k00,k01,k02,k03,k04;
  wire [7:0]p,r;
  xor h18(k00,n[6],n[5],n[4]);
  xor h19(k01,n[7],n[2]);
  xor h20(k02,n[3],n[1]);
  xor h21(k03,n[6],n[5]);
  xor h22(k04,n[1],n[0]);
  xor h1(p[7],n[7],k03,n[1]); //decryption-path
  xor h2(p[6],n[6],n[2]);
  xor h3(p[5],k03,n[1]);
  xor h4(p[4],k00,n[2],n[1]);
  xor h5(p[3],n[4],n[5],k02,n[2]);
  xor h6(p[2],k01,n[4],k02);
  xor h7(p[1],n[4],n[5]);
  xor h8(p[0],n[0],k00,n[2]);  
  xor h9(r[7],k01,n[3]);      //encryption-path
  xor h10(r[6],n[7],k00,1'b1);
  xor h11(r[5],k01,1'b1);
  xor h12(r[4],n[7],n[4],k04);
  xor h13(r[3],n[2],k04);
  xor h14(r[2],k00,n[3],n[2],n[0]);
  xnor h15(r[1],n[7],n[0]);
  xor h16(r[0],k01,n[6],k04,1'b1);
  mux21 h17(.i0(r),.i1(p),.sel(mode2),.op(o));
endmodule