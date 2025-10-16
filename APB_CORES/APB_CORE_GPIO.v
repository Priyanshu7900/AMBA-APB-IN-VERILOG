module apb_gpio(
    input                  pclk,
    input                  presetn, //Active Low Reset

    input                  psel,
    input                  penable,
    input        [1:0]     paddr,
    input                  pwrite, // 1-> writing to slave 0 -> reading from slave
    input        [7:0]     pwdata,
    output reg   [7:0]     prdata, //data read from slave
    output                 pready, //from slave    
    input        [7:0]     gpio_in,
    output reg   [7:0]     gpio_out,
    output reg   [7:0]     gpio_oe 
);
/*
0 - DIR_REG : defines direction of each pin (1- o/p, 0 - i/p)
1 - MODE_REG : configuration of buffer 1 - push pull, 0 - open drain
2 - WRITE_REG : actual value written on pin during o/p operation
3 - READ_REG : value read from outside world during i/p operation
*/

////// dir = 0, mode = 1, write = 2, read = 3 
reg [7:0] dir_reg = 0, read_reg = 0, write_reg = 0, mode_reg = 0;

localparam push_pull  = 1;
localparam open_drain = 0;
/////////////////// read data from gpio in on each positive edge of pclk



///////// update direction and write reg as per requirements on valid apb transaction
//direction reg addr = 0 //setup direction for each pin 1 = output 0 = input
//write reg   = 0 /// data to be written on output ports
  always @(posedge pclk,negedge presetn)
  begin
  if(psel == 1'b1 && penable == 1'b1 && pwrite == 1'b1)
  begin
    if(presetn == 1'b0)
    begin
        dir_reg   <= 8'h00; 
        write_reg <= 8'h00;
        mode_reg  <= 8'h00; 
    end
    else if(paddr == 2'b00) /// update dir reg if paddr = 0
      begin
        dir_reg   <= pwdata; 
      end 
    else if(paddr == 2'b01) /// update dir reg if paddr = 0
      begin
        mode_reg  <= pwdata; 
      end
    else if(paddr == 2'b10)
      begin
        write_reg <= pwdata;
      end
    end
  end 
 
 ////////////////reading register 
 
  always @(posedge pclk,negedge presetn)
  begin
    if(presetn == 1'b0)
    begin
        prdata    <= 8'h00;
    end
    else if(psel == 1'b1 && penable == 1'b1 && pwrite == 1'b0)
    begin
        case(paddr)
        2'b00: prdata <= dir_reg;
        2'b01: prdata <= mode_reg;
        2'b10: prdata <= write_reg;
        2'b11: prdata <= read_reg;
        default : prdata <= 8'h00;
        endcase
    end
  end 

 
  
  //////////////// input mode
   always@(posedge pclk)
   begin
   read_reg <= gpio_in;
   end
  
  
 /// push pull always enable transmitter, open drain disable transmitter to get 1 
  always@(posedge pclk)
  begin
    for(int i = 0 ; i <= 7; i++)
    begin
        gpio_oe[i] <= dir_reg[i] & ((mode_reg[i] == push_pull) ? 1'b1 : ~write_reg[i]);
    end
  end
  
  //////////////gpio_output
  always@(posedge pclk)
  begin
    for(int i = 0 ; i <= 7; i++)
    begin
        gpio_out[i] <= (mode_reg[i] == push_pull)? write_reg[i] : 1'b0;
    end
  end
  

/// no wait access for all transfer
assign pready_o = 1'b1;



endmodule
