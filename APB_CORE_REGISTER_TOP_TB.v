`timescale 1ns / 1ps

module testbench();
 
    reg rst = 1;            // Reset signal (active high)
    reg pclk = 0;           // APB clock signal
    reg presetn = 1;        // APB reset signal (active low)
    reg psel = 1;           // APB select signal
    reg [31:0] paddr = 2'b00;  // APB address signal
    reg [31:0] pwdata = 0;  // APB write data signal
    reg penable = 0;        // APB enable signal
    reg pwrite = 0;         // APB write enable signal
    wire [31:0] prdata;     // APB read data signal
    wire pready;            // APB read data ready signal

    // Instantiate APB FIFO
    apb_reg dut (
        .rst(rst),
        .pclk(pclk),
        .presetn(presetn),
        .psel(psel),
        .paddr(paddr),
        .pwdata(pwdata),
        .penable(penable),
        .pwrite(pwrite),
        .prdata(prdata),
        .pready(pready)
    );

    // Clock generation
    always #5 pclk =~pclk;
    // Initial stimulus
    initial begin
        // Reset
        rst = 0;
        repeat(3)  @(posedge pclk);
        rst = 1;
        
        ///////////APB Write
            @(posedge pclk);
            psel = 1;
            penable = 0;
            pwrite  = 1;
            pwdata  = $urandom_range(0,255);
            paddr   = 0;
            @(posedge pclk);
            penable = 1;
            @(posedge pclk);
            @(posedge pready);
            @(posedge pclk);

       /////////////// APB Read
        psel = 1;
        penable = 0;
        pwrite  = 0;
        pwdata  = 0;
        paddr   = 0;
        @(posedge pclk);
        penable = 1;
        @(posedge pclk);
        @(posedge pready);
        @(posedge pclk);
        
        $stop;
       
    end

endmodule
