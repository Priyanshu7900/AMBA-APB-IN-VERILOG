module apb_fifo (
    input  wire                   clk,        // Clock input
    input  wire                   rst,        // Reset input
    input  wire                   pclk,       // APB clock input
    input  wire                   presetn,    // APB reset input
    input  wire                   psel,       // APB select input
    input  wire [3:0]            paddr,      // APB address input
    input  wire [31:0]            pwdata,     // APB write data input
    input  wire                   penable,    // APB enable input
    input  wire                   pwrite,     // APB write enable input
    output reg  [31:0]            prdata,     // APB read data output
    output reg                    pready      // APB read data ready output
);

// Define parameters
parameter DEPTH = 16;  // Depth of the FIFO (number of entries)
parameter idle = 0, check_op = 1, write_data = 2, read_data =3,send_ready = 4;
reg [2:0] state = idle;
reg [3:0] addr ;
 reg [31:0] wdata,rdata;

// Internal FIFO memory
  reg [31:0] mem [16];
reg [3:0] wr_ptr;   // Write pointer
reg [3:0] rd_ptr;   // Read pointer
reg [4:0] count;    // Count of valid entries in FIFO
reg [1:0] cwait = 0;
// APB FIFO control logic
always @(posedge clk or negedge rst) begin
    if (rst == 0) begin
    
        for(int i = 0; i<16;i++)
        begin
        mem[i] <= 0;
        end
        
        wr_ptr <= 0;
        rd_ptr <= 0;
        count <= 0;
        pready <= 0;
        state   <= idle;
        pready <= 0;
        prdata <= 0;
        addr   <= 0;
        wdata  <= 0;
        rdata  <= 0;
        cwait  <= 0;
        
    end else begin
        // APB write operation
        case(state)
        idle:
        begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count <= 0;
            pready <= 0;
            prdata <= 0;
            addr   <= 0;
            wdata  <= 0;
            rdata  <= 0;
            cwait  <= 0;
            state <= check_op;
        end
        
        check_op:
        begin
         if (penable && psel && pwrite && count != 15)
         begin 
            state   <= write_data;
            addr    <= paddr;
            wdata   <= pwdata;
         end
         else if (penable && psel && !pwrite && count != 0)
         begin
            state  <= read_data;
            addr   <= paddr;
         end
         else 
            state  <= check_op;
        end
        
        write_data:
        begin
            mem[addr] <= wdata;
            
            if(cwait < 2)
            begin
              state <= write_data;
              cwait <= cwait + 1;
            end
            else
            begin
               cwait <= 0;
               pready <= 1'b1;
               state <= send_ready;
               wr_ptr <= wr_ptr + 1;
               count  <= count  + 1;
            end
        end
        
        read_data : begin
            rdata <= mem[addr];
            if(cwait < 2)
            begin
              state <= read_data;
              cwait <= cwait + 1;
            end
            else
            begin
               cwait <= 0;
               state <= send_ready;
               pready <= 1'b1;
               prdata <= rdata;
               rd_ptr <= rd_ptr + 1;
               count  <= count  - 1;
            end
        
        end
        
        send_ready: begin
           state  <= check_op;
           pready <= 1'b0;    
         end
     
     endcase
     
     end
        
   end  
endmodule
