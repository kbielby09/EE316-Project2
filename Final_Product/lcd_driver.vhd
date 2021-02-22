-----------------
--  Libraries  --
-----------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

--------------
--  Entity  --
--------------
entity lcd_driver is
    port(
        -- Clock and reset Signals
        I_RESET_N   : in std_logic;
        I_CLK_50MHZ : in std_logic;

        -- Data
        INPUT_DATA   : in std_logic_vector(31 downto 0);
        INPUT_ADDR   : in std_logic_vector(15 downto 0);
        CURRENT_MODE : in  std_logic_vector(1 downto 0);
        FREQUENCY    : in std_logic_vector(1 downto 0);
        DATA_CHANGE  : in std_logic;

        -- Outputs to LCD display
        LCD_RW      : out std_logic;
        LCD_EN      : out std_logic;
        LCD_RS      : out std_logic;
        LCD_DATA    : out std_logic_vector(7 downto 0);
        LCD_ON      : out std_logic;
        LCD_BLON    : out std_logic
    );
end lcd_driver;

--------------------------------
--  Architecture Declaration  --
--------------------------------
architecture rtl of lcd_driver is

    -- Signals for user output
    signal enable_counter        : unsigned(11 downto 0);
    signal lcd_enable            : std_logic;
    signal previous_enable_value : std_logic;

    signal sixteen_ms_count         : unsigned(19 downto 0);
    signal sixteen_ms_elapse        : std_logic := '0';
    signal five_ms_elapse           : std_logic := '0';
    signal one_hundred_micro_elapse : std_logic := '0';
    signal first_three              : std_logic := '0';
    signal forty_four_micro_elapse  : std_logic := '0';

    signal lcd_initialized          : std_logic := '0';

    signal active_digit : unsigned(5 downto 0) := (others => '0');
    signal previous_active_digit : unsigned(5 downto 0) := (others => '0');

    signal next_digit : std_logic_vector(7 downto 0);
    signal init_digit : std_logic_vector(7 downto 0);

    signal command_count : unsigned(1 downto 0) := "00";

    type LINE_DIGIT is (
      DIGIT0,
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

    type INIT_STATE is (
        INIT0,
        INIT1,
        INIT2,
        INIT3,
        INIT4,
        INIT5,
        INIT6,
        INIT7
    );

    signal lcd_init_state : INIT_STATE := INIT0;

    begin

      -- Process to count for approximately 230ns
      EN_COUNTER : process(I_CLK_50MHZ, I_RESET_N)
          begin
            if (I_RESET_N = '0') then
              enable_counter <= (others => '0');
              lcd_enable <= '0';
              previous_enable_value <= '0';
            elsif (rising_edge(I_CLK_50MHZ)) then
              if (current_digit /= DIGIT32)  then
                previous_enable_value <= lcd_enable;
                enable_counter <= enable_counter + 1;
                if (enable_counter = X"0") then
                  lcd_enable <= '1';
                elsif (enable_counter = X"C") then
                  lcd_enable <= '0';
                elsif (enable_counter = X"867") then
                  enable_counter <= (others => '0');
                end if;
              elsif (current_digit = DIGIT32 and DATA_CHANGE = '1') then
                previous_enable_value <= '1';
                lcd_enable <= '0';
              end if;
            end if;
      end process EN_COUNTER;

      INIT_COUNTER : process(I_CLK_50MHZ, I_RESET_N)
        begin
          if (I_RESET_N = '0') then
            sixteen_ms_elapse <= '0';
            five_ms_elapse    <= '0';
            one_hundred_micro_elapse <= '0';
            sixteen_ms_count  <= (others => '0');
          elsif (rising_edge(I_CLK_50MHZ)) then
            if (lcd_initialized = '0') then
              sixteen_ms_count        <= sixteen_ms_count + 1;
              forty_four_micro_elapse <= '0';

              if (sixteen_ms_count = "11000011010100000000"
                  and lcd_init_state = INIT0) then
                sixteen_ms_elapse <= '1';
                sixteen_ms_count <= (others => '0');

              elsif (sixteen_ms_count = "111101000010010000"
                     and lcd_init_state = INIT1) then
                five_ms_elapse <= '1';
                sixteen_ms_count <= (others => '0');

              elsif (sixteen_ms_count = "1001110111010"
                     and lcd_init_state = INIT2) then
                  one_hundred_micro_elapse <= '1';
                  sixteen_ms_count <= (others => '0');

              elsif (sixteen_ms_count = "100010011000"
                     and (lcd_init_state = INIT3
                          or lcd_init_state = INIT4
                          or lcd_init_state = INIT5
                          or lcd_init_state = INIT6
                          or lcd_init_state = INIT7)) then
                forty_four_micro_elapse <= '1';
                sixteen_ms_count <= (others => '0');
              end if;
            end if;
          end if;
      end process INIT_COUNTER;

      -- Process to change the state of the LCD
      DISPLAY_STATE : process(I_CLK_50MHZ, I_RESET_N)
        begin
          if (I_RESET_N = '0') then
            lcd_init_state <= INIT0;
            lcd_initialized <= '0';
          elsif (rising_edge(I_CLK_50MHZ)) then
            case(lcd_init_state) is
              when INIT0 =>
                if (sixteen_ms_elapse = '1') then
                  lcd_init_state <= INIT1;
                end if;

              when INIT1 =>
                if (five_ms_elapse = '1') then
                  lcd_init_state <= INIT2;
                end if;

              when INIT2 =>
                if (one_hundred_micro_elapse = '1') then
                  lcd_init_state <= INIT3;
                end if;

              when INIT3 =>
                if (forty_four_micro_elapse = '1') then
                  lcd_init_state <= INIT4;
                end if;

              when INIT4 =>
                if (forty_four_micro_elapse = '1') then
                  lcd_init_state <= INIT5;
                end if;

              when INIT5 =>
                if (forty_four_micro_elapse = '1') then
                  lcd_init_state <= INIT6;
                end if;

              when INIT6 =>
                if (forty_four_micro_elapse = '1') then
                  lcd_init_state <= INIT7;
                end if;

              when INIT7 =>
                if (forty_four_micro_elapse = '1') then
                  lcd_initialized   <= '1';
                end if;
            end case;
          end if;
      end process;

      DIGIT_STATE : process(I_CLK_50MHZ, I_RESET_N)
        begin
          if (I_RESET_N = '0') then
            current_digit <= DIGIT0;
          elsif (rising_edge(I_CLK_50MHZ)) then
            if (lcd_initialized = '1'
                and lcd_enable = '0'
                and previous_enable_value = '1') then
              if (DATA_CHANGE = '1') then
                current_digit <= DIGIT0;
              end if;

              case (current_digit) is
                when DIGIT0 =>
                  current_digit <= DIGIT1;
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
                  -- wait for display data change
              end case;
            end if;
          end if;
      end process DIGIT_STATE;

      -- Process to display data on lcd depending on mode of operation
      DISPLAY_VALUE : process(I_CLK_50MHZ, I_RESET_N)
        begin
          if (rising_edge(I_CLK_50MHZ)) then
            case( lcd_init_state ) is
              when INIT0 =>
                    -- waiting for VCC to rise
              when INIT1 =>
                  init_digit <= "00110000";
              when INIT2 =>
                  init_digit <= "00110000";

             when INIT3 =>
                 init_digit <= "00110000";

             when INIT4 =>
                 init_digit <= "00111000";

             when INIT5 =>
                 init_digit <= "00001111";

             when INIT6 =>
                 init_digit <= "00000001";

             when INIT7 =>
                 init_digit <= "00000110";
            end case;
          end if;
      end process;

      CHANGE_LINE : process(I_CLK_50MHZ, I_RESET_N)
      begin
        if (I_RESET_N = '0') then
          command_count <= (others => '0');
        elsif (rising_edge(I_CLK_50MHZ)) then
          if (enable_counter = X"867" and current_digit = DIGIT16) then
            command_count <= command_count + 1;
          end if;
        end if;
      end process;

      CURRENT_STATE : process(I_CLK_50MHZ, I_RESET_N)
      begin
        if (I_RESET_N = '0') then
        elsif (rising_edge(I_CLK_50MHZ)) then
          if (lcd_initialized = '1'
              and lcd_enable = '1') then
            case( CURRENT_MODE ) is
              when "00" => -- Initializing state
                case( current_digit ) is
                  when DIGIT0 =>
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
                    next_digit <= X"C0";
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
                    -- if (command_count = "01") then
                      next_digit <= X"C0";
                    -- end if;
                  when DIGIT17 =>
                    next_digit <= INPUT_ADDR(15 downto 8);
                  when DIGIT18 =>
                    next_digit <= INPUT_ADDR(7 downto 0);
                  when DIGIT19 =>
                    next_digit <= "00100000"; -- space
                  when DIGIT20 =>
                    next_digit <= INPUT_DATA(31 downto 24);
                  when DIGIT21 =>
                    next_digit <= INPUT_DATA(23 downto 16);
                  when DIGIT22 =>
                    next_digit <= INPUT_DATA(15 downto 8);
                  when DIGIT23 =>
                    next_digit <= INPUT_DATA(7 downto 0);
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
                    -- if (command_count = "01") then
                      next_digit <= X"C0"; -- switch to line 2
                    -- end if;
                  when DIGIT17 =>
                    next_digit <= INPUT_ADDR(15 downto 8);
                  when DIGIT18 =>
                    next_digit <= INPUT_ADDR(7 downto 0);
                  when DIGIT19 =>
                    next_digit <= "00100000"; -- space
                  when DIGIT20 =>
                    next_digit <= INPUT_DATA(31 downto 24);
                  when DIGIT21 =>
                    next_digit <= INPUT_DATA(23 downto 16);
                  when DIGIT22 =>
                    next_digit <= INPUT_DATA(15 downto 8);
                  when DIGIT23 =>
                    next_digit <= INPUT_DATA(7 downto 0);
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
                    -- if (command_count = "01") then
                      next_digit <= X"C0";
                    -- end if;
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
        end if;
      end process;

      LCD_ON   <= '1';
      LCD_BLON <= '1';
      -- LCD_EN <= '0' when next_digit = X"C0" else lcd_enable;
      LCD_EN <= lcd_enable;
      LCD_DATA <= init_digit when lcd_initialized = '0'
             else next_digit;
      -- LCD_RS <= '0' when lcd_initialized = '0'  else '1';
      LCD_RS <= '0' when lcd_initialized = '0' or current_digit = DIGIT16  else '1';
      LCD_RW <= '0';

end rtl;
