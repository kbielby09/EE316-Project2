-----------------
--  Libraries  --
-----------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


 --------------
--  Entity  --
--------------
entity one_hz_counter is
port
(
  -- Clocks & Resets
  I_CLK_50MHZ    : in std_logic;                    -- Input clock signal

  I_SYSTEM_RST   : in std_logic;

  CLK_ENABLE     : out std_logic

  );
end one_hz_counter;

architecture rtl of one_hz_counter is
    signal one_hz_counter_signal : unsigned(25 downto 0) := "00000000000000000000000000";

    signal count_enable   : std_logic;

    begin

    ONE_HZ_CLOCK : process (I_CLK_50MHZ, I_SYSTEM_RST)
        begin
         if(I_SYSTEM_RST = '1') then
            one_hz_counter_signal <= (others => '0');
        elsif (rising_edge(I_CLK_50MHZ)) then
            one_hz_counter_signal <= one_hz_counter_signal + 1;
            if (one_hz_counter_signal = "10111110101111000001111111") then  -- check for 1 Hz clock (count to 50 million)
                count_enable <= '1';
                one_hz_counter_signal <= (others => '0');
            else
                count_enable <= '0';
            end if;
        end if;

    end process ONE_HZ_CLOCK;

    CLK_ENABLE <= count_enable;

end architecture rtl;
