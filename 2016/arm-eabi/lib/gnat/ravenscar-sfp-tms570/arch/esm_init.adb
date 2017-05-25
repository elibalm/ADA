--  ===========================================================================
--  Author:  Elizabeth Almeyda
--  Date:    12 of April 2016
--  Project: TMS570 ARM ESM Module initialization
--  Description:
--           This file provides the ESM Initialization for the TMS570
--           (ARM Cortex R5) microcontrollers from Texas Instruments.
--  ===========================================================================

pragma Ada_2012;
pragma Restrictions (No_Elaboration_Code);

-------------------------------------------------------------------------------

with System;               use System;
with System.TMS570;        use System.TMS570;

-------------------------------------------------------------------------------
procedure esm_init is
   ----------------------------------------------------------------------------

   ----------------------------------------------------------------------------
   --  Configure system response to error conditions signaled to the ESM group1
   ----------------------------------------------------------------------------
begin
      --  Disable error pin channels
      ESM.DEPAPR1 := 16#FFFF_FFFF#;
      ESM.IEPCR4  := 16#FFFF_FFFF#;
      ESM.IEPCR7  := 16#FFFF_FFFF#;

      --  Disable interrupts
      ESM.IECR1   := 16#FFFF_FFFF#;
      ESM.IECR4   := 16#FFFF_FFFF#;
      ESM.IECR7   := 16#FFFF_FFFF#;

      --  Clear error status flags
      ESM.SR1 (1) := 16#FFFF_FFFF#;
      ESM.SR1 (2) := 16#FFFF_FFFF#;
      ESM.SSR2    := 16#FFFF_FFFF#;
      ESM.SR1 (3) := 16#FFFF_FFFF#;

      ESM.SR4 (1) := 16#FFFF_FFFF#;
      ESM.SR4 (2) := 16#FFFF_FFFF#;
      ESM.SR4 (3) := 16#FFFF_FFFF#;

      ESM.SR7 (1) := 16#FFFF_FFFF#;
      ESM.SR7 (2) := 16#FFFF_FFFF#;
      ESM.SR7 (3) := 16#FFFF_FFFF#;

      --  Setup LPC Preload
      ESM.LTCPR   := 16384 - 1;

      --  Reset error pin
      if ESM.EPSR = 0 then
         ESM.EKR  := 16#0000_0005#;
      else
         ESM.EKR  := 16#0000_0000#;
      end if;

      --  Clear Interrupt level
      ESM.ILCR1   := 16#FFFF_FFFF#;
      ESM.ILCR4   := 16#FFFF_FFFF#;
      ESM.ILCR7   := 16#FFFF_FFFF#;

      --  Set Interrupt level
      ESM.ILSR1   := 16#0000_0000#;
      ESM.ILSR4   := 16#0000_0000#;
      ESM.ILSR7   := 16#0000_0000#;

      --  Enable error pin channels
      ESM.EEPAPR1 := 16#0000_0000#;
      ESM.IEPSR4  := 16#0000_0000#;
      ESM.IEPSR7  := 16#0000_0000#;

      --  Enable Interrupts
      ESM.IESR1   := 16#0000_0000#;
      ESM.IESR4   := 16#0000_0000#;
      ESM.IESR7   := 16#0000_0000#;
end esm_init;
