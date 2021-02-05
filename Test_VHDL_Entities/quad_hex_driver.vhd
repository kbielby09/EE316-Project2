library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.Numeric_std.all;

entity quad_hex_driver is
port
(
  I_CLK_50MHZ         : in Std_logic;
  I_RESET_N           : in Std_logic;
  I_COUNT             : in Std_logic_Vector(15 downto 0);
  I_DATA_ADDR         : in Std_logic_Vector(7 downto 0);
  O_DATA_ADDR	      : out Std_logic_Vector(13 downto 0);
  O_HEX_N             : out Std_logic_Vector(27 downto 0)
);
end;

architecture behavioral of quad_hex_driver is

  signal O_HEX_N_BUF: std_logic_vector(27 downto 0);
  signal O_DATA_ADDR_BUF: std_logic_vector(13 downto 0);

  begin
quad_hex_driver: process(I_CLK_50MHZ, I_RESET_N) begin

    -- Reset state to Idle
    if I_RESET_N = '1' then
      O_HEX_N <= "1111111111111111111111111111";
      O_DATA_ADDR <= (others => '1');

    elsif rising_edge(I_CLK_50MHZ) then
      case(I_COUNT(3 downto 0)) is
        when "0000"             => -- '0'
          O_HEX_N_BUF(6 downto 0) <= "1000000";
        when "0001"             => -- '1'
          O_HEX_N_BUF(6 downto 0) <= "1111001";
        when "0010"             => -- '2'
          O_HEX_N_BUF(6 downto 0) <= "0100100";
        when "0011"             => -- '3'
          O_HEX_N_BUF(6 downto 0) <= "0110000";
        when "0100"             => -- '4'
          O_HEX_N_BUF(6 downto 0) <= "0011001";
        when "0101"             => -- '5'
          O_HEX_N_BUF(6 downto 0) <= "0010010";
        when "0110"             => -- '6'
          O_HEX_N_BUF(6 downto 0) <= "0000010";
        when "0111"             => -- '7'
          O_HEX_N_BUF(6 downto 0) <= "1111000";
        when "1000"             => -- '8'
          O_HEX_N_BUF(6 downto 0) <= "0000000";
        when "1001"             => -- '9'
          O_HEX_N_BUF(6 downto 0) <= "0010000";
        when "1010"             => -- 'A'
          O_HEX_N_BUF(6 downto 0) <= "0001000";
        when "1011"             => -- 'B'
          O_HEX_N_BUF(6 downto 0) <= "0000011";
        when "1100"             => -- 'C'
          O_HEX_N_BUF(6 downto 0) <= "1000110";
        when "1101"             => -- 'D'
          O_HEX_N_BUF(6 downto 0) <= "0100001";
        when "1110"             => -- 'E'
          O_HEX_N_BUF(6 downto 0) <= "0000110";
        when "1111"             => -- 'F'
          O_HEX_N_BUF(6 downto 0) <= "0001110";
        when others             => -- ' '
          O_HEX_N_BUF(6 downto 0) <= "1111111";
      end case;

		case(I_COUNT(7 downto 4)) is
      when "0000"             => -- '0'
        O_HEX_N_BUF(13 downto 7) <= "1000000";
      when "0001"             => -- '1'
        O_HEX_N_BUF(13 downto 7) <= "1111001";
      when "0010"             => -- '2'
        O_HEX_N_BUF(13 downto 7) <= "0100100";
      when "0011"             => -- '3'
        O_HEX_N_BUF(13 downto 7) <= "0110000";
      when "0100"             => -- '4'
        O_HEX_N_BUF(13 downto 7) <= "0011001";
      when "0101"             => -- '5'
        O_HEX_N_BUF(13 downto 7) <= "0010010";
      when "0110"             => -- '6'
        O_HEX_N_BUF(13 downto 7) <= "0000010";
      when "0111"             => -- '7'
        O_HEX_N_BUF(13 downto 7) <= "1111000";
      when "1000"             => -- '8'
        O_HEX_N_BUF(13 downto 7) <= "0000000";
      when "1001"             => -- '9'
        O_HEX_N_BUF(13 downto 7) <= "0010000";
      when "1010"             => -- 'A'
        O_HEX_N_BUF(13 downto 7) <= "0001000";
      when "1011"             => -- 'B'
        O_HEX_N_BUF(13 downto 7) <= "0000011";
      when "1100"             => -- 'C'
        O_HEX_N_BUF(13 downto 7) <= "1000110";
      when "1101"             => -- 'D'
        O_HEX_N_BUF(13 downto 7) <= "0100001";
      when "1110"             => -- 'E'
        O_HEX_N_BUF(13 downto 7) <= "0000110";
      when "1111"             => -- 'F'
        O_HEX_N_BUF(13 downto 7) <= "0001110";
      when others             => -- ' '
        O_HEX_N_BUF(13 downto 7) <= "1111111";
    end case;

		case(I_COUNT(11 downto 8)) is
      when "0000"             => -- '0'
        O_HEX_N_BUF(20 downto 14) <= "1000000";
      when "0001"             => -- '1'
        O_HEX_N_BUF(20 downto 14) <= "1111001";
      when "0010"             => -- '2'
        O_HEX_N_BUF(20 downto 14) <= "0100100";
      when "0011"             => -- '3'
        O_HEX_N_BUF(20 downto 14) <= "0110000";
      when "0100"             => -- '4'
        O_HEX_N_BUF(20 downto 14) <= "0011001";
      when "0101"             => -- '5'
        O_HEX_N_BUF(20 downto 14) <= "0010010";
      when "0110"             => -- '6'
        O_HEX_N_BUF(20 downto 14) <= "0000010";
      when "0111"             => -- '7'
        O_HEX_N_BUF(20 downto 14) <= "1111000";
      when "1000"             => -- '8'
        O_HEX_N_BUF(20 downto 14) <= "0000000";
      when "1001"             => -- '9'
        O_HEX_N_BUF(20 downto 14) <= "0010000";
      when "1010"             => -- 'A'
        O_HEX_N_BUF(20 downto 14) <= "0001000";
      when "1011"             => -- 'B'
        O_HEX_N_BUF(20 downto 14) <= "0000011";
      when "1100"             => -- 'C'
        O_HEX_N_BUF(20 downto 14) <= "1000110";
      when "1101"             => -- 'D'
        O_HEX_N_BUF(20 downto 14) <= "0100001";
      when "1110"             => -- 'E'
        O_HEX_N_BUF(20 downto 14) <= "0000110";
      when "1111"             => -- 'F'
        O_HEX_N_BUF(20 downto 14) <= "0001110";
      when others             => -- ' '
        O_HEX_N_BUF(20 downto 14) <= "1111111";
    end case;

		case(I_COUNT(15 downto 12)) is
      when "0000"             => -- '0'
        O_HEX_N_BUF(27 downto 21) <= "1000000";
      when "0001"             => -- '1'
        O_HEX_N_BUF(27 downto 21) <= "1111001";
      when "0010"             => -- '2'
        O_HEX_N_BUF(27 downto 21) <= "0100100";
      when "0011"             => -- '3'
        O_HEX_N_BUF(27 downto 21) <= "0110000";
      when "0100"             => -- '4'
        O_HEX_N_BUF(27 downto 21) <= "0011001";
      when "0101"             => -- '5'
        O_HEX_N_BUF(27 downto 21) <= "0010010";
      when "0110"             => -- '6'
        O_HEX_N_BUF(27 downto 21) <= "0000010";
      when "0111"             => -- '7'
        O_HEX_N_BUF(27 downto 21) <= "1111000";
      when "1000"             => -- '8'
        O_HEX_N_BUF(27 downto 21) <= "0000000";
      when "1001"             => -- '9'
        O_HEX_N_BUF(27 downto 21) <= "0010000";
      when "1010"             => -- 'A'
        O_HEX_N_BUF(27 downto 21) <= "0001000";
      when "1011"             => -- 'B'
        O_HEX_N_BUF(27 downto 21) <= "0000011";
      when "1100"             => -- 'C'
        O_HEX_N_BUF(27 downto 21) <= "1000110";
      when "1101"             => -- 'D'
        O_HEX_N_BUF(27 downto 21) <= "0100001";
      when "1110"             => -- 'E'
        O_HEX_N_BUF(27 downto 21) <= "0000110";
      when "1111"             => -- 'F'
        O_HEX_N_BUF(27 downto 21) <= "0001110";
      when others             => -- ' '
        O_HEX_N_BUF(27 downto 21) <= "1111111";
    end case;

		case(I_DATA_ADDR(3 downto 0)) is
        when "0000"             => -- '0'
          O_DATA_ADDR_BUF(6 downto 0) <= "1000000";
        when "0001"             => -- '1'
          O_DATA_ADDR_BUF(6 downto 0) <= "1111001";
        when "0010"             => -- '2'
          O_DATA_ADDR_BUF(6 downto 0) <= "0100100";
        when "0011"             => -- '3'
          O_DATA_ADDR_BUF(6 downto 0) <= "0110000";
        when "0100"             => -- '4'
          O_DATA_ADDR_BUF(6 downto 0) <= "0011001";
        when "0101"             => -- '5'
          O_DATA_ADDR_BUF(6 downto 0) <= "0010010";
        when "0110"             => -- '6'
          O_DATA_ADDR_BUF(6 downto 0) <= "0000010";
        when "0111"             => -- '7'
          O_DATA_ADDR_BUF(6 downto 0) <= "1111000";
        when "1000"             => -- '8'
          O_DATA_ADDR_BUF(6 downto 0) <= "0000000";
        when "1001"             => -- '9'
          O_DATA_ADDR_BUF(6 downto 0) <= "0010000";
        when "1010"             => -- 'A'
          O_DATA_ADDR_BUF(6 downto 0) <= "0001000";
        when "1011"             => -- 'B'
          O_DATA_ADDR_BUF(6 downto 0) <= "0000011";
        when "1100"             => -- 'C'
          O_DATA_ADDR_BUF(6 downto 0) <= "1000110";
        when "1101"             => -- 'D'
          O_DATA_ADDR_BUF(6 downto 0) <= "0100001";
        when "1110"             => -- 'E'
          O_DATA_ADDR_BUF(6 downto 0) <= "0000110";
        when "1111"             => -- 'F'
          O_DATA_ADDR_BUF(6 downto 0) <= "0001110";
        when others             => -- ' '
          O_DATA_ADDR_BUF(6 downto 0) <= "1111111";
      end case;

		case(I_DATA_ADDR(7 downto 4)) is
      when "0000"             => -- '0'
        O_DATA_ADDR_BUF(13 downto 7) <= "1000000";
      when "0001"             => -- '1'
        O_DATA_ADDR_BUF(13 downto 7) <= "1111001";
      when "0010"             => -- '2'
        O_DATA_ADDR_BUF(13 downto 7) <= "0100100";
      when "0011"             => -- '3'
        O_DATA_ADDR_BUF(13 downto 7) <= "0110000";
      when "0100"             => -- '4'
        O_DATA_ADDR_BUF(13 downto 7) <= "0011001";
      when "0101"             => -- '5'
        O_DATA_ADDR_BUF(13 downto 7) <= "0010010";
      when "0110"             => -- '6'
        O_DATA_ADDR_BUF(13 downto 7) <= "0000010";
      when "0111"             => -- '7'
        O_DATA_ADDR_BUF(13 downto 7) <= "1111000";
      when "1000"             => -- '8'
        O_DATA_ADDR_BUF(13 downto 7) <= "0000000";
      when "1001"             => -- '9'
        O_DATA_ADDR_BUF(13 downto 7) <= "0010000";
      when "1010"             => -- 'A'
        O_DATA_ADDR_BUF(13 downto 7) <= "0001000";
      when "1011"             => -- 'B'
        O_DATA_ADDR_BUF(13 downto 7) <= "0000011";
      when "1100"             => -- 'C'
        O_DATA_ADDR_BUF(13 downto 7) <= "1000110";
      when "1101"             => -- 'D'
        O_DATA_ADDR_BUF(13 downto 7) <= "0100001";
      when "1110"             => -- 'E'
        O_DATA_ADDR_BUF(13 downto 7) <= "0000110";
      when "1111"             => -- 'F'
        O_DATA_ADDR_BUF(13 downto 7) <= "0001110";
      when others             => -- ' '
        O_DATA_ADDR_BUF(13 downto 7) <= "1111111";
    end case;
      O_HEX_N <= O_HEX_N_BUF;
		  O_DATA_ADDR <= O_DATA_ADDR_BUF;

    end if;
  end process quad_hex_driver;

 end architecture behavioral;
