//// APB Master
////////////////
module apb_m
  (
    input pclk,
    input presetn,
    input [3:0] addrin,
    input [7:0] datain,
    input wr,
    input newd,
    input [7:0] prdata,
    input pready,
    
    output reg psel,
    output reg penable,
    output reg [3:0] paddr,
    output reg [7:0] pwdata,
    output reg pwrite,
    output reg [7:0] dataout
    
  
  );
  
  localparam [1:0] idle = 0, setup = 1, enable = 2;
  
  
  reg [1:0] state, nstate;
  
  //////reset decoder
  
  always@(posedge pclk)
    begin
      if(presetn == 1'b0)
          state <= idle;
      else
          state <= nstate;
    end
  
  //////state decoder
  
  always@(*)
    begin
      case(state)
        idle:
          begin
          if (newd == 1'b0)
             nstate = idle;
          else
             nstate = setup;
          end
        
        setup:
          begin
           nstate = enable; 
          end
        
        enable:
          begin
            if(newd == 1'b1 )
               begin
                 if(pready == 1'b1)
                    nstate = setup;
                 else
                    nstate = enable;
               end
           else
               begin
                 nstate = idle;
               end
            
          end
        
        default : nstate = idle; 
      endcase
      
    end

////////////////address decoding
always@(posedge pclk, negedge presetn)
    begin
        if(presetn == 1'b0)
            begin
              psel <= 1'b0;
            end
         else if (nstate == idle)
            begin
              psel <= 1'b0;
            end
         else if (nstate == enable || nstate == setup)
            begin
             psel <= 1'b1;
            end
         else 
            begin
             psel <= 1'b0;
            end     
    end
 
 
 /////////////// output logic
 always@(posedge pclk, negedge presetn)
     begin
        if(presetn == 1'b0)
          begin
          penable <= 1'b0;
          paddr   <= 4'h0;
          pwdata  <= 8'h00;
          pwrite  <= 1'b0;
          end
        else if (nstate == idle)
          begin
          penable <= 1'b0;
          paddr   <= 4'h0;
          pwdata  <= 8'h00;
          pwrite  <= 1'b0;
          end
        else if (nstate == setup)
          begin
            penable <= 1'b0;
            paddr   <= addrin;
            pwrite  <= wr;
            if(wr == 1'b1)
                begin
                pwdata <= datain;
                end
             end
        else if (nstate == enable)
            begin
                penable <= 1'b1;
            end
     end
 
 assign dataout = (psel == 1'b1 && penable == 1'b1 && wr == 1'b0) ? prdata : 8'h00;
 
endmodule

//////////////////////////////////////////////////////////////////
////////////////APB Slave

`timescale 1ns/1ps

module apb_s
(
    input  pclk,
    input  presetn,
    input [3:0] paddr,
    input psel,
    input penable,
    input [7:0] pwdata,
    input pwrite,
    
    output reg [7:0] prdata,
    output reg pready,
    output reg pslverr,
    input s_wait
);

  localparam [1:0] idle = 0, write = 1, read = 2;
  reg [7:0] mem[16];
  
  reg [1:0] state, nstate;
  
  //////reset decoder
  
  always@(posedge pclk)
    begin
      if(presetn == 1'b0)
          state <= idle;
      else
          state <= nstate;
    end
    
  always@(*)
    begin
    case(state)
     idle:
     begin
        prdata = 8'h00;
        pready = 1'b0;
            if(psel == 1'b1 && pwrite == 1'b1)  
                nstate = write;
            else if (psel == 1'b1 && pwrite == 1'b0)
                nstate = read;
            else
                nstate = idle;      
     end
     
     write:
     begin
        if(psel == 1'b1 && penable == 1'b1)
            begin
                if(s_wait == 1'b1)
                 begin
                 nstate = write; 
                 end
                 else
                 begin
                 pready = 1'b1;
                 mem[paddr]  = pwdata;
                 nstate      = idle;
                 end
             end
        else
            begin
            nstate      = idle;
            end
     
     end
     
    read:
     begin
        if(psel == 1'b1 && penable == 1'b1 )
            begin
            if(s_wait == 1'b1)
                 begin
                 nstate = read; 
                 end
                 else
                 begin
                 pready = 1'b1;
                 prdata = mem[paddr];
                 nstate      = idle;
                end
              end
        else
            begin
            nstate      = idle;
            end
     
     end
     
    default : nstate = idle; 
     
    endcase
    end

endmodule

///////////////////////////////////////////////////////


`timescale 1ns/1ps

module top(
input clk,rstn,wr,newd,s_wait,
input [3:0] ain,
input [7:0] din,
output [7:0] dout
);

wire psel, penable, pready, pwrite;
wire [7:0] prdata, pwdata;
wire [3:0] paddr;
 

apb_m m1 (
        .pclk(clk),
        .presetn(rstn),
        .addrin(ain),
        .datain(din),
        .wr(wr),
        .newd(newd),
        .prdata(prdata),
        .pready(pready),
        .psel(psel),
        .penable(penable),
        .paddr(paddr),
        .pwdata(pwdata),
        .pwrite(pwrite),
        .dataout(dout)
    );



    apb_s s1 (
        .pclk(clk),
        .presetn(rstn),
        .paddr(paddr),
        .psel(psel),
        .penable(penable),
        .pwdata(pwdata),
        .pwrite(pwrite),
        .prdata(prdata),
        .pready(pready),
        .s_wait(s_wait)
    );
    
    

endmodule


