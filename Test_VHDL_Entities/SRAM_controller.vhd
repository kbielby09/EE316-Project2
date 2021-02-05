--------------------------------------------------------------------------------
-- Filename     : seven_seg_driver.vhd
-- Author       : Kyle Bielby
-- Date Created : 2021-25-01
-- Last Revised : 2021-25-01
-- Project      : seven_seg_driver
-- Description  : driver code that displays digit on the seven segment display
--------------------------------------------------------------------------------
-- Todos:
--
--
--------------------------------------------------------------------------------

-----------------
--  Libraries  --
-----------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

--------------
--  Entity  --
--------------
entity SRAM_controller is
port
(
  -- Clocks & Resets
  I_CLK_50MHZ     : in std_logic;                    -- Input clock signal

  I_SYSTEM_RST_N  : in std_logic;                    -- Input signal to reset SRAM data form ROM

  COUNT_EN : in std_logic;

  RW         : in std_logic;

  DIO : inout std_logic_vector(15 downto 0);

  CE_N : out std_logic;

  -- Read/Write enable signals
  WE_N    : out std_logic;     -- signal for writing to SRAM
  OE    : out std_logic;     -- Input signal for enabling output

  UB    : out std_logic;
  LB    : out std_logic;

  -- digit selection input
  IN_DATA      : in std_logic_vector(15 downto 0);    -- gives the values of the digits to be illuminated
                                                            -- bits 0-3: digit 1; bits 4-7: digit 2, bits 8-11: digit 3
                                                            -- bits 12-15: digit 4

  IN_DATA_ADDR : in std_logic_vector(17 downto 0);


  -- seven segment display digit selection port
  OUT_DATA    : out std_logic_vector(15 downto 0);       -- if bit is 1 then digit is activated and if bit is 0 digit is inactive
                                                            -- bits 0-3: digit 1; bits 3-7: digit 2, bit 7: digit 4

  OUT_DATA_ADR : out std_logic_vector(17 downto 0)

  );
end SRAM_controller;


--------------------------------
--  Architecture Declaration  --
--------------------------------
architecture rtl of SRAM_controller is

  -------------
  -- SIGNALS --
  -------------

  -- state machine states for SRAM read and write FSM
  type SRAM_STATE is (INIT,
                      READY,
                      WRITE1,
                      WRITE2,
                      READ1,
                      READ2);

  signal current_state : SRAM_STATE;  -- current state of the

  signal read_data       : std_logic_vector(15 downto 0);

  signal tri_state : std_logic;

begin

 -- state machine responsible for changing the states of the SRAM state machine
 STATE_CHANGE : process (I_CLK_50MHZ, RW, COUNT_EN)
     begin
     if (rising_edge(I_CLK_50MHZ)) then
         case current_state is
             when INIT =>
                 -- check for written ROM
                 current_state <= READY;
             when READY =>
                 if (COUNT_EN = '1') then
                   if (RW = '0') then  -- TODO not sure how to implement clock
                      current_state <= WRITE1;
                   elsif (RW = '1') then
                     current_state <= READ1;
                   end if;
                 end if;
                 when READ1 =>
                     current_state <= READ2;
                 when READ2 =>
                     current_state <= READY;
                 when WRITE1 =>
                     current_state <= WRITE2;
                 when WRITE2 =>
                     current_state <= READY;
         end case;
     end if;
 end process STATE_CHANGE;

 CHANGE_STUFF : process(I_CLK_50MHZ)
     begin
         if (rising_edge(I_CLK_50MHZ)) then
           case current_state is

      when INIT =>
        tri_state <= '0';
        WE_N     <= '1';
        OE     <= '1';

        when READY =>
          tri_state <= '0';
          WE_N     <= '1';
          OE     <= '1';

      when READ1 =>
        tri_state <= '0';
        WE_N     <= '1';
        OE     <= '0';

      when READ2 =>
        read_data      <= DIO;
        tri_state <= '0';
        WE_N     <= '1';
        OE     <= '0';

      when WRITE1 =>
        tri_state <= '1';
        WE_N     <= '0';
        OE     <= '1';

      when WRITE2 =>
        tri_state <= '1';
        WE_N     <= '0';
        OE     <= '1';

      -- Error condition, should never occur
      when others =>
        tri_state <= '0';
        WE_N     <= '1';
        OE     <= '1';
    end case;
         end if;
end process CHANGE_STUFF;

  DIO          <= IN_DATA when tri_state = '1' else (others => 'Z');
  CE_N         <= '0';
  UB           <= '0';
  LB           <= '0';
  OUT_DATA     <= read_data;
  OUT_DATA_ADR <= IN_DATA_ADDR;



------------------------------------------------------------------------------
  -- Process Name     : REFRESH_DIGITS
  -- Sensitivity List : I_CLK_100MHZ    : 100 MHz global clock
  --
  -- Useful Outputs   : segment_select : Gives the segment section that is to be illuminated
  --                  : digit_select : selects the digit to illuminate
  --                    (active high enable logic)
  -- Description      : illuminates the desired segment and digit that is to be displayed
  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------

  -- send signals to output ports

end architecture rtl;
