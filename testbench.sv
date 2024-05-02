//----------------------------------------------------------------
//
//        APB PROTOCOL TESTBENCH FILE - SYSTEM VERILOG
//        File Name : testbench.sv
//
//----------------------------------------------------------------

module tb;
  //input configration 
  reg pclk;
  reg prst;
  reg [31:0]paddr;

  reg pselx;
  reg penable;
  reg pwrite;
  reg [31:0]pwdata;

  //output configration
  wire  pready;
  wire  pslverr;
  wire [31:0]prdata;

  //intantiation of all port
  AMBA_APB  apb_dut1(pclk,prst,paddr,pselx,penable,pwrite,pwdata,pready,pslverr,prdata);

  always #5 pclk=~pclk;

  //Init task
  task init;
    begin
      pclk=0;
      prst=0;
      paddr=0;
      pselx=0;
      penable=0;
      pwrite=0;
      pwdata=23;
    end
  endtask

  //Reset Task
  task reset;
    begin
      prst=1;
      #10
      prst=0;
    end
  endtask

  //Task Write Stimulus
  task write_data;
    begin
      @(posedge pclk);
      pselx=1;
      pwrite=1;
      penable=0;
      pwdata=pwdata+1;
      paddr=paddr+1;

      @(posedge pclk);
      penable=1;
      pselx=1;

      @(posedge pclk);
      penable=0;
      pselx=0;

      @(posedge pclk);
      $strobe ("Writing data into memory address(pwaddr) = %0d data_in(pwdata) = %0d" , paddr,pwdata);
    end
  endtask

  //Task Read Stimulus  
  task read_data;
    begin
      @(posedge pclk);
      pwrite=0;
      pselx=1;
      penable=0;

      @(posedge pclk);
      penable=1;
      pselx=1;
      paddr<=paddr+1;

      @(posedge pclk);
      penable=0;
      pselx=0;

      @(posedge pclk);
      $strobe("Reading data from memory address(paddr) = %0d data_out(prdata) = %0d",paddr,prdata);
    end
  endtask

  //Task Read Write 
  task read_write;
  begin
    $display("Writing Operation");
    repeat(5)
    begin
      write_data;
    end
    #1
    paddr=0;
    $display("Read Operation");
    repeat(4)
    begin
      read_data;
    end
  end
  endtask

  initial
  begin
    $dumpfile("dump.vcd");
    $dumpvars;
    init;               //Initialize input values
    reset;              //Generate Reset signal
    read_write;         //Read and write Operation
    #100;
  end
endmodule



