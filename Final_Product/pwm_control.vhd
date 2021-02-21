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
    frequency   : in std_logic_vector(1 downto 0);
    addr_change : in std_logic;
    i_rom_data  : in std_logic_vector (15 DOWNTO 0);
    PWM_OUT     : out std_logic
  );
end entity;

architecture rtl of pwm_control is

  signal pwm_count : unsigned(15 downto 0);
  signal pwm_sig_val : std_logic := '0';
  signal PWM_MODE : std_logic := '1'; -- TODO remove and implement with signal

begin

  PWM_COUNTER : process(I_CLK_50MHZ, I_RESET_N)
  begin
    if (I_RESET_N = '0') then
      pwm_count <= (others => '0');
      pwm_sig_val <= '0';
    elsif (rising_edge(I_CLK_50MHZ)) then
      if (PWM_MODE = '1') then
        pwm_count <= pwm_count + 1;

        if (addr_change = '1') then
          pwm_count <= (others => '0');  -- Reset counter
        end if;

        case(frequency) is
          when "00" =>
            if (pwm_count = unsigned(i_rom_data(15 downto 7))) then
              pwm_sig_val <= '1';
            elsif (pwm_count = X"1FF") then
              pwm_count <= (others => '0');  -- Reset counter
              pwm_sig_val <= '0';
            end if;
          when "01" =>
            if (pwm_count = unsigned(i_rom_data(15 downto 7))) then
              pwm_sig_val <= '1';
            elsif (pwm_count = X"1FF") then
              pwm_count <= (others => '0');  -- Reset counter
              pwm_sig_val <= '0';
            end if;
          when "10" =>
            if (pwm_count = unsigned(i_rom_data(15 downto 10))) then
              pwm_sig_val <= '1';
            elsif (pwm_count = X"3F") then
              pwm_count <= (others => '0');  -- Reset counter
              pwm_sig_val <= '0';
            end if;
          when others =>
            -- Do nothing
        end case;
      end if;
    end if;
  end process PWM_COUNTER;

  PWM_OUT <= pwm_sig_val;
end architecture;
