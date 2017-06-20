# GNAT 2016 (Libre) for Launchpad XL2-570LC 

1. This tree contains the gnat 2016 sfp ravenscar profile ported to the Hercules TMS570LC43A MCU.
2. The code is specifically targeted to this launchpad board.
3. The Demo_Leds project is an example that has a task which toggle the two USER LEDs on the board and prints at 115200 8N1 to the Debug probe (Diagnostic port).
4. To build these projects, first go to libre.adacore.com and download the GNAT 2016 (Libre) for ARM ELF hosted on Windows or Linux.
5. Install GPS (GNAT Programming Studio) and build the sfp runtime and then the Demo_Leds project.
