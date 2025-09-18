class transaction;
  randc bit [7:0] a;
  randc bit [7:0] b;
  bit [8:0] sum;
  
   // Constraint to limit values between 1 and 10
  constraint value_range {
    a inside {[1:4]};
    b inside {[1:4]};
  }
  
  // Optional: Constraint to prevent overflow (sum <= 20)
  constraint no_overflow {
    (a + b) <= 20;
  }
endclass

/////////////////////////////////////////////////////////////////////  

class generator;
  mailbox #(transaction) mbx;
  event done;
  transaction t;
  integer i;

  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction

  task main();
    t = new();
    for(i = 0; i < 10; i++) begin
      void'(t.randomize());  // Fixed: capture return value
      mbx.put(t);
      $display("[GEN] : Data send to Driver a:%0d and b:%0d", t.a, t.b);
      @(done);  // Wait for driver to complete
    end
  endtask
endclass

////////////////////////////////////////////////////////////////////////////

class driver;
  mailbox #(transaction) mbx;
  transaction t;
  event done;
  virtual add_intf vif;

  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction

  task main();
    forever begin
      mbx.get(t);
      vif.a <= t.a;
      vif.b <= t.b;
      $display("[DRV] : Interface triggered with a:%0d and b:%0d", t.a, t.b);
      repeat(2)@(posedge vif.clk);
      -> done;  // Signal generator to continue
    end
  endtask
endclass

///////////////////////////////////////////////////////////////////////////
class monitor;
  virtual add_intf vif;
  mailbox #(transaction) mbx;
  transaction t;
 
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
    t = new();
  endfunction

  task main();
    forever begin
      repeat(2) @(posedge vif.clk);
      t.a = vif.a;
      t.b = vif.b;
      t.sum = vif.sum;
      mbx.put(t);
      $display("[MON] : Data send to Scoreboard a: %0d, b:%0d and sum:%0d", vif.a, vif.b, vif.sum);
    end
  endtask
endclass

//////////////////////////////////////////////////////////////////////////
  
class scoreboard;
  mailbox #(transaction) mbx;
  transaction t;
  bit [8:0] temp;

  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction

  task main();
    forever begin
      mbx.get(t);
      if(t.sum == t.a + t.b)
        $display("[SCO] : Test Passed for a=%0d, b=%0d, sum=%0d", t.a, t.b, t.sum);
      else
        $display("[SCO] : Test Failed for a=%0d, b=%0d, expected=%0d, got=%0d", 
                 t.a, t.b, (t.a + t.b), t.sum);
    end
  endtask
endclass

////////////////////////////////////////////////////////////////////////////
class environment;
  generator gen;
  driver drv;
  monitor mon;
  scoreboard sco;

  mailbox #(transaction) gdmbx, msmbx;
  virtual add_intf vif;
  event gddone;

  function new();
    gdmbx = new();
    msmbx = new();
    gen = new(gdmbx);
    drv = new(gdmbx);
    mon = new(msmbx);
    sco = new(msmbx);
  endfunction

  task main();
    drv.vif = vif;
    mon.vif = vif;
    
    gen.done = gddone;
    drv.done = gddone;

    fork
      gen.main();
      drv.main();
      mon.main();
      sco.main();
    join_any
  endtask
endclass

////////////////////////////////////////////////////////////////////////  
  
module tb();
  environment e;
  mailbox #(transaction) gdmbx, msmbx;
  add_intf vif();
  
  add dut (vif.a, vif.b, vif.clk, vif.resetn, vif.sum);  // Add resetn
 
  bind add sum_assert dut2 (vif.a, vif.b, vif.clk,vif.resetn, vif.sum);

  initial begin
    vif.clk = 0;
    vif.resetn = 0;  // Assert reset

    
    e = new();
    e.vif = vif;  // Assign virtual interface before calling main
  
    // Deassert reset after some clocks
    repeat(3) @(negedge vif.clk);  // Wait for 2 falling edges
    vif.resetn = 1;  // Deassert reset
    #10;
    e.main();
  end
  
  always #5 vif.clk = ~vif.clk;
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    #300;
    $finish;
  end
endmodule
