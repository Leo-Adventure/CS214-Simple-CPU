@echo off
REM Generate UART download bit stream for Minisys3.0.
REM UARTCoe_v3.0.exe is used
set program=UARTCoe_v3.0.exe
set param=h
set path1=prgmip32.coe
set path0=dmem32.coe
%program% %param% %path1% %path0% out.txt
@echo on
