`timescale 1ns/1ps

module apb_m_top
  (
    input pclk,
    input presetn,
    input [1:0] slv_addr_in, /// 01 - slave1 , 10 - slave2
    input [3:0] addrin,
    input [7:0] datain,
    input wr,
    input newd,
    input [7:0] prdata,
    input pready,
    
    output reg psel1,psel2,
    output reg penable,
    output reg slverr,
    output reg [3:0] paddr,
    output reg [7:0] pwdata,
    output reg pwrite,
    output [7:0] dataout
    
  
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
              psel1 <= 1'b0;
              psel2 <= 1'b0;
            end
         else if (nstate == idle)
            begin
              psel1 <= 1'b0;
              psel2 <= 1'b0;
            end
         else if (nstate == enable || nstate == setup)
            begin
             if(slv_addr_in == 2'b01)
             begin
                psel1 <= 1'b1;
                psel2 <= 1'b0;
             end
             else if (slv_addr_in == 2'b10)
             begin
               psel1 <= 1'b0;
               psel2 <= 1'b1;
             end
            else 
             begin
               psel1 <= 1'b0;
               psel2 <= 1'b0;
             end
           end
         else 
            begin
              psel1 <= 1'b0;
              psel2 <= 1'b0;
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
 
assign dataout = ((psel1 == 1'b1 || psel2 == 1'b1) && penable == 1'b1 && wr == 1'b0) ? prdata : 8'h00; 
endmodule

module apb_s_top
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
    output     pslverr
);

  localparam [1:0] idle = 0, write = 1, read = 2;
  reg [7:0] mem[16];
  
  reg [1:0] state, nstate;
  
  bit  addr_err , addv_err, data_err, setup_apb_err;
  ////////// setup - correct apb cycles
  /////////  addr_range - should be less than 16
  /////////   addr_val - be greater than or equal to 0
  /////////   data_val - be greater than or equal to 0  
/*
Transactions that receive an error, might or might not have changed the state of the peripheral. 
This is peripheral-specific and either is acceptable. 
When a write transaction receives an error this does not mean that the register within the peripheral 
has not been updated. Read transactions that receive an error can return invalid data.
 There is no requirement for the peripheral to drive the data bus to all 0s for a read error.
*/
  ///// reset decoder
  always@(posedge pclk, negedge presetn)
    begin
      if(presetn == 1'b0)
          state <= idle;
      else
          state <= nstate;
    end
    
    ///next state , output decoder
  always@(*)
    begin
    case(state)
     idle:
     begin
        prdata    = 8'h00;
        pready    = 1'b0;
        
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
                 if(!addr_err && !addv_err && !data_err )
                    begin
                    pready = 1'b1;
                    mem[paddr]  = pwdata;
                    nstate      = idle;
                    end
                else
                     begin
                     nstate = idle;
                     pready = 1'b1;
                     end     
                 
     
        end
    end
     
    read:
     begin
        if(psel == 1'b1 && penable == 1'b1 )
        begin
            if(!addr_err && !addv_err && !data_err )
                 begin
                 pready = 1'b1;
                 prdata = mem[paddr];
                 nstate      = idle;
                 end
            else
                begin
                pready = 1'b1;
                prdata = 8'h00;
                nstate      = idle;
                end
        end
    end
     
    default : 
    begin
        nstate = idle; 
        prdata    = 8'h00;
        pready    = 1'b0;
     end
    endcase
    end

///////////////// checking valid values of address
reg av_t = 0;
always@(*)
begin
if(paddr >= 0)
  av_t = 1'b0;
else
  av_t = 1'b1;
end

///////////////// checking valid values of address
reg dv_t = 0;
always@(*)
begin
if(pwdata >= 0)
  dv_t = 1'b0;
else
  dv_t = 1'b1;
end


assign addr_err = ((nstate == write || read) && (paddr > 15)) ? 1'b1 : 1'b0;
assign addv_err = (nstate == write || read) ? av_t : 1'b0;
assign data_err = (nstate == write || read) ? dv_t : 1'b0;

assign pslverr  = (psel == 1'b1 && penable == 1'b1) ? ( addv_err || addr_err || data_err) : 1'b0;

endmodule
//////////////////////////////////


module mul_slave
(
    input pclk,
    input presetn,
    input [1:0] slv_addr_in, /// 01 - slave1 , 10 - slave2
    input [3:0] addrin,
    input [7:0] datain,
    input wr,
    input newd,
    
    output reg slverr_o,
    output reg [7:0] dataout

);

wire psel1, psel2;
wire [7:0] prdata1, prdata2;
wire [7:0] prdata;
wire pready1,pready2;
wire pslverr1, pslverr2;
wire pready,pslverr;
wire pwrite;
wire [3:0] paddr;
wire [7:0] pwdata;

apb_m_top m1 (
        .pclk(pclk),
        .presetn(presetn),
        .slv_addr_in(slv_addr_in),
        .addrin(addrin),
        .datain(datain),
        .wr(wr),
        .newd(newd),
        .prdata(prdata),
        .pready(pready),
        .psel1(psel1),
        .psel2(psel2),
        .penable(penable),
        .slverr(slverr),
        .paddr(paddr),
        .pwdata(pwdata),
        .pwrite(pwrite),
        .dataout(dataout)
    );
    
   apb_s_top s1 (
        .pclk(pclk),
        .presetn(presetn),
        .paddr(paddr),
        .psel(psel1),
        .penable(penable),
        .pwdata(pwdata),
        .pwrite(pwrite),
        .prdata(prdata1),
        .pready(pready1),
        .pslverr(pslverr1)
    );
    
    
    apb_s_top s2 (
        .pclk(pclk),
        .presetn(presetn),
        .paddr(paddr),
        .psel(psel2),
        .penable(penable),
        .pwdata(pwdata),
        .pwrite(pwrite),
        .prdata(prdata2),
        .pready(pready2),
        .pslverr(pslverr2)
    ); 

assign  prdata = (psel1 == 1'b1) ? prdata1 : ((psel2 == 1'b1) ? prdata2 : 8'h00) ;    
assign  pready = (psel1 == 1'b1) ? pready1 : ((psel2 == 1'b1) ? pready2 : 1'b0) ;    
assign  pslverr = (psel1 == 1'b1) ? pslverr1 : ((psel2 == 1'b1) ? pslverr2 : 1'b0) ;    
assign  slverr_o = pslverr;

endmodule
