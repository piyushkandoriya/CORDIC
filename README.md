
# **2D-CORDIC (ROTATING MODE AND VECTORING MODE)**
# INDEX
 <div class="toc">
  <ul>
    <li><a href="#header-1">2D ROTATING MODE CORDIC</a></li>
	<ul>
        <li><a href="#header-1_1">VERILOG code and Simulation output</a></li>
      </ul>
      <ul>
        <li><a href="#header-1_2">Synthesis of 2D ROTATING MODE CORDIC using GENUS</a></li>
      </ul>
</div>
	
  <div class="toc">
  <ul>
      <li><a href="#header-2">2D VECTORING MODE CORDIC</a></li>
	<ul>
        <li><a href="#header-2_1">VERILOG code and Simulation output</a></li>
      </ul>
      <ul>
        <li><a href="#header-2_2">Synthesis of 2D VECTORING MODE CORDIC using GENUS</a></li>
      </ul>
  </div>
  <div class="toc">
  <ul>
    <li><a href="#header-3">ROTATING and VECTORING combine design of CORDIC</a></li>
	<ul>
        <li><a href="#header-3_1">VERILOG code and Simulation output</a></li>
      </ul>
      <ul>
        <li><a href="#header-3_2">Synthesis of ROTATING and VECTORING combine design of CORDIC using GENUS</a></li>
      </ul>
</div>
	
<div class="toc">
  <ul>
    <li><a href="#header-4">Doubly Pipeling of ROTATING and VECTORING CORDIC</a></li>
	<ul>
        <li><a href="#header-4_1">VERILOG code and Simulation output</a></li>
      </ul>
      <ul>
        <li><a href="#header-4_2">Synthesis of Doubly Pipeling of ROTATING and VECTORING CORDIC using GENUS</a></li>
      </ul>
	<ul>
 </div>
		
# <h1 id="header-1">2D ROTATING MODE CORDIC</h1>	 
## <h1 id="header-1_1">VERILOG code and Simulation output</h1>
### VERILOG CODE
```verilog
  module ROTATING(x0, y0, theta, xf, yf, clk);
  input clk;
  input [15:0] x0, y0;
  input [15:0] theta;
  output [15:0] xf, yf;
  wire [15:0] xi [0:7]; 
  wire [15:0] yi [0:7];
  reg [2:0] stage;
  wire [15:0] outangle [0:7];
  
  
  // instantiating
  
  //stage0
  cordics r0(clk, 3'd0, x0, y0, theta, 16'd45_00, 16'd0, xi[0], yi[0], outangle[0]);
  //stage1
  cordics r1(clk, 3'd1, xi[0], yi[0], theta, 16'd26_57, outangle[0], xi[1], yi[1], outangle[1]);
  //stage2
  cordics r2(clk, 3'd2, xi[1], yi[1], theta, 16'd14_04, outangle[1], xi[2], yi[2], outangle[2]); 
  //stage3
  cordics r3(clk, 3'd3, xi[2], yi[2], theta, 16'd7_13, outangle[2], xi[3], yi[3], outangle[3]);
  //stage4
  cordics r4(clk, 3'd4, xi[3], yi[3], theta, 16'd3_58, outangle[3], xi[4], yi[4], outangle[4]);  
  //stage5
  cordics r5(clk, 3'd5, xi[4], yi[4], theta, 16'd1_79, outangle[4], xi[5], yi[5], outangle[5]);
  //stage6
  cordics r6(clk, 3'd6, xi[5], yi[5], theta, 16'd89, outangle[5], xi[6], yi[6], outangle[6]);
  //stage7
  cordics r7(clk, 3'd7, xi[6], yi[6], theta, 16'd44, outangle[6], xi[7], yi[7], outangle[7]);
  assign xf = xi[7];
  assign yf = yi[7];
  // assign xf <= (xi[7]>>>1)+(xi[7]>>>4)+(xi[7]>>>5);
  //assign yf <= (yi[7]>>>1)+(yi[7]>>>4)+(yi[7]>>>5);
  
endmodule
  
  
module cordics(clk,stage,xi,yi,theta,uangle,inangle,xf,yf,outangle);
 input clk;
 input [2:0] stage;
 input [15:0] xi,yi,theta,inangle,uangle;
 output reg [15:0] xf,yf,outangle;

 always @(posedge clk)begin
   if((inangle)>theta)begin                                   //clockwise

    case({xi[15],yi[15]})
       2'b00 : begin
          xf <= xi+(yi>>stage);
            yf <= yi - (xi>>stage);
       end
       2'b01 : begin
          xf <= xi-((16'hffff-yi+1)>>stage);
          yf <= -(16'hffff-yi+1) - (xi>>stage);
       end 
      2'b10 : begin
          xf <= -(16'hffff-xi+1)+(yi>>stage);
          yf <= yi +((16'hffff-xi+1)>>stage);
       end
      2'b11 : begin 
          xf <= -(16'hffff-xi+1)-((16'hffff-yi+1)>>stage);
          yf <= -(16'hffff-yi+1) + ((16'hffff-xi+1)>>stage);
       end
    endcase
    outangle <= inangle-uangle;
   end
   
   else begin 
    case({xi[15],yi[15]})
       2'b00 : begin                                        //anticlockwise
          xf <= xi-(yi>>stage);
          yf <= yi + (xi>>stage);
        end
       2'b01 : begin
            xf <= xi + ((16'hffff-yi+1)>>stage);
            yf <= -(16'hffff-yi+1) + (xi>>stage);
        end 
       2'b10 : begin
          xf <= -((16'hffff-xi+1))-(yi>>stage);
          yf <= yi - ((16'hffff-xi+1)>>stage);
        end 
       2'b11 : begin
          xf <= -(16'hffff-xi+1)+((16'hffff-yi+1)>>stage);
          yf <= -(16'hffff-yi+1) - ((16'hffff-xi+1)>>stage);
        end
    endcase
         outangle <= inangle+uangle;
   end
  end
endmodule
```
	  
### Test bench
```verilog
module ROTATING_TB #(parameter period=5);
  reg clk=0;
  reg [15:0]x0,y0;
  reg [15:0]theta;
  wire [15:0]xf,yf;
  always @(*)begin
    #period clk<=~clk;
    end
  ROTATING dut(x0,y0,theta,xf,yf,clk);
  initial begin
    {x0,y0,theta}={16'd3, 16'd4, 16'd5300};
   end
endmodule
```

### Output Waveform
<img width="749" alt="image" src="https://user-images.githubusercontent.com/123488595/234951940-43d1d883-0c29-4c53-9ae9-342ddd7b9cec.png">


## <h1 id="header-1_2">Synthesis of 2D ROTATING MODE CORDIC using GENUS</h1>
To synthesis the code, first we have to login into server by given code:
```
	  ssh -X dic_lab_03@192.168.88.31
```
	  
Then create the working directory
```
/DIG_DESIGN/INTERNS/dic_lab_03/piyush/rotating/
```
	  
Now add verilog (rotating.v) and .tcl file (rotating.tcl)
Then done the synthesis by given below command:
```
tcsh
source /DIG_DESIGN02/APPLICATION_CMS/Cadence/cshrc_cadence
```
	  
```
genus -legacy_ui
```
	 
```
source rotating.tcl	  
```
	  
### Terminal
<img width="960" alt="image" src="https://user-images.githubusercontent.com/123488595/234963835-14089e12-e716-46fd-82b1-322637531490.png">

### Synthesis Design
<img width="791" alt="image" src="https://user-images.githubusercontent.com/123488595/234964257-5705aff6-0270-4c9b-9e05-8eccb0a39374.png">

<img width="790" alt="image" src="https://user-images.githubusercontent.com/123488595/234964437-89bc5ec7-c3c4-40b7-b76e-531d24952ec0.png">
