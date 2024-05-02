//--------------------------------------------------------------------
//
//       APB PROTOCOL DESIGN - VERILOG CODE
//       File Name : apb_design.v
//
//--------------------------------------------------------------------

module AMBA_APB(pclk,prst,paddr,pselx,penable,pwrite,pwdata,pready,pslverr,prdata);
  //input configration 
  input pclk;
  input prst;
  input [31:0]paddr;

  input pselx;
  input penable;
  input pwrite;
  input [31:0]pwdata;

  //output configration
  output reg pready;
  output reg  pslverr;
  output reg [31:0]prdata;

  //memory decleration
  reg [31:0]mem[31:0];

  //state declaration communication
  parameter [1:0] idle=2'b00;
  parameter [1:0] setup=2'b01;
  parameter [1:0] access=2'b10;

  //state declaration of present and next 
  reg [1:0] present_state,next_state;

  always @(posedge pclk)
  begin
    if(prst) present_state <= idle;
    else
      present_state <= next_state;
  end


  always @(*)
  begin
  case (present_state)

    idle:begin
      if (pselx & !penable)
        next_state = setup;
      pready=0;
    end

    setup:begin
      if (!penable | !pselx)
        next_state = idle;
        else
        begin
          next_state =access;
          if(pwrite ==1)
          begin
            mem[paddr]= pwdata;
            pready=1;
            pslverr=0;
          end
          else
          begin
            prdata=mem[paddr];
            pready=1;
            pslverr=0;
          end
       end
    end

    access :begin
      if(pwrite ==1)
      begin
        mem[paddr]= pwdata;
        pready=1;
        pslverr=0;
      end
      else
      begin
        prdata=mem[paddr];
        pready=1;
        pslverr=0;
      end

      if(!penable | !pselx)
      begin
        next_state = idle;
        pready =0;
      end
      else if(!pready )
        next_state = access;
      else if (pready & !pslverr)
        next_state = setup;
      else
        next_state = idle;
    end
  endcase
  end
endmodule
              
