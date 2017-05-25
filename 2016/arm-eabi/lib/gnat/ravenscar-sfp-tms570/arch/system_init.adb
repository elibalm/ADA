--  ===========================================================================
--  Author:  Elizabeth Almeyda
--  Date:    03 of February 2016
--  Project: TMS570 ARM System configuration and initialization.
--  Description:
--           This file provides the system initialization for the TMS570
--           (ARM Cortex R5) microcontrollers from Texas Instruments.
--  ===========================================================================

pragma Ada_2012;
pragma Restrictions (No_Elaboration_Code);
pragma Suppress (All_Checks);
-------------------------------------------------------------------------------

with System;
with System.TMS570;        use System.TMS570;

-------------------------------------------------------------------------------
procedure system_init is
   ----------------------------------------------------------------------------

   procedure Setup_Pll;
   procedure Init_Peripherals;
   procedure Init_Mux;
   procedure Setup_Flash;
   procedure Trim_LPO;
   procedure Map_Clocks;
   procedure Set_ECLK;

   ----------------------------------------------------------------------------
   --  Configure PLL control registers and enable PLLs
   ----------------------------------------------------------------------------
   procedure Setup_Pll is
   begin
      --  Disable PLL1 and PLL2
      System1.CSDISSET := 16#0000_0002# or 16#0000_0040#;

      --  Wait until the PLLs have been disabled
      while (System1.CSDIS and 16#0000_0042#) /= 16#0000_0042# loop
         null;
      end loop;

      --  Clear Global Status Register
      System1.GLBSTAT  := 16#0000_0301#;

      --  Initialize PLL1
      --  Configure PLL control registers 1 and 2
      --  ROS = 0 : Do not reset when PLL slip is detected
      --  PLLDIV    = 1F  => f (PLL CLK) = f (post_ODCLK) / (PLLDIV + 1)
      --  REFCLKDIV = 7   => f (INT CLK) = f (OSCIN) / (REFVLKDIV+1)
      --  PLLMUL    = 149 => f (VCO CLK) = f (INT CLK) * (PLLMUL/256 + 1)
      System1.PLLCTL1  := 16#2000_0000# or 16#1F00_0000# or 16#0007_0000# or
        16#0000_9500#;

      System1.PLLCTL2  := 16#3FC0_0000# or 16#0000_7000# or 16#0000_003D#;

      --  Initialize PLL2
      System2.PLLCTL3  := 16#1F00_0000# or 16#0007_0000# or 16#0000_9500#;

      --  Enable PLL(s) to start up or Lock
      System1.CSDIS    := 16#0000_0008# or 16#0000_0080# or 16#0000_0004#;
   end Setup_Pll;

   ----------------------------------------------------------------------------
   --  Enable clocks to peripherals and release peripheral reset
   ----------------------------------------------------------------------------
   procedure Init_Peripherals is
   begin
      --  Disable Peripherals before peripheral powerup
      System1.CLKCNTL      := System1.CLKCNTL and 16#FFFF_FEFF#;

      --  Release peripherals from reset and enable clocks to all peripherals
      PCR1_PSPWRDWNCLR (1) := 16#FFFF_FFFF#;
      PCR1_PSPWRDWNCLR (2) := 16#FFFF_FFFF#;
      PCR1_PSPWRDWNCLR (3) := 16#FFFF_FFFF#;
      PCR1_PSPWRDWNCLR (4) := 16#FFFF_FFFF#;

      PCR2_PSPWRDWNCLR (1) := 16#FFFF_FFFF#;
      PCR2_PSPWRDWNCLR (2) := 16#FFFF_FFFF#;
      PCR2_PSPWRDWNCLR (3) := 16#FFFF_FFFF#;
      PCR2_PSPWRDWNCLR (4) := 16#FFFF_FFFF#;

      PCR3_PSPWRDWNCLR (1) := 16#FFFF_FFFF#;
      PCR3_PSPWRDWNCLR (2) := 16#FFFF_FFFF#;
      PCR3_PSPWRDWNCLR (3) := 16#FFFF_FFFF#;
      PCR3_PSPWRDWNCLR (4) := 16#FFFF_FFFF#;

      --  Enable Peripherals
      System1.CLKCNTL      := System1.CLKCNTL or 16#0000_0100#;
   end Init_Peripherals;

   ----------------------------------------------------------------------------
   --  Configure device-level multiplexing and I/O multiplexing
   ----------------------------------------------------------------------------
   procedure Init_Mux is
   begin
      --  Enable Pin Muxing
      IOMUX.KICKER0       := 16#83E7_0B13#;
      IOMUX.KICKER1       := 16#95A4_F1E0#;

      --  Initialize Output Pin Multiplexing Control Registers :
      --  PINMMR0 through PINMMR37

      --  AD1EVT, EMIF_ADDR_00, EMIF_ADDR_01, EMIF_ADDR_06
      IOMUX.PINMUX (0)    := 16#0101_0101#;

      --  EMIF_ADDR_07, EMIF_ADDR_08, EMIF_ADDR_09, EMIF_ADDR_10
      IOMUX.PINMUX (1)    := 16#0101_0101#;

      --  EMIF_ADDR_11, EMIF_ADDR_12, EMIF_ADDR_13, EMIF_ADDR_14
      IOMUX.PINMUX (2)    := 16#0101_0101#;

      --  EMIF_ADDR_15, EMIF_ADDR_16, EMIF_ADDR_17, EMIF_ADDR_18
      IOMUX.PINMUX (3)    := 16#0101_0101#;

      --  EMIF_ADDR_19, EMIF_ADDR_20, EMIF_ADDR_21
      IOMUX.PINMUX (4)    := 16#0001_0101#;

      IOMUX.PINMUX (5)    := 0;
      IOMUX.PINMUX (6)    := 0;
      IOMUX.PINMUX (7)    := 0;
      IOMUX.PINMUX (8)    := 16#0100_0000#;
      IOMUX.PINMUX (9)    := 16#0101_0100#;

      for I in Integer range 10 .. 36 loop
         IOMUX.PINMUX (I) := 16#0101_0101#;
      end loop;

      IOMUX.PINMUX (37)   := 16#0000_0101#;

      --  Initialize Input Pin Multiplexing Control Registers :
      --                               PINMMR80 through PINMMR99
      IOMUX.PINMUX (80)   := 16#0202_0201#;
      IOMUX.PINMUX (81)   := 0;
      IOMUX.PINMUX (82)   := 0;
      IOMUX.PINMUX (83)   := 16#0102_0202#;
      IOMUX.PINMUX (84)   := 16#0101_0101#;
      IOMUX.PINMUX (85)   := 16#0101_0101#;
      IOMUX.PINMUX (86)   := 16#0101_0101#;
      IOMUX.PINMUX (87)   := 16#0101_0101#;
      IOMUX.PINMUX (88)   := 16#0002_0101#;
      IOMUX.PINMUX (89)   := 16#0101_0000#;

      for I in Integer range 90 .. 98 loop
         IOMUX.PINMUX (I) := 16#0101_0101#;
      end loop;

      IOMUX.PINMUX (99)   := 16#0001_0101#;

      --  Special Functionality Multiplexing Control Registers :
      --                              PINMMR160 through PINMMR179
      IOMUX.PINMUX (161)  := 16#0202_0200#;
      IOMUX.PINMUX (162)  := 16#0202_0202#;
      IOMUX.PINMUX (163)  := 16#0002_0202#;

      --  Enable EMIF CLKs
      IOMUX.PINMUX (9)    := IOMUX.PINMUX (9) or 16#0000_0001#;

      --  EMIF OUTPUT Enable
      IOMUX.PINMUX (174)  := IOMUX.PINMUX (174) or 16#0000_0100#;

      --  GPIO_DISABLE_HET1_ENABLE
      IOMUX.PINMUX (179)  := IOMUX.PINMUX (179) or 16#0000_0001#;

      --  Select RMII ETHERNET
      IOMUX.PINMUX (160)  := IOMUX.PINMUX (160) or 16#0100_0000#;

      --  ADC ALT
      IOMUX.PINMUX (161)  := IOMUX.PINMUX (161) or 16#0000_0001#;

      --  ETPWM1_EQEPERR_ Enable
      IOMUX.PINMUX (167)  := IOMUX.PINMUX (167) or 16#0101_0101#;
      IOMUX.PINMUX (168)  := IOMUX.PINMUX (168) or 16#0001_0101#;

      IOMUX.PINMUX (165)  := IOMUX.PINMUX (165) or 16#0100_0000#;
      IOMUX.PINMUX (172)  := IOMUX.PINMUX (172) or 16#0101_0000#;
      IOMUX.PINMUX (173)  := IOMUX.PINMUX (173) or 16#0000_0101#;
      IOMUX.PINMUX (164)  := IOMUX.PINMUX (164) or 16#0101_0101#;
      IOMUX.PINMUX (165)  := IOMUX.PINMUX (165) or 16#0001_0101#;
      IOMUX.PINMUX (170)  := IOMUX.PINMUX (170) and 16#0000_FFFF#;
      IOMUX.PINMUX (171)  := 16#0000_0000#;
      IOMUX.PINMUX (172)  := IOMUX.PINMUX (172) and 16#FFFF_0000#;
      IOMUX.PINMUX (169)  := 16#0000_0000#;
      IOMUX.PINMUX (170)  := IOMUX.PINMUX (170) and 16#FFFF_0000#;

      IOMUX.PINMUX (175)  := 16#0101_0101#;
      IOMUX.PINMUX (176)  := 16#0101_0101#;
      IOMUX.PINMUX (177)  := 16#0101_0101#;
      IOMUX.PINMUX (178)  := 16#0101_0101#;

      IOMUX.PINMUX (174)  := IOMUX.PINMUX (174) or 16#0100_0000#;
      IOMUX.PINMUX (173)  := IOMUX.PINMUX (173) or 16#0101_0000#;
      IOMUX.PINMUX (174)  := IOMUX.PINMUX (174) or 16#0000_0001#;

      --  Disable Pin Muxing
      IOMUX.KICKER0       := 16#0000_0000#;
      IOMUX.KICKER1       := 16#0000_0000#;
   end Init_Mux;

   ----------------------------------------------------------------------------
   --  Set up flash address and data wait states based on the target CPU clock
   --  frequency
   ----------------------------------------------------------------------------
   procedure Setup_Flash is
   begin
      --  Setup flash read mode, address wait states and data wait states
      FLASH_WR_FRDCNTL   := 16#0000_0300# or 16#0000_0003#;

      --  Setup flash access wait states for bank 7
      FSM_WR_ENA_HL      := 16#0000_0005#;
      EEPROM_CONFIG_HL   := 16#0000_0002# or 16#0009_0000#;

      --  Disable write access to flash state machine registers
      FSM_WR_ENA_HL      := 16#0000_0002#;

      --  Setup flash bank power modes
      FLASH_WR_FBPWRMODE := 16#0000_C000# or 16#0000_000C# or 16#0000_0003#;
   end Setup_Flash;

   ----------------------------------------------------------------------------
   --  Configure the LPO such that HF LPO is as close to 10MHz as possible
   ----------------------------------------------------------------------------
   procedure Trim_LPO is
      Value : constant Word := Shift_Right (LPO_TRIM and 16#FFFF_0000#, 16);
   begin
      if Value /=  16#0000_FFFF# then
         System1.LPOMONCTL := 16#0100_0000# or Value;
      else
         System1.LPOMONCTL := 16#0100_0000# or 16#000_1000# or
           16#0100_0010#;
      end if;
   end Trim_LPO;

   ----------------------------------------------------------------------------
   --  Wait for PLLs to start up and map clock domains to desired clock sources
   ----------------------------------------------------------------------------
   procedure Map_Clocks is
      csdis   : Word := 0;
      csvstat : Word := 0;
      cond    : Word := 0;
   begin
      --  Setup system clock divider for HCLK
      System2.HCLKCNTL  := 1;

      --  Disable / Enable clock domain : VCLKA2OFF
      System1.CDDIS     := 16#0000_0020#;

      --  Wait until clocks are locked
      loop
         csvstat     := System1.CSVSTAT;
         csdis       := System1.CSDIS;
         cond        := (csdis xor 16#00FF#) and 16#00FF#;

         exit when (csvstat and cond) = cond;
      end loop;

      --  Now the PLLs are locked and the PLL outputs can be sped up
      System1.PLLCTL1   := System1.PLLCTL1 and 16#E0FF_FFFF#;
      System2.PLLCTL3   := System2.PLLCTL3 and 16#E0FF_FFFF#;

      --  Enable/Disable Frequency modulation
      System1.PLLCTL2   := System1.PLLCTL2 or 16#0000_0000#;

      --  Setup GCLK, HCLK and VCLK clock source for normal operation,
      --  power down mode and after wakeup
      System1.GHVSRC    := 16#0101_0001#;

      --  Setup synchronous peripheral clock dividers for VCLK1, VCLK2, VCLK3
      System1.CLKCNTL   := (System1.CLKCNTL and 16#F0FF_FFFF#) or
        16#0100_0000#;
      System1.CLKCNTL   := (System1.CLKCNTL and 16#FFF0_FFFF#) or
        16#0001_0000#;
      System2.CLK2CNTRL := (System2.CLK2CNTRL and 16#FFFF_FFF0#) or
        16#0000_0001#;

      --  Setup RTICLK1 and RTICLK2 clocks
      System1.RCLKSRC   := 16#0100_0000# or 16#0009_0000# or 16#0000_0100# or
        16#0000_0009#;

      --  Setup asynchronous peripheral clock sources for AVCLK1 and AVCLK2
      System1.VCLKASRC  := 16#0000_0900# or 16#0000_0009#;
      System2.VCLKACON1 := 16#0009_0000# or 16#0000_0009#;

   end Map_Clocks;

   ----------------------------------------------------------------------------
   --  set ECLK pins functional mode
   ----------------------------------------------------------------------------
   procedure Set_ECLK is
   begin
      --  set ECLK pins functional mode
      System1.SYSPC1 := 16#0000_0000#;

      --  set ECLK pins default output value
      System1.SYSPC4 := 16#0000_0000#;

      --  set ECLK pins output direction
      System1.SYSPC2 := 16#0000_0001#;

      --  set ECLK pins open drain enable
      System1.SYSPC7 := 16#0000_0000#;

      --  set ECLK pins pullup/pulldown enable
      System1.SYSPC8 := 16#0000_0000#;

      --  set ECLK pins pullup/pulldown select
      System1.SYSPC9 := 16#0000_0001#;

      --  Setup ECLK
      System1.ECPCNTL := 16#0000_0007#;

   end Set_ECLK;

   ----------------------------------------------------------------------------
   --  System initialization
   ----------------------------------------------------------------------------
begin
   Setup_Pll;
   Init_Peripherals;
   Init_Mux;
   Setup_Flash;
   Trim_LPO;
   Map_Clocks;
   Set_ECLK;
   ----------------------------------------------------------------------------
end system_init;
