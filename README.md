# usbTim
This is just a base implementation for a USB peripheral. I am increasingly needing more speed than I can get from asynchronous serial (UART). This is mostly derived from avakar/usbcorev. I'm currently working with an Orangecrab. I am anticipating more part shortages so I am reluctant to get in bed with say Xilinx (vis-a-vis proprietary IP) as China implodes.

I am also doing a silly experiment. Since the open source tools are so fast, I am experimenting with skipping simulation (gasp!!!) and doing my "simulation" in HW with a logic analyzer.
<br><p>
# Terminal output from FPGA 
  Bright text means a wire is active, dim means inactive, there is also some hex data too.  
![Terminal output from FPGA](doc/uartAnnunciator.jpg)
