--  ===========================================================================
--  Author:  Elizabeth Almeyda
--  Date:    03 of February 2016
--  Project: TMS570LC43XX ARM Definitions
--  Description:
--           This file provides Register definitions for the TMS570
--           (ARM Cortex R5) microcontrollers from Texas Instruments.
--  ===========================================================================

pragma Restrictions (No_Elaboration_Code);

with Interfaces;
-------------------------------------------------------------------------------
package System.TMS570 is
   ----------------------------------------------------------------------------
   pragma Preelaborate (System.TMS570);

   ----------------------------------------------------------------------------
   type Word      is new Interfaces.Unsigned_32;  -- for shift/rotate
   type Half_Word is new Interfaces.Unsigned_16;  -- for shift/rotate
   type Byte      is new Interfaces.Unsigned_8;   -- for shift/rotate

   type Bits_1    is mod 2**1 with Size => 1;
   type Bits_2    is mod 2**2 with Size => 2;
   type Bits_4    is mod 2**4 with Size => 4;

   type Bits_32x1 is array (0 .. 31) of Bits_1 with Pack, Size => 32;
   type Bits_16x2 is array (0 .. 15) of Bits_2 with Pack, Size => 32;
   type Bits_8x4  is array (0 ..  7) of Bits_4 with Pack, Size => 32;

   type Rsvd_3_type   is array (1 .. 3)   of Word with Pack;
   type Rsvd_4_type   is array (1 .. 4)   of Word with Pack;
   type Rsvd_5_type   is array (1 .. 5)   of Word with Pack;
   type Rsvd_6_type   is array (1 .. 6)   of Word with Pack;
   type Rsvd_7_type   is array (1 .. 7)   of Word with Pack;
   type Rsvd_28_type  is array (1 .. 28)  of Word with Pack;
   type Rsvd_40_type  is array (1 .. 40)  of Word with Pack;
   type Rsvd_180_type is array (0 .. 179) of Word with Pack;

   ----------------------------------------------------------------------------
   --  Defines
   ----------------------------------------------------------------------------
   SYSTEM_Port             : constant  := 16#FFFF_FF04#;
   SYSTEM_Base1            : constant  := 16#FFFF_FF00#;
   SYSTEM_Base2            : constant  := 16#FFFF_E100#;
   LPO_TRIM_Base           : constant  := 16#F008_01B4#;
   SYS_EXCEPTION_Base      : constant  := 16#FFFF_FFE4#;
   GIO_Base                : constant  := 16#FF00_0000# + 16#00F7_BC00#;

   --  @brief Flash Wrapper Register Frame Pointer
   Flash_Wrapper_Base      : constant  := 16#FFF8_7000#;
   FLASH_WR_FRDCNTL_BASE   : constant  := 16#FFF8_7000#;
   FLASH_WR_FBPWRMODE_BASE : constant  := 16#FFF8_7000# + 16#0040#;
   FSM_WR_ENA_HL_BASE      : constant  := 16#FFF8_7288#;
   EEPROM_CONFIG_HL_BASE   : constant  := 16#FFF8_72B8#;
   FSM_SECTOR1_BASE        : constant  := 16#FFF8_72C0#;
   FSM_SECTOR2_BASE        : constant  := 16#FFF8_72C4#;
   FCFG_BANK_BASE          : constant  := 16#FFF8_7400#;

   --  IO Mux
   IOMUX_BASE              : constant  := 16#FFFF_1C00#;

   --  PCR
   PCR_REG1_BASE           : constant  := 16#FFFF_1000#;
   PCR_REG2_BASE           : constant  := 16#FCFF_1000#;
   PCR_REG3_BASE           : constant  := 16#FFF7_8000#;
   PSPWRDWNCLR_OFFSET      : constant  := 16#0000_00A0#;

   --  ESM
   ESM_BASE                : constant  := 16#FFFF_F500#;

   ----------------------------------------------------------------------------
   --  System Register Frame 1 Definition
   --   @brief System Register Frame 1 Definition
   --          This type is used to access the System 1 Registers.
   ----------------------------------------------------------------------------

   type System_Base1_Registers_Type is record
      SYSPC1           : Word;          --  0x0000
      SYSPC2           : Word;          --  0x0004
      SYSPC3           : Word;          --  0x0008
      SYSPC4           : Word;          --  0x000C
      SYSPC5           : Word;          --  0x0010
      SYSPC6           : Word;          --  0x0014
      SYSPC7           : Word;          --  0x0018
      SYSPC8           : Word;          --  0x001C
      SYSPC9           : Word;          --  0x0020
      rsvd1            : Word;          --  0x0024
      rsvd2            : Word;          --  0x0028
      rsvd3            : Word;          --  0x002C
      CSDIS            : Word;          --  0x0030
      CSDISSET         : Word;          --  0x0034
      CSDISCLR         : Word;          --  0x0038
      CDDIS            : Word;          --  0x003C
      CDDISSET         : Word;          --  0x0040
      CDDISCLR         : Word;          --  0x0044
      GHVSRC           : Word;          --  0x0048
      VCLKASRC         : Word;          --  0x004C
      RCLKSRC          : Word;          --  0x0050
      CSVSTAT          : Word;          --  0x0054
      MSTGCR           : Word;          --  0x0058
      MINITGCR         : Word;          --  0x005C
      MSINENA          : Word;          --  0x0060
      MSTFAIL          : Word;          --  0x0064
      MSTCGSTAT        : Word;          --  0x0068
      MINISTAT         : Word;          --  0x006C
      PLLCTL1          : Word;          --  0x0070
      PLLCTL2          : Word;          --  0x0074
      SYSPC10          : Word;          --  0x0078
      DIEIDL           : Word;          --  0x007C
      DIEIDH           : Word;          --  0x0080
      rsvd4            : Word;          --  0x0084
      LPOMONCTL        : Word;          --  0x0088
      CLKTEST          : Word;          --  0x008C
      DFTCTRLREG1      : Word;          --  0x0090
      DFTCTRLREG2      : Word;          --  0x0094
      rsvd5            : Word;          --  0x0098
      rsvd6            : Word;          --  0x009C
      GPREG1           : Word;          --  0x00A0
      rsvd7            : Word;          --  0x00A4
      rsvd8            : Word;          --  0x00A8
      rsvd9            : Word;          --  0x00AC
      SSIR1            : Word;          --  0x00B0
      SSIR2            : Word;          --  0x00B4
      SSIR3            : Word;          --  0x00B8
      SSIR4            : Word;          --  0x00BC
      RAMGCR           : Word;          --  0x00C0
      BMMCR1           : Word;          --  0x00C4
      rsvd10           : Word;          --  0x00C8
      CPURSTCR         : Word;          --  0x00CC
      CLKCNTL          : Word;          --  0x00D0
      ECPCNTL          : Word;          --  0x00D4
      rsvd11           : Word;          --  0x00D8
      DEVCR1           : Word;          --  0x00DC
      SYSECR           : Word;          --  0x00E0
      SYSESR           : Word;          --  0x00E4
      SYSTASR          : Word;          --  0x00E8
      GLBSTAT          : Word;          --  0x00EC
      DEVID            : Word;          --  0x00F0
      SSIVEC           : Word;          --  0x00F4
      SSIF             : Word;          --  0x00F8
   end record;

   ----------------------------------------------------------------------------
   type System_Base2_Registers_Type is record
      PLLCTL3          : Word;          --  0x0000
      rsvd1            : Word;          --  0x0004
      STCCLKDIV        : Word;          --  0x0008
      rsvd2            : Rsvd_6_type;   --  0x000C
      ECPCNTL          : Word;          --  0x0024
      ECPCNTL1         : Word;          --  0x0028
      rsvd3            : Rsvd_4_type;   --  0x002C
      CLK2CNTRL        : Word;          --  0x003C
      VCLKACON1        : Word;          --  0x0040
      rsvd4            : Rsvd_4_type;   --  0x0044
      HCLKCNTL         : Word;          --  0x0054
      rsvd5            : Rsvd_6_type;   --  0x0058
      CLKSLIP          : Word;          --  0x0070
      rsvd6            : Word;          --  0x0074
      IP1ECCERREN      : Word;          --  0x0078
      rsvd7            : Rsvd_28_type;  --  0x007C
      EFC_CTLEN        : Word;          --  0x00EC
      DIEIDL_REG0      : Word;          --  0x00F0
      DIEIDH_REG1      : Word;          --  0x00F4
      DIEIDL_REG2      : Word;          --  0x00F8
      DIEIDH_REG3      : Word;          --  0x00FC
   end record;
   ----------------------------------------------------------------------------

   System1  : System_Base1_Registers_Type with Volatile,
                Address => System'To_Address (SYSTEM_Base1);

   System2  : System_Base2_Registers_Type with Volatile,
                Address => System'To_Address (SYSTEM_Base2);

   ----------------------------------------------------------------------------
   --  G P I O
   ----------------------------------------------------------------------------
   type GIO_Unit is record
      GIODIR    : Word; -- GIO Data Direction Register
      GIODIN    : Word; -- GIO Data Input Register
      GIODOUT   : Word; -- GIO Data Output Register
      GIODSET   : Word; -- GIO Data Set Register
      GIODCLR   : Word; -- GIO Data Clear Register
      GIOPDR    : Word; -- GIO Open Drain Register
      GIOPULDIS : Word; -- GIO Pull Disable Register
      GIOPSL    : Word; -- GIO Pull Select Register
   end record;

   type GIO_Range is (GIO_A, GIO_B);
   for GIO_Range use (GIO_A => 0, GIO_B => 1);

   --  This range can be 0..7 on some SoCs vvvvvv
   type GIO_Block is array (GIO_Range) of GIO_Unit;

   type GIO_Register is record
      GIOGCR0   : Word; -- GIO Global Control Register #00#
      Reserved1 : Word; -- reserved 16#04#
      GIOINTDET : Word; -- GIO Interrupt Detect Register #08#
      GIOPOL    : Word; -- GIO Interrupt Polarity Register #0C#
      GIOENASET : Word; -- GIO Interrupt Enable #10#
      GIOENACLR : Word; -- GIO Interrupt Enable Clear Register #14#
      GIOLVLSET : Word; -- GIO Interrupt Priority #18#
      GIOLVLCLR : Word; -- GIO Interrupt Priority Clear Register #1C#
      GIOFLG    : Word; -- GIO Interrupt Flag Register #20#
      GIOOFF1   : Word; -- GIO Offset 1 Register #24#
      GIOOFF2   : Word; -- GIO Offset 2 Register #28#
      GIOEMU1   : Word; -- GIO Emulation 1 Register #2C#
      GIOEMU2   : Word; -- GIO Emulation 2 Register #30#
      GIOx      : GIO_Block;
   end record;

   GIO : GIO_Register with Volatile, Address
     => System'To_Address (GIO_Base);

   ----------------------------------------------------------------------------
   --  System_Exception
   ----------------------------------------------------------------------------

   LPO_TRIM    : Word with Volatile,
     Address => System'To_Address (LPO_TRIM_Base);

   ----------------------------------------------------------------------------
   --  Flash Wrapper
   ----------------------------------------------------------------------------

   FLASH_WR_FRDCNTL : Word with Volatile,
                      Address => System'To_Address (FLASH_WR_FRDCNTL_BASE);

   FLASH_WR_FBPWRMODE : Word with Volatile,
                        Address => System'To_Address (FLASH_WR_FBPWRMODE_BASE);

   FSM_WR_ENA_HL    : Word with Volatile,
                          Address => System'To_Address (FSM_WR_ENA_HL_BASE);

   EEPROM_CONFIG_HL : Word with Volatile,
                          Address => System'To_Address (EEPROM_CONFIG_HL_BASE);

   FCFG_BANK_HL     : Word with Volatile,
                          Address => System'To_Address (FCFG_BANK_BASE);

   ----------------------------------------------------------------------------
   --  Pin MUX
   ----------------------------------------------------------------------------

   type IOMUX_Register_Type is record
      REVISION_REG           :  Word;          --  0x00: Revision Register
      rsvd1                  :  Rsvd_7_type;   --  Reserved 04,8,c,10,14,18,1c
      BOOT_REG               :  Word;          --  0x20: Boot Mode Register
      rsvd2                  :  Rsvd_5_type;   --  Reserved
      KICKER0                :  Word;          --  0x38: Kicker Register 0
      KICKER1                :  Word;          --  0x3C: Kicker Register 1
      rsvd3                  :  Rsvd_40_type;  --  Reserved
      ERR_RAW_STATUS_REG     :  Word;          --  0xE0: Error Raw Status /
      --        Set Register
      ERR_ENABLED_STATUS_REG :  Word;          --  0xE4: Error Enabled Status /
      --        Clear Register
      ERR_ENABLE_REG         :  Word;          --  0xE8: Error Signaling Enable
      --                                       --        Register
      ERR_ENABLE_CLR_REG     :  Word;          --  0xEC: Error Signaling Enable
      --                                         --      Clear Register
      rsvd4                  :  Word;          --  Reserved
      FAULT_ADDRESS_REG      :  Word;          --  0xF4: Fault Address Register
      FAULT_STATUS_REG       :  Word;          --  0xF8: Fault Status Register
      FAULT_CLEAR_REG        :  Word;          --  0xFC: Fault Clear Register
      rsvd5                  :  Rsvd_4_type;   --  Reserved
      PINMUX                 :  Rsvd_180_type;
      --  0x110 - 0x1A4 : Output Pin Multiplexing Control Registers
      --                  (38 registers)
      --  0x250 - 0x29C : Input Pin Multiplexing Control Registers (20)
      --  0x390 - 0x3DC : Special Functionality Control Registers (20)
   end record;

   ----------------------------------------------------------------------------
   IOMUX  : IOMUX_Register_Type with Volatile,
     Address => System'To_Address (IOMUX_BASE);

   ----------------------------------------------------------------------------
   PCR1_PSPWRDWNCLR  : Rsvd_4_type with Volatile,
           Address => System'To_Address (PCR_REG1_BASE + PSPWRDWNCLR_OFFSET);

   PCR2_PSPWRDWNCLR  : Rsvd_4_type with Volatile,
           Address => System'To_Address (PCR_REG2_BASE + PSPWRDWNCLR_OFFSET);

   PCR3_PSPWRDWNCLR  : Rsvd_4_type with Volatile,
     Address => System'To_Address (PCR_REG3_BASE + PSPWRDWNCLR_OFFSET);

   ----------------------------------------------------------------------------
   --  ESM Register
   ----------------------------------------------------------------------------

   type ESM_Register_Type is record
      EEPAPR1          :  Word;          --  0x0000
      DEPAPR1          :  Word;          --  0x0004
      IESR1            :  Word;          --  0x0008
      IECR1            :  Word;          --  0x000C
      ILSR1            :  Word;          --  0x0010
      ILCR1            :  Word;          --  0x0014
      SR1              :  Rsvd_3_type;   --  0x0018, 0x001C, 0x0020
      EPSR             :  Word;          --  0x0024
      IOFFHR           :  Word;          --  0x0028
      IOFFLR           :  Word;          --  0x002C
      LTCR             :  Word;          --  0x0030
      LTCPR            :  Word;          --  0x0034
      EKR              :  Word;          --  0x0038
      SSR2             :  Word;          --  0x003C
      IEPSR4           :  Word;          --  0x0040
      IEPCR4           :  Word;          --  0x0044
      IESR4            :  Word;          --  0x0048
      IECR4            :  Word;          --  0x004C
      ILSR4            :  Word;          --  0x0050
      ILCR4            :  Word;          --  0x0054
      SR4              :  Rsvd_3_type;   --  0x0058, 0x005C, 0x0060
      rsvd1            :  Rsvd_7_type;   --  0x0064 - 0x007C
      IEPSR7           :  Word;          --  0x0080
      IEPCR7           :  Word;          --  0x0084
      IESR7            :  Word;          --  0x0088
      IECR7            :  Word;          --  0x008C
      ILSR7            :  Word;          --  0x0090
      ILCR7            :  Word;          --  0x0094
      SR7              :  Rsvd_3_type;   --  0x0098, 0x009C, 0x00A0
   end record;

   ----------------------------------------------------------------------------
   ESM  : ESM_Register_Type with Volatile, Import,
                            Address => System'To_Address (ESM_BASE);

   ----------------------------------------------------------------------------
end System.TMS570;
