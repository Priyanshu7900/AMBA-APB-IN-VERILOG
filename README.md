# AMBA-APB-IN-VERILOG

## About
This repository contains several **AMBA APB (Advanced Peripheral Bus)** example designs and corresponding testbenches implemented in **Verilog**.  
It is intended as a hands-on learning and demonstration repository for APB master/slave interactions, common peripheral cores (registers, GPIO, UART, FIFO), and APB bus behaviors (wait states, error response, multiple slaves).

The repository includes source modules, testbenches, and simulation result PDFs showing waveform screenshots and test outcomes.

---

## Features
- APB **master and slave** top-level examples (single and multiple slaves)  
- APB peripheral cores:
  - **Register read/write core**  
  - **GPIO core**  
  - **UART core**  
  - **FIFO core**  
- Bus-level behaviors:
  - **Wait states** from slaves  
  - **Slave error response** handling  
- Directed testbenches for verifying functionality  
- Simulation results (PDFs) containing waveform captures and summaries  

---

## Repository Structure
```
AMBA-APB-IN-VERILOG/
│
├── APB2_MASTER_SLAVE_TOP.v
├── APB2_MASTER_SLAVE_TOP_TB.v
├── APB2_MASTER_SLAVE_WITH_WAIT_STATE_TOP.v
├── APB2_MASTER_SLAVE_WITH_WAIT_STATE_TOP_TB.v
├── APB2_WITH_MULTIPLE_SLAVE.v
├── APB2_WITH_MULTIPLE_SLAVE_TB.v
├── APB_CORE_REGISTER_TOP.v
├── APB_CORE_REGISTER_TOP_TB.v
├── APB_CORE_GPIO.v
├── APB_CORE_GPIO_TB.v
├── APB_CORE_UART.v
├── APB_CORE_UART_TB.v
├── APB_CORE_FIFO.v
├── APB_CORE_FIFO_TB.v
├── APB_WITH_SLAVE_ERROR.v
├── APB_WITH_SLAVE_ERROR_TB.v
├── *_RESULTS.pdf         # Simulation results / waveforms
└── README.md
```

---

## Quick Guide — Which File Does What
- **APB2_MASTER_SLAVE_TOP.v** – Master connected to a single slave (basic APB flow).  
- **APB2_MASTER_SLAVE_WITH_WAIT_STATE_TOP.v** – Demonstrates slave-inserted wait states.  
- **APB2_WITH_MULTIPLE_SLAVE.v** – Master accessing multiple slaves via decoding.  
- **APB_CORE_REGISTER_TOP.v** – Register-based peripheral (read/write registers).  
- **APB_CORE_GPIO.v** – APB-connected GPIO peripheral.  
- **APB_CORE_UART.v** – UART peripheral interfaced with APB.  
- **APB_CORE_FIFO.v** – FIFO core accessible via APB.  
- **APB_WITH_SLAVE_ERROR.v** – Demonstrates error response signaling.  
- **\*_TB.v** – Testbenches for each design.  
- **\*_RESULTS.pdf** – Waveform screenshots and summaries.  

---

## Running Simulations (ModelSim / Questa)
Example flow:

```bash
# Create work library
vlib work
vmap work work

# Compile sources and TB (example for register core)
vlog APB_CORE_REGISTER_TOP.v APB_CORE_REGISTER_TOP_TB.v

# Run simulation (console mode)
vsim -c APB_CORE_REGISTER_TOP_TB -do "run -all; quit"
```

Other examples (replace DUT/TB names accordingly):
```bash
vlog APB_CORE_UART.v APB_CORE_UART_TB.v
vsim -c APB_CORE_UART_TB -do "run -all; quit"

vlog APB_CORE_GPIO.v APB_CORE_GPIO_TB.v
vsim -c APB_CORE_GPIO_TB -do "run -all; quit"

vlog APB2_MASTER_SLAVE_TOP.v APB2_MASTER_SLAVE_TOP_TB.v
vsim -c APB2_MASTER_SLAVE_TOP_TB -do "run -all; quit"
```

Run without `-c` for GUI waveform viewing:
```bash
vsim APB_CORE_REGISTER_TOP_TB
run -all
```

---

## Running on EDA Playground
1. Open [EDA Playground](https://www.edaplayground.com/)  
2. Set language to **Verilog** (or SystemVerilog if needed)  
3. Paste DUT and TB files into the editor panes  
4. Select simulator (ModelSim/Questa recommended)  
5. Run simulation and open waveform viewer  

---

## Debugging Tips
- Key APB signals to check in waveforms:  
  - **PSEL, PENABLE, PWRITE, PADDR, PWDATA, PRDATA, PREADY, PSLVERR**  
- **Transaction Phases**:  
  - **Setup**: PSEL=1, PENABLE=0, valid address/data  
  - **Enable**: PENABLE=1, transfer completes when PREADY=1  
- For wait states, ensure **PREADY** remains low and stable signals are held.  

---

## How to Extend
- Add new APB-compliant peripherals (use standard bus signals).  
- Expand testbenches with more stimulus and protocol checks.  
- Convert to **UVM-based verification** for constrained-random and coverage-driven verification.  

---

## Useful References
- ## Useful References
- [AMBA APB Protocol Specification (ARM IHI 0024E, 2023)](https://developer.arm.com/documentation/ihi0024/e)  
- [Arm Developer Documentation](https://developer.arm.com/documentation)  
  
---

## Notes
- The designs here are **for learning and simulation purposes**, not production-grade IP.  
- Simulation results are pre-captured in the `*_RESULTS.pdf` files.  

---

## Author
Repository owner: **Priyanshu7900**  

---
---

## Author
Repository owner: **Priyanshu7900**  

---
