module tb_s;
reg pclk = 0,presetn = 1,psel = 0, penable = 0, pwrite = 1;
reg [31:0] paddr = 0;
reg  [7:0] pwdata = 0;
wire pslverr;
wire [7:0] prdata;
wire pready;

apb_s dut (pclk,presetn,paddr,psel, penable,pwdata, pwrite,prdata,pready,pslverr);

always #10 pclk = ~pclk;

initial begin
presetn = 0;
repeat(5) @(posedge pclk);
presetn = 1;

////////////// valid write

            for(int i = 0; i < 5; i++)
            begin
            @(posedge pclk);
            paddr = $urandom_range(0,15);
            pwrite = 1;
            pwdata = $urandom;
            psel = 1;
            penable = 0;
            @(posedge pclk);
            penable  = 1;
            @(posedge pclk);
            psel = 0;
            penable = 0;
            end

////////////// valid read

            for(int i = 0; i < 5; i++)
            begin
            @(posedge pclk);
            pwrite = 0;
            paddr = $urandom_range(0,15);
            pwdata = $urandom;
            psel = 1;
            penable = 0;
            @(posedge pclk);
            penable  = 1;
            @(posedge pclk);
            psel = 0;
            penable = 0;
            end
            
            
 ////////////////// invalid address range during write
              
            for(int i = 0; i < 5; i++)
            begin
            @(posedge pclk);
            paddr = $urandom_range(16,255);
            pwrite = 1;
            pwdata = $urandom;
            psel = 1;
            penable = 0;
            @(posedge pclk);
            penable  = 1;
            @(posedge pclk);
            psel = 0;
            penable = 0;
            end         
            
  ////////////////// invalid address range during read
              
            for(int i = 0; i < 5; i++)
            begin
            @(posedge pclk);
            paddr = $urandom_range(16,255);
            pwrite = 0;
            pwdata = $urandom;
            psel = 1;
            penable = 0;
            @(posedge pclk);
            penable  = 1;
            @(posedge pclk);
            psel = 0;
            penable = 0;
            end 
            
 //////////////////////// invalid address values
  
            @(posedge pclk);
            pwrite = 1;
            paddr = 4'bxx00;
            pwdata = $urandom;
            psel = 1;
            penable = 0;
            @(posedge pclk);
            penable  = 1;
            @(posedge pclk);
            psel = 0;
            penable = 0;
  
 //////////////////////// invalid data values
            @(posedge pclk);
            pwrite = 1;
            paddr = 2;
            pwdata = 4'b011x;
            psel = 1;
            penable = 0;
            @(posedge pclk);
            penable  = 1;
            @(posedge pclk);
            psel = 0;
            penable = 0;
            
            

            
                               
            
end

initial 
begin
#5000;
$finish;
end
endmodule
