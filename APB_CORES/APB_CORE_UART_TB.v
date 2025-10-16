  `timescale 1ns / 1ps

///////////////////uart_tb
module uart_tb();
 
    reg rst = 1;            // Reset signal (active high)
    reg pclk = 0;           // APB clock signal
    reg presetn = 1;        // APB reset signal (active low)
    reg psel = 1;           // APB select signal
    reg [31:0] paddr = 2'b00;  // APB address signal
    reg [7:0] pwdata = 0;  // APB write data signal
    reg penable = 0;        // APB enable signal
    reg pwrite = 0;         // APB write enable signal
    wire [31:0] prdata;     // APB read data signal
    wire pready;            // APB read data ready signal
    wire tx;
    reg rx;
    // Instantiate APB FIFO
    apb_uart dut (
        .rx(rx),
        .tx(tx),
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
            rx = 1;
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
        rx = 0;
        @(posedge pclk);
        @(posedge pclk);
        for(int i = 0; i <= 8;i++)
        begin
        rx = $random;
        @(posedge pclk);
        end
        rx = 1;
        @(posedge pready);
        @(posedge pclk);
        
        $stop;
       
    end

endmodule
