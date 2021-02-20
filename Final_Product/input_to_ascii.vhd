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

    CURRENT_MODE : in  std_logic_vector(1 downto 0);
    FREQUENCY    : in std_logic_vector(1 downto 0);

    LCD_RW      : out std_logic;
    LCD_EN      : out std_logic;
    LCD_RS      : out std_logic;
    LCD_DATA    : out std_logic_vector(7 downto 0);
    LCD_ON      : out std_logic;
    LCD_BLON    : out std_logic;

    -- Address and data
    INPUT_ADDR :  in std_logic_vector(7 downto 0);
    INPUT_DATA :  in std_logic_vector(15 downto 0)

  );
end entity;

architecture rtl of input_to_ascii is
  component lcd_driver is
    port(
      I_RESET_N   : in std_logic;
      I_CLK_50MHZ : in std_logic;
      INPUT_DATA : in std_logic_vector(7 downto 0);
      NEW_DATA   : in std_logic;
      READY       : out std_logic := '0';
      LCD_RW      : out std_logic;
      LCD_EN      : out std_logic;
      LCD_RS      : out std_logic;
      LCD_DATA    : out std_logic_vector(7 downto 0);
      LCD_ON      : out std_logic;
      LCD_BLON    : out std_logic
    );
  end component lcd_driver;

  -- type WRITE_DIGIT_STATE is (
  --   DIGIT1,
  --   DIGIT2,
  --   DIGIT3,
  --   DIGIT4,
  --   DIGIT5,
  --   DIGIT6,
  --   DIGIT7,
  --   DIGIT8,
  --   DIGIT9,
  --   DIGIT10,
  --   DIGIT11,
  --   DIGIT12
  -- );
  --
  -- signal current_digit : WRITE_DIGIT_STATE := DIGIT1;

  type LINE_DIGIT is (
    DIGIT1,
    DIGIT2,
    DIGIT3,
    DIGIT4,
    DIGIT5,
    DIGIT6,
    DIGIT7,
    DIGIT8,
    DIGIT9,
    DIGIT10,
    DIGIT11,
    DIGIT12,
    DIGIT13,
    DIGIT14,
    DIGIT15,
    DIGIT16,
    DIGIT17,
    DIGIT18,
    DIGIT19,
    DIGIT20,
    DIGIT21,
    DIGIT22,
    DIGIT23,
    DIGIT24,
    DIGIT25,
    DIGIT26,
    DIGIT27,
    DIGIT28,
    DIGIT29,
    DIGIT30,
    DIGIT31,
    DIGIT32
  );

  signal current_digit : LINE_DIGIT := DIGIT1;

  signal data_ascii_out    : std_logic_vector(31 downto 0) := (others => '0');
  signal addr_ascii_out    : std_logic_vector(15 downto 0) := (others => '0');
  signal next_digit        : std_logic_vector(7 downto 0);
  signal new_input_digit   : std_logic;
  -- signal lcd_init_success  : std_logic;
  signal lcd_ready         : std_logic;
  -- signal display_pause     : std_logic := '0';

begin
  LCD_ENTITY : lcd_driver
  port map(
    I_RESET_N   => I_RESET_N,
    I_CLK_50MHZ => I_CLK_50MHZ,
    INPUT_DATA => next_digit,
    NEW_DATA   => new_input_digit,
    READY     => lcd_ready,
    LCD_RW      => LCD_RW,
    LCD_EN      => LCD_EN,
    LCD_RS      => LCD_RS,
    LCD_DATA    => LCD_DATA,
    LCD_ON      => LCD_ON,
    LCD_BLON    => LCD_BLON
  );

  CURRENT_STATE : process(I_CLK_50MHZ, I_RESET_N)
  begin
    if (I_RESET_N = '0') then
    elsif (rising_edge(I_CLK_50MHZ)) then
      case( CURRENT_MODE ) is
        when "00" => -- Initializing state
          case( current_digit ) is
            when DIGIT1 =>
              next_digit <= "01001001"; -- I
            when DIGIT2 =>
              next_digit <= "01101110"; -- n
            when DIGIT3 =>
              next_digit <= "01101001"; -- i
            when DIGIT4 =>
              next_digit <= "01110100"; -- t
            when DIGIT5 =>
              next_digit <= "01101001"; -- i
            when DIGIT6 =>
              next_digit <= "01100001"; -- a
            when DIGIT7 =>
              next_digit <= "01101100"; -- l
            when DIGIT8 =>
              next_digit <= "01101001"; -- i
            when DIGIT9 =>
              next_digit <= "01111010"; -- z
            when DIGIT10 =>
              next_digit <= "01101001"; -- i
            when DIGIT11 =>
              next_digit <= "01101110"; -- n
            when DIGIT12 =>
              next_digit <= "01100111"; -- g
            when DIGIT13 =>
              next_digit <= "00100000"; -- space
            when DIGIT14 =>
              next_digit <= "00100000"; -- space
            when DIGIT15 =>
              next_digit <= "00100000"; -- space
            when DIGIT16 =>
              next_digit <= "00100000"; -- space
            when DIGIT17 =>
              next_digit <= "00100000"; -- space
            when DIGIT18 =>
              next_digit <= "00100000"; -- space
            when DIGIT19 =>
              next_digit <= "00100000"; -- space
            when DIGIT20 =>
              next_digit <= "00100000"; -- space
            when DIGIT21 =>
              next_digit <= "00100000"; -- space
            when DIGIT22 =>
              next_digit <= "00100000"; -- space
            when DIGIT23 =>
              next_digit <= "00100000"; -- space
            when DIGIT24 =>
              next_digit <= "00100000"; -- space
            when DIGIT25 =>
              next_digit <= "00100000"; -- space
            when DIGIT26 =>
              next_digit <= "00100000"; -- space
            when DIGIT27 =>
              next_digit <= "00100000"; -- space
            when DIGIT28 =>
              next_digit <= "00100000"; -- space
            when DIGIT29 =>
              next_digit <= "00100000"; -- space
            when DIGIT30 =>
              next_digit <= "00100000"; -- space
            when DIGIT31 =>
              next_digit <= "00100000"; -- space
            when DIGIT32 =>
              next_digit <= "00100000"; -- space
            when others =>
          end case;
        when "01" => -- test state
          case( current_digit ) is
            when DIGIT1 =>
              next_digit <= "01010100"; -- T
            when DIGIT2 =>
              next_digit <= "01100101"; -- e
            when DIGIT3 =>
              next_digit <= "01110011"; -- s
            when DIGIT4 =>
              next_digit <= "01110100"; -- t
            when DIGIT5 =>
              next_digit <= "00100000"; -- space
            when DIGIT6 =>
              next_digit <= "01001101"; -- M
            when DIGIT7 =>
              next_digit <= "01101111"; -- o
            when DIGIT8 =>
              next_digit <= "01100100"; -- d
            when DIGIT9 =>
              next_digit <= "01100101"; -- e
            when DIGIT10 =>
              next_digit <= "00100000"; -- space
            when DIGIT11 =>
              next_digit <= "00100000"; -- space
            when DIGIT12 =>
              next_digit <= "00100000"; -- space
            when DIGIT13 =>
              next_digit <= "00100000"; -- space
            when DIGIT14 =>
              next_digit <= "00100000"; -- space
            when DIGIT15 =>
              next_digit <= "00100000"; -- space
            when DIGIT16 =>
              next_digit <= "00100000"; -- space
            when DIGIT17 =>
              next_digit <= addr_ascii_out(15 downto 8);
            when DIGIT18 =>
              next_digit <= addr_ascii_out(7 downto 0);
            when DIGIT19 =>
              next_digit <= "00100000"; -- space
            when DIGIT20 =>
              next_digit <= data_ascii_out(31 downto 24);
            when DIGIT21 =>
              next_digit <= data_ascii_out(23 downto 16);
            when DIGIT22 =>
              next_digit <= data_ascii_out(15 downto 8);
            when DIGIT23 =>
              next_digit <= data_ascii_out(7 downto 0);
            when DIGIT24 =>
              next_digit <= "00100000"; -- space
            when DIGIT25 =>
              next_digit <= "00100000"; -- space
            when DIGIT26 =>
              next_digit <= "00100000"; -- space
            when DIGIT27 =>
              next_digit <= "00100000"; -- space
            when DIGIT28 =>
              next_digit <= "00100000"; -- space
            when DIGIT29 =>
              next_digit <= "00100000"; -- space
            when DIGIT30 =>
              next_digit <= "00100000"; -- space
            when DIGIT31 =>
              next_digit <= "00100000"; -- space
            when DIGIT32 =>
              next_digit <= "00100000"; -- space
            when others =>
          end case;
        when "10" => -- Pause state
          case( current_digit ) is
            when DIGIT1 =>
              next_digit <= "01010000"; -- P
            when DIGIT2 =>
              next_digit <= "01100001"; -- a
            when DIGIT3 =>
              next_digit <= "01110101"; -- u
            when DIGIT4 =>
              next_digit <= "01110011"; -- s
            when DIGIT5 =>
              next_digit <= "01100101"; -- e
            when DIGIT6 =>
              next_digit <= "00100000"; -- space
            when DIGIT7 =>
              next_digit <= "01001101"; -- M
            when DIGIT8 =>
              next_digit <= "01101111"; -- o
            when DIGIT9 =>
              next_digit <= "01100100"; -- d
            when DIGIT10 =>
              next_digit <= "01100101"; -- e
            when DIGIT11 =>
              next_digit <= "00100000"; -- space
            when DIGIT12 =>
              next_digit <= "00100000"; -- space
            when DIGIT13 =>
              next_digit <= "00100000"; -- space
            when DIGIT14 =>
              next_digit <= "00100000"; -- space
            when DIGIT15 =>
              next_digit <= "00100000"; -- space
            when DIGIT16 =>
              next_digit <= "00100000"; -- space
            when DIGIT17 =>
              next_digit <= addr_ascii_out(15 downto 8);
            when DIGIT18 =>
              next_digit <= addr_ascii_out(7 downto 0);
            when DIGIT19 =>
              next_digit <= "00100000"; -- space
            when DIGIT20 =>
              next_digit <= data_ascii_out(31 downto 24);
            when DIGIT21 =>
              next_digit <= data_ascii_out(23 downto 16);
            when DIGIT22 =>
              next_digit <= data_ascii_out(15 downto 8);
            when DIGIT23 =>
              next_digit <= data_ascii_out(7 downto 0);
            when DIGIT24 =>
              next_digit <= "00100000"; -- space
            when DIGIT25 =>
              next_digit <= "00100000"; -- space
            when DIGIT26 =>
              next_digit <= "00100000"; -- space
            when DIGIT27 =>
              next_digit <= "00100000"; -- space
            when DIGIT28 =>
              next_digit <= "00100000"; -- space
            when DIGIT29 =>
              next_digit <= "00100000"; -- space
            when DIGIT30 =>
              next_digit <= "00100000"; -- space
            when DIGIT31 =>
              next_digit <= "00100000"; -- space
            when DIGIT32 =>
              next_digit <= "00100000"; -- space
            when others =>
          end case;
        when "11" => -- PWM Generation State
          case( current_digit ) is
            when DIGIT1 =>
              next_digit <= "01010000"; -- P
            when DIGIT2 =>
              next_digit <= "01010111"; -- W
            when DIGIT3 =>
              next_digit <= "01001101"; -- M
            when DIGIT4 =>
              next_digit <= "00100000"; -- space
            when DIGIT5 =>
              next_digit <= "01000111"; -- G
            when DIGIT6 =>
              next_digit <= "01100101"; -- e
            when DIGIT7 =>
              next_digit <= "01101110"; -- n
            when DIGIT8 =>
              next_digit <= "01100101"; -- e
            when DIGIT9 =>
              next_digit <= "01110010"; -- r
            when DIGIT10 =>
              next_digit <= "01100001"; -- a
            when DIGIT11 =>
              next_digit <= "01110100"; -- t
            when DIGIT12 =>
              next_digit <= "01101001"; -- i
            when DIGIT13 =>
              next_digit <= "01101111"; -- o
            when DIGIT14 =>
              next_digit <= "01101110"; -- n
            when DIGIT15 =>
              next_digit <= "00100000"; -- space
            when DIGIT16 =>
              next_digit <= "00100000"; -- space
            when DIGIT17 =>
              case( frequency ) is
                when "00" =>
                  next_digit <= "00110110"; -- 6
                when "01" =>
                  next_digit <= "00110001"; -- 1
                when "10" =>
                  next_digit <= "00110001"; -- 1
                when others =>
              end case;
            when DIGIT18 =>
              case( frequency ) is
                when "00" =>
                  next_digit <= "00110000"; -- 0
                when "01" =>
                  next_digit <= "00110010"; -- 2
                when "10" =>
                  next_digit <= "00110000";  -- 0
                when others =>
              end case;
            when DIGIT19 =>
              case( frequency ) is
                when "00" =>
                  next_digit <= "00100000"; -- space
                when "01" =>
                  next_digit <= "00110000"; -- 0
                when "10" =>
                  next_digit <= "00110000"; -- 0
                when others =>
              end case;
            when DIGIT20 =>
              case( frequency ) is
                when "00" =>
                  next_digit <= "01001000"; -- H
                when "01" =>
                  next_digit <= "00100000"; -- space
                when "10" =>
                  next_digit <= "00110000"; -- 0
                when others =>
              end case;
            when DIGIT21 =>
              case( frequency ) is
                when "00" =>
                  next_digit <= "01111010"; -- z
                when "01" =>
                  next_digit <= "01001000"; -- H
                when "10" =>
                  next_digit <= "00100000"; -- space
                when others =>
              end case;
            when DIGIT22 =>
              case( frequency ) is
                when "00" =>
                  next_digit <= "00100000"; -- space
                when "01" =>
                  next_digit <= "01111010"; -- z
                when "10" =>
                  next_digit <= "01001000"; -- H
                when others =>
              end case;
            when DIGIT23 =>
              case( frequency ) is
                when "00" =>
                  next_digit <= "00100000"; -- space
                when "01" =>
                  next_digit <= "00100000"; -- space
                when "10" =>
                  next_digit <= "01111010"; -- z
                when others =>
              end case;
            when DIGIT24 =>
              next_digit <= "00100000"; -- space
            when DIGIT25 =>
              next_digit <= "00100000"; -- space
            when DIGIT26 =>
              next_digit <= "00100000"; -- space
            when DIGIT27 =>
              next_digit <= "00100000"; -- space
            when DIGIT28 =>
              next_digit <= "00100000"; -- space
            when DIGIT29 =>
              next_digit <= "00100000"; -- space
            when DIGIT30 =>
              next_digit <= "00100000"; -- space
            when DIGIT31 =>
              next_digit <= "00100000"; -- space
            when DIGIT32 =>
              next_digit <= "00100000"; -- space
            when others =>
          end case;
      end case;
    end if;

  end process;

  DIGIT_STATE : process(I_CLK_50MHZ, I_RESET_N)
    begin
      if (I_RESET_N = '0') then
        current_digit <= DIGIT1;
        new_input_digit <= '0';
      elsif (rising_edge(I_CLK_50MHZ)) then
        if (lcd_ready = '1') then
          new_input_digit <= '1';
          case (current_digit) is
            when DIGIT1 =>
              current_digit <= DIGIT2;
            when DIGIT2 =>
              current_digit <= DIGIT3;
            when DIGIT3 =>
              current_digit <= DIGIT4;
            when DIGIT4 =>
              current_digit <= DIGIT5;
            when DIGIT5 =>
              current_digit <= DIGIT6;
            when DIGIT6 =>
              current_digit <= DIGIT7;
            when DIGIT7 =>
              current_digit <= DIGIT8;
            when DIGIT8 =>
              current_digit <= DIGIT9;
            when DIGIT9 =>
              current_digit <= DIGIT10;
            when DIGIT10 =>
              current_digit <= DIGIT11;
            when DIGIT11 =>
              current_digit <= DIGIT12;
            when DIGIT12 =>
              current_digit <= DIGIT13;
            when DIGIT13 =>
              current_digit <= DIGIT14;
            when DIGIT14 =>
              current_digit <= DIGIT15;
            when DIGIT15 =>
              current_digit <= DIGIT16;
            when DIGIT16 =>
              current_digit <= DIGIT17;
            when DIGIT17 =>
              current_digit <= DIGIT18;
            when DIGIT18 =>
              current_digit <= DIGIT19;
            when DIGIT19 =>
              current_digit <= DIGIT20;
            when DIGIT20 =>
              current_digit <= DIGIT21;
            when DIGIT21 =>
              current_digit <= DIGIT22;
            when DIGIT22 =>
              current_digit <= DIGIT23;
            when DIGIT23 =>
              current_digit <= DIGIT24;
            when DIGIT24 =>
              current_digit <= DIGIT25;
            when DIGIT25 =>
              current_digit <= DIGIT26;
            when DIGIT26 =>
              current_digit <= DIGIT27;
            when DIGIT27 =>
              current_digit <= DIGIT28;
            when DIGIT28 =>
              current_digit <= DIGIT29;
            when DIGIT29 =>
              current_digit <= DIGIT30;
            when DIGIT30 =>
              current_digit <= DIGIT31;
            when DIGIT31 =>
              current_digit <= DIGIT32;
            when DIGIT32 =>
              current_digit <= DIGIT1;
          end case;
        else
          new_input_digit <= '0';
        end if;
      end if;
  end process DIGIT_STATE;

  -- DIGIT_WRITE : process(I_CLK_50MHZ, I_RESET_N)
  --   begin
  --     if (I_RESET_N = '0') then
  --       display_pause <= '0';
  --       next_digit    <= (others => '0');
  --     elsif (rising_edge(I_CLK_50MHZ)) then
  --       if (lcd_init_success = '1') then
  --       -- previous_lcd_state <= lcd_ready;
  --       -- if (lcd_ready = '1') then
  --         case( current_digit ) is
  --           when DIGIT1 =>
  --             display_pause <= '0';
  --             next_digit <= "01000001"; --addr_ascii_out(15 downto 8);
  --           when DIGIT2 =>
  --             next_digit <= "01000001"; --addr_ascii_out(7 downto 0);
  --           when DIGIT3 =>
  --             next_digit <= "00100000";
  --           when DIGIT4 =>
  --             next_digit <= "01000001"; --data_ascii_out(31 downto 24);
  --           when DIGIT5 =>
  --             next_digit <= "01000001"; --data_ascii_out(23 downto 16);
  --           when DIGIT6 =>
  --             next_digit <= "01000001"; --data_ascii_out(15 downto 8);
  --           when DIGIT7 =>
  --             next_digit <= "01000001"; --data_ascii_out(7 downto 0);
  --           when DIGIT8 =>
  --             next_digit <= "01000110";
  --           when DIGIT9 =>
  --             next_digit <= "01000110";
  --           when DIGIT10 =>
  --             next_digit <= "01000110";
  --           when DIGIT11 =>
  --             next_digit <= "01000110";
  --           when DIGIT12 =>
  --             display_pause <= '1';
  --             next_digit <= "01000110";
  --         end case;
  --       end if;
  --     end if;
  -- end process DIGIT_WRITE;

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
