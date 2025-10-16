module apb_uart (
    input  wire                   rx,
    output reg                    tx,
    input  wire                   rst,        // Reset input
    input  wire                   pclk,       // APB clock input
    input  wire                   presetn,    // APB reset input
    input  wire                   psel,       // APB select input
    input  wire [31:0]            paddr,      // APB address input
    input  wire [7:0]             pwdata,     // APB write data input
    input  wire                   penable,    // APB enable input
    input  wire                   pwrite,     // APB write enable input
    output reg  [7:0]             prdata,     // APB read data output
    output reg                    pready,      // APB read data ready output
    output reg                    pwakeup
);


parameter idle = 0, check_op = 1, write_data = 2, read_data =3,send_ready = 4, send_start = 5, transfer = 6, send_wakeup = 7;
reg [2:0] state = idle;
reg [7:0] wdata;
reg [7:0] rxdata;
reg [3:0] bitcnt = 0;

// APB FIFO control logic
always @(posedge pclk or negedge rst) begin
    if (rst == 0) begin
        pready  <= 0;
        state   <= idle;
        prdata  <= 0;
        wdata   <= 0;
        pwakeup <= 1'b0; 
    end else begin

        case(state)
        
        idle:
        begin
            pready <= 0;
            prdata <= 0;
            wdata  <= 0;
            state <= send_wakeup;
            pwakeup <= 1'b0;
            bitcnt  <= 0;
            /////// add logic or delay to come out of sleep
        end
        
        send_wakeup:begin
         pwakeup <= 1'b1;
         state   <= check_op;
        end
        
        check_op:
        begin
         if (penable && psel && pwrite)
         begin 
            state   <= send_start;
            wdata   <= pwdata;
         end
         else if (penable && psel && !pwrite)
         begin
            if(rx == 1'b0)  // start of reception
            state  <= read_data;
            else
            state  <= check_op;
         end
         else 
            state  <= idle;
        end
        
        send_start: begin
            tx      <= 1'b0; //start of tx
            state   <= transfer; 
            bitcnt  <= 0;
        end
        
        transfer: 
        begin
        if(bitcnt <= 7) begin
           bitcnt <= bitcnt + 1;
           tx     <= wdata[bitcnt];
           state  <= transfer;
        end
        else 
        begin
           bitcnt <= 0;
           tx     <= 1'b1; // stop bit
           pready <= 1'b1;
           state  <= send_ready;
        end 
        end
        
        read_data: 
         begin
         if(bitcnt <= 7)
         begin
         state  <= read_data;
         bitcnt <= bitcnt + 1;
         rxdata <= {rx, rxdata[7:1]};
         end
         else
         begin
         bitcnt <= 0;
         pready <= 1'b1;
         prdata <= rxdata;
         state  <= send_ready;
         end
         end
         
        send_ready: 
        begin
           state  <= idle;
           pready <= 1'b0;
           pwakeup <= 1'b0;    
         end
     
     endcase
     
     end
        
   end  
   
   
   endmodule
