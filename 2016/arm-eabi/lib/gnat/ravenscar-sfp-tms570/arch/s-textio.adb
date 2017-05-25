------------------------------------------------------------------------------
--                                                                          --
--                         GNAT RUN-TIME COMPONENTS                         --
--                                                                          --
--                       S Y S T E M . T E X T _ I O                        --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--          Copyright (C) 1992-2013, Free Software Foundation, Inc.         --
--                                                                          --
-- GNAT is free software;  you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  GNAT is distributed in the hope that it will be useful, but WITH- --
-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE.                                     --
--                                                                          --
--                                                                          --
--                                                                          --
--                                                                          --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
-- GNAT was originally developed  by the GNAT team at  New York University. --
-- Extensive contributions were provided by Ada Core Technologies Inc.      --
--                                                                          --
------------------------------------------------------------------------------

--  Minimal version of Text_IO body for use on TMS570LC43xx, using SCI/LIN

with Interfaces; use Interfaces;

package body System.Text_IO is

   SCI_BASE : constant := 16#FFF7_E400#;
   --  SCI base address

   TX_READY : constant := 16#100#;
   RX_READY : constant := 16#200#;

   SCIGCR0 : Unsigned_32 with Volatile,
      Address => System'To_Address (SCI_BASE + 16#00#);

   SCIGCR1 : Unsigned_32 with Volatile,
     Address => System'To_Address (SCI_BASE + 16#04#);

   SCICLEARINT : Unsigned_32 with Volatile,
     Address => System'To_Address (SCI_BASE + 16#10#);

   SCICLEARINTLVL : Unsigned_32 with Volatile,
     Address => System'To_Address (SCI_BASE + 16#18#);

   SCIFLR : Unsigned_32 with Volatile,
     Address => System'To_Address (SCI_BASE + 16#1C#);

   BRS : Unsigned_32 with Volatile,
     Address => System'To_Address (SCI_BASE + 16#2C#);

   SCIFORMAT : Unsigned_32 with Volatile,
     Address => System'To_Address (SCI_BASE + 16#28#);

   SCIRD : Unsigned_32 with Volatile,
     Address => System'To_Address (SCI_BASE + 16#34#);

   SCITD : Unsigned_32 with Volatile,
     Address => System'To_Address (SCI_BASE + 16#38#);

   SCIPIO0 : Unsigned_32 with Volatile,
     Address => System'To_Address (SCI_BASE + 16#3C#);

   SCIPIO8 : Unsigned_32 with Volatile,
     Address => System'To_Address (SCI_BASE + 16#5C#);

   ---------
   -- Get --
   ---------

   function Get return Character is
   begin
      return Character'Val (SCIRD and 16#FF#);
   end Get;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
   begin
      --  Bring out of reset
      SCIGCR0 := 0;
      SCIGCR0 := 1;

      --  Disable all interrupts
      SCICLEARINT    := 16#FFFF_FFFF#;
      SCICLEARINTLVL := 16#FFFF_FFFF#;

      --  8n1, enable RX and TX, async, idle-line mode, SWnRST, internal clk
      --  NOTE: SPNU499A (Nov 2012) is incorrect on COMM MODE: Idle line mode
      --  value is 0.
      SCIGCR1 := 16#03_00_00_22#;

      --  Baud rate. PLLCLK=300Mhz, VCLK = PLLCLK / 1
      declare
         Baud : constant := 115200;
         VCLK : constant := 75_000_000;
         P    : constant := VCLK / (16 * Baud) - 1;
         M    : constant := (VCLK / Baud) rem 16;
      begin
         BRS  := P + M * 2**24;
      end;

      --  8 bits
      SCIFORMAT := 7;

      --  Enable Tx and Rx pins, pull-up
      SCIPIO0   := 2#110#;
      SCIPIO8   := 2#110#;

      --  Enable SCI
      SCIGCR1   := SCIGCR1 or 16#80#;

      Initialized := True;
   end Initialize;

   -----------------
   -- Is_Tx_Ready --
   -----------------

   function Is_Tx_Ready return Boolean is
      ((SCIFLR and TX_READY) /= 0);

   -----------------
   -- Is_Rx_Ready --
   -----------------

   function Is_Rx_Ready return Boolean is
      ((SCIFLR and RX_READY) /= 0);

   ---------
   -- Put --
   ---------

   procedure Put (C : Character) is
   begin
      SCITD := Character'Pos (C);
   end Put;

   ----------------------------
   -- Use_Cr_Lf_For_New_Line --
   ----------------------------

   function Use_Cr_Lf_For_New_Line return Boolean is
   begin
      return True;
   end Use_Cr_Lf_For_New_Line;
end System.Text_IO;
