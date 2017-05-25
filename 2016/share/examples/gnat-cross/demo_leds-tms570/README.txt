This example is for the Hercules XL2-570LC43 (A) Launchpad based on
 TMS570LC4357 MCU from Texas Instruments.



It blinks the 2 green User LEDs located on the right side of the central MCU chip.



Note that this demo is set up for "Revision A1" of the board, so there are only 2 User LEDs.



Note that debugging the application requires a JTAG debug interface,
 such as one of the JLINK devices.  
Configuration of a JTAG 
debugger interface is device-specific so is outside the scope of this
README, but note that once set up, debugging via GDB is like any other
remote target. In that case full debugging is available via the GPS
 debugger GUI interface.


