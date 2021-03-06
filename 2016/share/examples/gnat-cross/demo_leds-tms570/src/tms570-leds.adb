------------------------------------------------------------------------------
--                                                                          --
--                             GNAT EXAMPLE                                 --
--                                                                          --
--             Copyright (C) 2014, Free Software Foundation, Inc.           --
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

with Ada.Unchecked_Conversion;

package body TMS570.LEDs is

   function As_Word is new Ada.Unchecked_Conversion
     (Source => User_LED, Target => Word);

   --------
   -- On --
   --------

   procedure On (This : User_LED) is
   begin
      Set_Pin (GPIOB_Port, As_Word (This));
   end On;

   ---------
   -- Off --
   ---------

   procedure Off (This : User_LED) is
   begin
      Clear_Pin (GPIOB_Port, As_Word (This));
   end Off;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
   begin
      -- Set GPIO Module out of reset
      GPIO_Base.GCR0    := 16#0000_0001#;
      GPIO_Base.ENACLR  := 16#FFFF_FFFF#;
      GPIO_Base.LVLCLR  := 16#FFFF_FFFF#;

      -- Set pins 7:4 as outputs
      GPIOB_Port.DOUT   := 16#0000_00F0#;
      GPIOB_Port.DIR    := 16#0000_00F0#;
      GPIOB_Port.PDR    := 16#0000_0000#;
      GPIOB_Port.PSL    := 16#0000_0000#;
      GPIOB_Port.PULDIS := 16#0000_0000#;

      -- Initialize interrupts
      GPIO_Base.POL     := 16#0000_0000#;
      GPIO_Base.LVLSET  := 16#0000_0000#;
      GPIO_Base.FLG     := 16#0000_00FF#;
      GPIO_Base.ENASET  := 16#0000_0000#;

   end Initialize;

begin
   Initialize;
end TMS570.LEDs;
