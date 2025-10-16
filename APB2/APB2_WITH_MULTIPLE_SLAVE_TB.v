module tb_mul_slave;
    // Define testbench ports
    reg pclk = 0;
    reg presetn;
    reg [1:0] slv_addr_in;
    reg [3:0] addrin;
    reg [7:0] datain;
    reg wr;
    reg newd;
    wire slverr_o;
    wire [7:0] dataout;
    
    // Instantiate the mul_slave module
    mul_slave dut (
        .pclk(pclk),
        .presetn(presetn),
        .slv_addr_in(slv_addr_in),
        .addrin(addrin),
        .datain(datain),
        .wr(wr),
        .newd(newd),
        .slverr_o(slverr_o),
        .dataout(dataout)
    );
    
    always #10 pclk = ~pclk;
    
    initial begin
    presetn = 0;
    repeat(5) @(posedge pclk);
    presetn = 1;
    
    //// 10 transaction to slave 1
    for (int i = 1; i<10; i++)
    begin
    slv_addr_in = 1;
    newd = 1;
    addrin = i;
    datain = 5*i;
    wr = 1;
    repeat(2)@(posedge pclk);
    newd = 1'b0;
    end
    
    /// 10 transaction to slave 2
    for (int i = 1; i<10; i++)
    begin
    slv_addr_in = 2;
    newd = 1;
    addrin = i;
    datain = 10*i;
    wr = 1;
    repeat(2)@(posedge pclk);
    newd = 1'b0;
    end
    
        //// 10 read transaction to slave 1
    for (int i = 1; i<10; i++)
    begin
    slv_addr_in = 1;
    newd = 1;
    addrin = i;
    datain = 0;
    wr = 0;
    repeat(2)@(posedge pclk);
    newd = 1'b0;
    end
    
    $stop;
    
    end

    
    
    
    
    endmodule
