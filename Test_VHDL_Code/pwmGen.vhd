-----------------
--  Libraries  --
-----------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

--------------
--  Entity  --
--------------
entity pwmGen is
  port (
    -- Clock and reset Signals
    I_RESET_N   : in std_logic;
    I_CLK_50MHZ : in std_logic;

    PWM_MODE    : in std_logic;
    I_ROM_DATA  : in std_logic_vector(15 downto 0);

    PWM_OUT     : out std_logic
  );
end entity pwmGen;

--------------------------------
--  Architecture Declaration  --
--------------------------------
architecture rtl of pwmGen is

  signal pwm_count : unsigned(15 downto 0);
  signal pwm_sig_val : std_logic := '0';

begin

  PWM_COUNTER : process(I_CLK_50MHZ, I_RESET_N)
  begin
    if (I_RESET_N = '0') then
      pwm_count <= (others => '0');
    elsif (rising_edge(I_CLK_50MHZ)) then
      if (PWM_MODE = '1') then
        pwm_count <= pwm_count + 1;

        if (pwm_count = I_ROM_DATA) then
          pwm_sig_val <= '1';
        elsif (pwm_count = "1111111111111111") then
          pwm_count <= (others => '0');  -- Reset counter
        end if;
      end if;
    end if;
  end process PWM_COUNTER;

  PWM_OUT <= pwm_sig_val; -- TODO not sure about this
end rtl;
