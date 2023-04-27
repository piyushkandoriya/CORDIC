
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
    module rotation_mode #(parameter N=32)(
    input  signed [N-1:0] x0, y0,
    input  signed [17:0] angle,
    input  clk,
    output signed [N-1:0] xf, yf
    );
   
    //Micro-angles storing in reg. multipled by 1000
    reg signed [17:0] reg_angle [0:N-1];
    initial begin reg_angle[0] = 45000; reg_angle[1] = 26565; reg_angle[2] = 14036; reg_angle[3] = 7125; //3-digit decimal
                  reg_angle[4] = 03576; reg_angle[5] = 01790; reg_angle[6] = 00895; reg_angle[7] = 0448;
                  reg_angle[8] = 00224; reg_angle[9] = 00112; reg_angle[10]= 00056; reg_angle[11]= 0028;
                  reg_angle[12]= 00014; reg_angle[13]= 00007; reg_angle[14]= 00003; reg_angle[15]= 0002;
            end
     
    //Other variables            
    reg signed [17:0] angle_new;      

    integer i;
   
    reg signed [N-1:0] x [0:N];
    reg signed [N-1:0] y [0:N];
    //reg signed [N-1:0] x, y;
   
    //Final output x[16]*0.607 --> 0.607=b0.10011011011
    //assign xf=(((x[16])>>1)+((x[16])>>4)+((x[16])>>5)+((x[16])>>7)+((x[16])>>8)+((x[16])>>10));
    //assign yf=(((y[16])>>1)+((y[16])>>4)+((y[16])>>5)+((y[16])>>7)+((y[16])>>8)+((y[16])>>10));
   
    assign xf=x[16]*0.607;
    assign yf=y[16]*0.607;
   
    always @ (posedge clk) begin
        angle_new = reg_angle[0];
        //+45 for 1st stage
        x[1] = x0 + y0;
        y[1] = y0 - x0;
        //x = x0 + y0;
        //y = y0 - x0;
       
        for (i=1;i<=15;i=i+1) begin
            if (angle_new < angle) begin  
               x[i+1] = x[i] + (y[i]>>>i);
               y[i+1] = y[i] - (x[i]>>>i);
//               x = x + (y>>>i);
//               y = y - (x>>>i);
               angle_new = angle_new + reg_angle[i];
            end
            else begin
               x[i+1] = x[i] - (y[i]>>>i);
               y[i+1] = y[i] + (x[i]>>>i);
//               x = x - (y>>>i);
//               y = y + (x>>>i);
               angle_new = angle_new - reg_angle[i];
            end
        end
    end
endmodule
```
	  
### Test bench
```verilog
module test_rotation_mode();
    parameter N=32;
    reg  signed [N-1:0] x0, y0;
    reg  signed [17:0] angle;
    reg clk;
    wire [N-1:0] xf, yf;
   
    rotation_mode_4 uut (x0, y0, angle, clk, xf, yf);

    always #5 clk=~clk;
   
    initial begin
        clk=0;
        x0=30_000; y0=40_000;
       
        angle=53_000; #10;
//        angle=30_000; #10;
//        angle=45_000; #10;
//        angle=60_000; #10;
//        angle=75_000; #10;
//        angle=90_000; #10;
        //x0=1000; y0=9000; angle=10000; #10;
        //$finish;
    end
endmodule
```
