-----------------
--  Libraries  --
-----------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

--------------
--  Entity  --
--------------
entity input_to_ascii is
  port (
    -- Clock and reset Signals
    I_RESET_N   : in std_logic;
    I_CLK_50MHZ : in std_logic;

    -- Address and data
    data_ascii_out : out std_logic_vector(31 downto 0);
    addr_ascii_out : out std_logic_vector(15 downto 0);
    INPUT_ADDR     : in std_logic_vector(7 downto 0);
    INPUT_DATA     : in std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of input_to_ascii is
begin

  INPUT_TO_ASCII : process(I_CLK_50MHZ, I_RESET_N)
    begin
      if (I_RESET_N = '0') then
        addr_ascii_out <= (others => '0');
        data_ascii_out <= (others => '0');
      elsif (rising_edge(I_CLK_50MHZ)) then
        case( INPUT_ADDR(3 downto 0) ) is
          when "0000"             => -- '0'
            addr_ascii_out(7 downto 0) <= "00110000";
          when "0001"             => -- '1'
            addr_ascii_out(7 downto 0) <= "00110001";
          when "0010"             => -- '2'
            addr_ascii_out(7 downto 0) <= "00110010";
          when "0011"             => -- '3'
            addr_ascii_out(7 downto 0) <= "00110011";
          when "0100"             => -- '4'
            addr_ascii_out(7 downto 0) <= "00110100";
          when "0101"             => -- '5'
            addr_ascii_out(7 downto 0) <= "00110101";
          when "0110"             => -- '6'
            addr_ascii_out(7 downto 0) <= "00110110";
          when "0111"             => -- '7'
            addr_ascii_out(7 downto 0) <= "00110111";
          when "1000"             => -- '8'
            addr_ascii_out(7 downto 0) <= "00111000";
          when "1001"             => -- '9'
            addr_ascii_out(7 downto 0) <= "00111001";
          when "1010"             => -- 'A'
            addr_ascii_out(7 downto 0) <= "01000001";
          when "1011"             => -- 'B'
            addr_ascii_out(7 downto 0) <= "01000010";
          when "1100"             => -- 'C'
            addr_ascii_out(7 downto 0) <= "01000011";
          when "1101"             => -- 'D'
            addr_ascii_out(7 downto 0) <= "01000100";
          when "1110"             => -- 'E'
            addr_ascii_out(7 downto 0) <= "01000101";
          when "1111"             => -- 'F'
            addr_ascii_out(7 downto 0) <= "01000110";
        end case;

        case( INPUT_ADDR(7 downto 4) ) is
          when "0000"             => -- '0'
            addr_ascii_out(15 downto 8) <= "00110000";
          when "0001"             => -- '1'
            addr_ascii_out(15 downto 8) <= "00110001";
          when "0010"             => -- '2'
            addr_ascii_out(15 downto 8) <= "00110010";
          when "0011"             => -- '3'
            addr_ascii_out(15 downto 8) <= "00110011";
          when "0100"             => -- '4'
            addr_ascii_out(15 downto 8) <= "00110100";
          when "0101"             => -- '5'
            addr_ascii_out(15 downto 8) <= "00110101";
          when "0110"             => -- '6'
            addr_ascii_out(15 downto 8) <= "00110110";
          when "0111"             => -- '7'
            addr_ascii_out(15 downto 8) <= "00110111";
          when "1000"             => -- '8'
            addr_ascii_out(15 downto 8) <= "00111000";
          when "1001"             => -- '9'
            addr_ascii_out(15 downto 8) <= "00111001";
          when "1010"             => -- 'A'
            addr_ascii_out(15 downto 8) <= "01000001";
          when "1011"             => -- 'B'
            addr_ascii_out(15 downto 8) <= "01000010";
          when "1100"             => -- 'C'
            addr_ascii_out(15 downto 8) <= "01000011";
          when "1101"             => -- 'D'
            addr_ascii_out(15 downto 8) <= "01000100";
          when "1110"             => -- 'E'
            addr_ascii_out(15 downto 8) <= "01000101";
          when "1111"             => -- 'F'
            addr_ascii_out(15 downto 8) <= "01000110";
        end case;

        case( INPUT_DATA(3 downto 0) ) is
          when "0000"             => -- '0'
            data_ascii_out(7 downto 0) <= "00110000";
          when "0001"             => -- '1'
            data_ascii_out(7 downto 0) <= "00110001";
          when "0010"             => -- '2'
            data_ascii_out(7 downto 0) <= "00110010";
          when "0011"             => -- '3'
            data_ascii_out(7 downto 0) <= "00110011";
          when "0100"             => -- '4'
            data_ascii_out(7 downto 0) <= "00110100";
          when "0101"             => -- '5'
            data_ascii_out(7 downto 0) <= "00110101";
          when "0110"             => -- '6'
            data_ascii_out(7 downto 0) <= "00110110";
          when "0111"             => -- '7'
            data_ascii_out(7 downto 0) <= "00110111";
          when "1000"             => -- '8'
            data_ascii_out(7 downto 0) <= "00111000";
          when "1001"             => -- '9'
            data_ascii_out(7 downto 0) <= "00111001";
          when "1010"             => -- 'A'
            data_ascii_out(7 downto 0) <= "01000001";
          when "1011"             => -- 'B'
            data_ascii_out(7 downto 0) <= "01000010";
          when "1100"             => -- 'C'
            data_ascii_out(7 downto 0) <= "01000011";
          when "1101"             => -- 'D'
            data_ascii_out(7 downto 0) <= "01000100";
          when "1110"             => -- 'E'
            data_ascii_out(7 downto 0) <= "01000101";
          when "1111"             => -- 'F'
            data_ascii_out(7 downto 0) <= "01000110";
        end case;

        case( INPUT_DATA(7 downto 4) ) is
          when "0000"             => -- '0'
            data_ascii_out(15 downto 8) <= "00110000";
          when "0001"             => -- '1'
            data_ascii_out(15 downto 8) <= "00110001";
          when "0010"             => -- '2'
            data_ascii_out(15 downto 8) <= "00110010";
          when "0011"             => -- '3'
            data_ascii_out(15 downto 8) <= "00110011";
          when "0100"             => -- '4'
            data_ascii_out(15 downto 8) <= "00110100";
          when "0101"             => -- '5'
            data_ascii_out(15 downto 8) <= "00110101";
          when "0110"             => -- '6'
            data_ascii_out(15 downto 8) <= "00110110";
          when "0111"             => -- '7'
            data_ascii_out(15 downto 8) <= "00110111";
          when "1000"             => -- '8'
            data_ascii_out(15 downto 8) <= "00111000";
          when "1001"             => -- '9'
            data_ascii_out(15 downto 8) <= "00111001";
          when "1010"             => -- 'A'
            data_ascii_out(15 downto 8) <= "01000001";
          when "1011"             => -- 'B'
            data_ascii_out(15 downto 8) <= "01000010";
          when "1100"             => -- 'C'
            data_ascii_out(15 downto 8) <= "01000011";
          when "1101"             => -- 'D'
            data_ascii_out(15 downto 8) <= "01000100";
          when "1110"             => -- 'E'
            data_ascii_out(15 downto 8) <= "01000101";
          when "1111"             => -- 'F'
            data_ascii_out(15 downto 8) <= "01000110";
        end case;

        case( INPUT_DATA(11 downto 8) ) is
          when "0000"             => -- '0'
            data_ascii_out(23 downto 16) <= "00110000";
          when "0001"             => -- '1'
            data_ascii_out(23 downto 16) <= "00110001";
          when "0010"             => -- '2'
            data_ascii_out(23 downto 16) <= "00110010";
          when "0011"             => -- '3'
            data_ascii_out(23 downto 16) <= "00110011";
          when "0100"             => -- '4'
            data_ascii_out(23 downto 16) <= "00110100";
          when "0101"             => -- '5'
            data_ascii_out(23 downto 16) <= "00110101";
          when "0110"             => -- '6'
            data_ascii_out(23 downto 16) <= "00110110";
          when "0111"             => -- '7'
            data_ascii_out(23 downto 16) <= "00110111";
          when "1000"             => -- '8'
            data_ascii_out(23 downto 16) <= "00111000";
          when "1001"             => -- '9'
            data_ascii_out(23 downto 16) <= "00111001";
          when "1010"             => -- 'A'
            data_ascii_out(23 downto 16) <= "01000001";
          when "1011"             => -- 'B'
            data_ascii_out(23 downto 16) <= "01000010";
          when "1100"             => -- 'C'
            data_ascii_out(23 downto 16) <= "01000011";
          when "1101"             => -- 'D'
            data_ascii_out(23 downto 16) <= "01000100";
          when "1110"             => -- 'E'
            data_ascii_out(23 downto 16) <= "01000101";
          when "1111"             => -- 'F'
            data_ascii_out(23 downto 16) <= "01000110";
        end case;

        case( INPUT_DATA(15 downto 12) ) is
          when "0000"             => -- '0'
            data_ascii_out(31 downto 24) <= "00110000";
          when "0001"             => -- '1'
            data_ascii_out(31 downto 24) <= "00110001";
          when "0010"             => -- '2'
            data_ascii_out(31 downto 24) <= "00110010";
          when "0011"             => -- '3'
            data_ascii_out(31 downto 24) <= "00110011";
          when "0100"             => -- '4'
            data_ascii_out(31 downto 24) <= "00110100";
          when "0101"             => -- '5'
            data_ascii_out(31 downto 24) <= "00110101";
          when "0110"             => -- '6'
            data_ascii_out(31 downto 24) <= "00110110";
          when "0111"             => -- '7'
            data_ascii_out(31 downto 24) <= "00110111";
          when "1000"             => -- '8'
            data_ascii_out(31 downto 24) <= "00111000";
          when "1001"             => -- '9'
            data_ascii_out(31 downto 24) <= "00111001";
          when "1010"             => -- 'A'
            data_ascii_out(31 downto 24) <= "01000001";
          when "1011"             => -- 'B'
            data_ascii_out(31 downto 24) <= "01000010";
          when "1100"             => -- 'C'
            data_ascii_out(31 downto 24) <= "01000011";
          when "1101"             => -- 'D'
            data_ascii_out(31 downto 24) <= "01000100";
          when "1110"             => -- 'E'
            data_ascii_out(31 downto 24) <= "01000101";
          when "1111"             => -- 'F'
            data_ascii_out(31 downto 24) <= "01000110";
        end case;
      end if;
  end process INPUT_TO_ASCII;

end architecture rtl;
