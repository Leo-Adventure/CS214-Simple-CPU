-makelib ies_lib/xil_defaultlib -sv \
  "D:/Applications/Vivado/Vivado/2017.4/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "D:/Applications/Vivado/Vivado/2017.4/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies_lib/xpm \
  "D:/Applications/Vivado/Vivado/2017.4/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../CPU.srcs/sources_1/ip/uart_1/uart_bmpg.v" \
  "../../../../CPU.srcs/sources_1/ip/uart_1/upg.v" \
  "../../../../CPU.srcs/sources_1/ip/uart_1/sim/uart.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

