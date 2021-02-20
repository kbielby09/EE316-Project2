-----------------
--  Libraries  --
-----------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

--------------
--  Entity  --
--------------
entity pwm_control is
  port (
    -- Clock and reset Signals
    I_RESET_N   : in std_logic;
    I_CLK_50MHZ : in std_logic;

    addr_change : in std_logic; 
    rom_data     : in std_logic_vector (15 DOWNTO 0);
    PWM_OUT     : out std_logic
  );
end entity;

architecture rtl of pwm_control is

  -- component SRAM_controller is
  -- port
  -- (
  --   -- Clocks & Resets
  --   I_CLK_50MHZ     : in std_logic;                    -- Input clock signal
  --
  --   I_SYSTEM_RST_N  : in std_logic;                    -- Input signal to reset SRAM data form ROM
  --
  --   COUNT_EN : in std_logic;
  --
  --   RW         : in std_logic;
  --
  --   DIO : inout std_logic_vector(15 downto 0);
  --
  --   CE_N : out std_logic;
  --
  --   -- Read/Write enable signals
  --   WE_N    : out std_logic;     -- signal for writing to SRAM
  --   OE    : out std_logic;     -- Input signal for enabling output
  --
  --   UB    : out std_logic;
  --   LB    : out std_logic;
  --
  --   -- digit selection input
  --   IN_DATA      : in std_logic_vector(15 downto 0);    -- gives the values of the digits to be illuminated
  --                                                             -- bits 0-3: digit 1; bits 4-7: digit 2, bits 8-11: digit 3
  --                                                             -- bits 12-15: digit 4
  --
  --   IN_DATA_ADDR : in std_logic_vector(17 downto 0);
  --
  --
  --   -- seven segment display digit selection port
  --   OUT_DATA    : out std_logic_vector(15 downto 0);       -- if bit is 1 then digit is activated and if bit is 0 digit is inactive
  --                                                             -- bits 0-3: digit 1; bits 3-7: digit 2, bit 7: digit 4
  --
  --   OUT_DATA_ADR : out std_logic_vector(17 downto 0)
  --
  --   );
  -- end component SRAM_controller;

  -- component ROM is
  -- 	port
  -- 	(
  -- 		address : in STD_LOGIC_VECTOR (7 DOWNTO 0);
  -- 		clock		: in STD_LOGIC;
  -- 		q		    : out STD_LOGIC_VECTOR (15 DOWNTO 0)
  -- 	);
  -- end component ROM;

  -- Signals to control frequency
  -- type FREQ_STATE is
  -- (
  --   SIXTY_HZ,
  --   ONE_HUNDRED_TWENTY_HZ,
  --   ONE_KHZ
  -- );
  --
  -- signal frequency_state : FREQ_STATE := SIXTY_HZ;
  -- signal frequency_state : FREQ_STATE := ONE_KHZ;

  -- Signals to get rom data
  -- signal i_rom_addr : unsigned(7 downto 0) := (others => '0');
  -- signal rom_data   : std_logic_vector(15 downto 0);
  -- signal addr_change : std_logic := '0';

  -- -- Signals for frequency counter
  -- signal sixty_hz_counter : unsigned(11 downto 0);
  -- signal one_twenty_hz_counter : unsigned(21 downto 0);
  -- signal one_khz_counter : unsigned(21 downto 0);

  signal pwm_count : unsigned(15 downto 0);
  signal pwm_sig_val : std_logic := '0';
  signal PWM_MODE : std_logic := '1'; -- TODO remove and implement with signal
  -- signal null_addr : std_logic_vector(17 downto 0);

begin

  -- ROM_INST : ROM
  -- port map
  -- (
  --   address => std_logic_vector(i_rom_addr),
  --   clock	  => I_CLK_50MHZ,
  --   q		    => rom_data
  -- );

  -- SRAM : SRAM_controller
  -- port map
  -- (
  --   -- Clocks & Resets
  --   I_CLK_50MHZ     : in std_logic;                    -- Input
  --   I_SYSTEM_RST_N  : in std_logic;                    -- Input signal to reset SRAM data
  --   COUNT_EN : in
  --   RW         : in
  --   DIO : inout std_logic_vector(15 downto
  --   CE_N : out
  --   WE_N    : out std_logic;     -- signal for writing
  --   OE    : out std_logic;     -- Input signal for
  --   UB    : out
  --   LB    : out
  --   IN_DATA      : in std_logic_vector(15 downto 0);    -- gives the values of the digits to
  --   IN_DATA_ADDR : in std_logic_vector(17 downto
  --   OUT_DATA  => out_data; -- Rename this
  --   OUT_DATA_ADR => null_addr
  --
  --   );

  -- FREQ_CHANGE : process(I_CLK_50MHZ, I_RESET_N)
  -- begin
  --   if (I_RESET_N = '0') then
  --     frequency_state <= SIXTY_HZ;
  --   elsif (rising_edge(I_CLK_50MHZ)) then
  --     if (FREQ_SEL = '0') then
  --       case( frequency_state ) is
  --         when SIXTY_HZ =>
  --           frequency_state <= ONE_HUNDRED_TWENTY_HZ;
  --         when ONE_HUNDRED_TWENTY_HZ =>
  --           frequency_state <= ONE_KHZ;
  --         when ONE_KHZ =>
  --           frequency_state <= SIXTY_HZ;
  --       end case;
  --     end if;
  --   end if;
  -- end process FREQ_CHANGE;

  -- FREQ_COUNTER : process(I_CLK_50MHZ, I_RESET_N)
  -- begin
  --   if (I_RESET_N = '0') then
  --     sixty_hz_counter <= (others => '0');
  --     one_twenty_hz_counter <= (others => '0');
  --     one_khz_counter <= (others => '0');
  --     addr_change <= '0';
  --     i_rom_addr <= (others => '0');
  --   elsif (rising_edge(I_CLK_50MHZ)) then
  --     sixty_hz_counter <= sixty_hz_counter + 1;
  --     one_twenty_hz_counter <= one_twenty_hz_counter + 1;
  --     one_khz_counter <= one_khz_counter + 1;
  --     addr_change <= '0';
  --     case(frequency_state) is
  --       when SIXTY_HZ =>
  --         if (sixty_hz_counter = "110010110111") then
  --           i_rom_addr <= i_rom_addr + 1;
  --           addr_change <= '1';
  --           sixty_hz_counter <= (others => '0');
  --         end if;
  --
  --       when ONE_HUNDRED_TWENTY_HZ =>
  --         if (one_twenty_hz_counter = "11001011100") then
  --           i_rom_addr <= i_rom_addr + 1;
  --           addr_change <= '1';
  --           one_twenty_hz_counter <= (others => '0');
  --         end if;
  --       when ONE_KHZ =>
  --         if (one_khz_counter = "11000011") then
  --           i_rom_addr <= i_rom_addr + 1;
  --           addr_change <= '1';
  --           one_khz_counter <= (others => '0');
  --         end if;
  --     end case;
  --   end if;
  -- end process FREQ_COUNTER;

  PWM_COUNTER : process(I_CLK_50MHZ, I_RESET_N)
  begin
    if (I_RESET_N = '0') then
      pwm_count <= (others => '0');
      pwm_sig_val <= '0';
    elsif (rising_edge(I_CLK_50MHZ)) then
      if (PWM_MODE = '1') then
        pwm_count <= pwm_count + 1;
        case(frequency_state) is
          when SIXTY_HZ =>
            if (pwm_count(10 downto 0) = unsigned(rom_data(15 downto 5))) then
              pwm_sig_val <= '1';
            elsif (pwm_count(10 downto 0) = "11111111111" or addr_change = '1') then
              pwm_count <= (others => '0');  -- Reset counter
              pwm_sig_val <= '0';
            end if;
          when ONE_HUNDRED_TWENTY_HZ =>
            if (pwm_count(8 downto 0) = unsigned(rom_data(15 downto 7))) then
              pwm_sig_val <= '1';
            elsif (pwm_count(8 downto 0) = "111111111" or addr_change = '1') then
              pwm_count <= (others => '0');  -- Reset counter
              pwm_sig_val <= '0';
            end if;
          when ONE_KHZ =>
            if (pwm_count(5 downto 0) = unsigned(rom_data(15 downto 10))) then
              pwm_sig_val <= '1';
            elsif (pwm_count(5 downto 0) = "111111" or addr_change = '1') then
              pwm_count <= (others => '0');  -- Reset counter
              pwm_sig_val <= '0';
            end if;
        end case;
      end if;
    end if;
  end process PWM_COUNTER;

  PWM_OUT <= pwm_sig_val;
end architecture;
