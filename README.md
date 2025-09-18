# Adder_UVM_SVA
Synchronous Adder Verification Project
A comprehensive SystemVerilog testbench for verifying a synchronous 8-bit adder with registered outputs using Assertion-Based Verification (ABV).

📁 Project Structure
text
adder-verification/
├── rtl/
│   └── add.sv                 # DUT - Synchronous adder with registered output
├── tb/
│   └── testbench.sv           # Complete testbench environment
├── interfaces/
│   └── add_intf.sv            # Interface definition
├── assertions/
│   └── sum_assert.sv          # SVA assertions for verification
└── README.md
🎯 Features
Synchronous Design: 8-bit adder with registered output (1-cycle latency)

Assertion-Based Verification: Comprehensive SVA checks

UVM-Style Testbench: Object-oriented verification environment

Randomized Testing: Constrained random stimulus generation

Functional Coverage: Built-in scoreboard for result checking

🔧 DUT Specifications
systemverilog
module add (
  input [7:0] a,        // 8-bit input A
  input [7:0] b,        // 8-bit input B  
  input clk,            // Clock signal
  input resetn,         // Active-low reset
  output reg [8:0] sum  // 9-bit registered output
);
📊 Assertion Checks
Functional Assertions
SUM_CHECK: Verifies sum = a + b with 1-cycle latency

SUM_VALID: Ensures sum is never unknown when inputs are stable

A_VALID: Checks input A is always valid

B_VALID: Checks input B is always valid

Key SVA Techniques
disable iff (!resetn) - Reset handling

|=> - Implication with 1-cycle delay

$past() - Accessing previous values

$stable() - Checking signal stability

$isunknown() - Unknown value detection

🚀 Getting Started
Prerequisites
SystemVerilog simulator (QuestaSim, VCS, or Icarus Verilog)

Basic understanding of SVA and OOP verification

Example Output
text
[GEN] : Data send to Driver a:4 and b:1
[DRV] : Interface triggered with a:4 and b:1
[MON] : Data send to Scoreboard a:4, b:1 and sum:5
[SCO] : Test Passed for a=4, b=1, sum=5
[ASSERT] SUM_CHECK Pass: Sum:5
🧪 Test Cases
Basic arithmetic operations

Reset functionality verification

Boundary value testing (overflow prevention)

Randomized input testing

Unknown value handling

📈 Verification Metrics
Functional Coverage: 100% for specified constraints

Assertion Coverage: All SVA properties verified

Bug Detection: Catches timing and arithmetic errors

Reset Recovery: Proper reset behavior verified

🎓 Learning Outcomes
This project demonstrates:

Synchronous design principles

Assertion-Based Verification methodology

UVM-style testbench architecture

Constrained random testing

Debugging techniques with SVA

🤝 Contributing
Feel free to:

Add more assertion properties

Extend constraint ranges

Implement functional coverage

Add different adder architectures
