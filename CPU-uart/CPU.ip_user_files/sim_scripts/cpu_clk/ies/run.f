-makelib ies_lib/xil_defaultlib -sv \
  "D:/Applications/Vivado/Vivado/2017.4/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "D:/Applications/Vivado/Vivado/2017.4/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies_lib/xpm \
  "D:/Applications/Vivado/Vivado/2017.4/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../CPU.srcs/sources_1/ip/cpu_clk/cpu_clk_clk_wiz.v" \
  "../../../../CPU.srcs/sources_1/ip/cpu_clk/cpu_clk.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

