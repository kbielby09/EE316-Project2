-- LCD Driver

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

        -- Address and data
        INPUT_ADDR :  in std_logic_vector(7 downto 0);
        INPUT_DATA :  in std_logic_vector(15 downto 0);
        NEW_INPUT  :  in std_logic;
        READY      :  out std_logic;

        -- Control Inputs
        SYS_PAUSE    : in  std_logic;
        PWM_GEN_MODE : in  std_logic;

        -- Outputs to LCD display
        LCD_RW      : out std_logic;
        LCD_EN      : out std_logic;
        LCD_RS      : out std_logic;
        LCD_DATA    : out std_logic_vector(7 downto 0);
        LCD_ON      : out std_logic;
        LCD_BLON    : out std_logic;

        -- Output to top entity
        LCD_INITIALIZED : out std_logic
    );
end lcd_driver;

--------------------------------
--  Architecture Declaration  --
--------------------------------
architecture rtl of lcd_driver is

    -- Signals for LCD display state machine
    type LCD_STATE is (
        INIT,
        WRITE_DIGIT,
        WAITING
    );

    signal lcd_control_state : LCD_STATE := INIT;

    -- initialize states
    type INIT_STATE is (
      STEP0,
      STEP1,
      STEP2,
      STEP3,
      STEP4,
      STEP5,
      STEP6,
      STEP7
    );

    signal initialization_state : INIT_STATE := STEP0;

    -- Write digit states
    type WRITE_DIGIT_STATE is (
      CLEAR_DIGIT,
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
      DIGIT12
    );

    signal current_digit : WRITE_DIGIT_STATE := CLEAR_DIGIT;

    -- Signals for user output
    signal enable_counter        : unsigned(3 downto 0);
    signal lcd_enable            : std_logic;
    signal previous_enable_state : std_logic;
    signal lcd_ready             : std_logic;
    signal counter_pause : std_logic := '0';

    -- signal data_ascii_out    : std_logic_vector(31 downto 0) := (others => '0');
    signal data_ascii_out    : std_logic_vector(31 downto 0) := "01000110000000000000000001000110";
    signal addr_ascii_out    : std_logic_vector(15 downto 0) := (others => '0');

    -- signal prev_data         : std_logic_vector(15 downto 0);
    -- signal new_data          : std_logic_vector(15 downto 0);
    -- signal prev_addr         : std_logic_vector(7 downto 0);
    -- signal new_addr          : std_logic_vector(7 downto 0);

    signal sixteen_ms_count         : unsigned(19 downto 0);
    signal sixteen_ms_elapse        : std_logic := '0';
    signal five_ms_elapse           : std_logic := '0';
    signal one_hundred_micro_elapse : std_logic := '0';
    signal first_three              : std_logic := '0';
    signal forty_four_micro_elapse  : std_logic := '0';
    -- signal first_of_four            : unsigned(2 downto 0) := "000";

    begin

      -- Process to count for approximately 230ns
      EN_COUNTER : process(I_CLK_50MHZ, I_RESET_N)
          begin
            if (I_RESET_N = '0') then
              enable_counter <= (others => '0');
              lcd_enable <= '0';
              previous_enable_state <= '0';
            elsif (rising_edge(I_CLK_50MHZ)) then
              if (counter_pause = '0') then
                enable_counter <= enable_counter + 1;
                lcd_enable <= '1';
                previous_enable_state <= lcd_enable;
                -- Check for 230ns of elapsed time
                if (enable_counter = "1100") then
                  lcd_enable <= '0';
                end if;
              else
                lcd_enable <= '0';
                previous_enable_state <= '0';
              end if;
            end if;
      end process EN_COUNTER;

      -- Process to count for 16 ms for initialization Process
      INIT_COUNTER : process(I_CLK_50MHZ, I_RESET_N)
        begin
          if (I_RESET_N = '0') then
            sixteen_ms_elapse <= '0';
            five_ms_elapse    <= '0';
            one_hundred_micro_elapse <= '0';
            sixteen_ms_count  <= (others => '0');
          elsif (rising_edge(I_CLK_50MHZ)) then
            sixteen_ms_count        <= sixteen_ms_count + 1;
            forty_four_micro_elapse <= '0';

            if (sixteen_ms_count = "11000011010100000000"
                and initialization_state = STEP0) then
              sixteen_ms_elapse <= '1';
              sixteen_ms_count <= (others => '0');

            elsif (sixteen_ms_count = "111101000010010000"
                   and initialization_state = STEP1) then
              five_ms_elapse <= '1';
              sixteen_ms_count <= (others => '0');

            elsif (sixteen_ms_count = "1001110111010"
                   and initialization_state = STEP2) then
              one_hundred_micro_elapse <= '1';
              sixteen_ms_count <= (others => '0');

            elsif (sixteen_ms_count = "100010011000"
                   and (initialization_state = STEP3
                        or initialization_state = STEP4
                        or initialization_state = STEP5
                        or initialization_state = STEP6
                        or initialization_state = STEP7)) then
              forty_four_micro_elapse <= '1';
              sixteen_ms_count <= (others => '0');

            end if;
          end if;
      end process INIT_COUNTER;

      -- Process to change the state of the LCD
      DISPLAY_STATE : process(I_CLK_50MHZ, I_RESET_N, SYS_PAUSE, PWM_GEN_MODE, NEW_INPUT)
        begin
          if (I_RESET_N = '0') then
            lcd_control_state <= INIT;
          elsif (rising_edge(I_CLK_50MHZ)) then
            case( lcd_control_state ) is
              when INIT =>
                case( initialization_state ) is
                  when STEP0 =>
                    if (sixteen_ms_elapse = '1') then
                      initialization_state <= STEP1;
                    end if;
                  when STEP1 =>
                    if (five_ms_elapse = '1') then
                      initialization_state <= STEP2;
                    end if;
                  when STEP2 =>
                    if (one_hundred_micro_elapse = '1') then
                      initialization_state <= STEP3;
                    end if;
                  when STEP3 =>
                    if (forty_four_micro_elapse = '1') then
                      initialization_state <= STEP4;
                    end if;
                  when STEP4 =>
                    if (forty_four_micro_elapse = '1') then
                      initialization_state <= STEP5;
                    end if;
                  when STEP5 =>
                    if (forty_four_micro_elapse = '1') then
                      initialization_state <= STEP6;
                    end if;
                  when STEP6 =>
                    if (forty_four_micro_elapse = '1') then
                      initialization_state <= STEP7;
                    end if;
                  when STEP7 =>
                    if (forty_four_micro_elapse = '1') then
                      lcd_control_state <= WRITE_DIGIT;
                    end if;
                end case;

              -- when READY1 =>
              --   if (lcd_enable = '1') then
              --     lcd_control_state <= WRITE_DIGIT;
              --   end if;
              --
              -- when READY2 =>
              --   if (enable_counter = "1111") then
              --     lcd_control_state <= READY1;
              --   end if;

              when WRITE_DIGIT =>
                if (lcd_enable = '0' and previous_enable_state = '1') then
                  case(current_digit) is
                    when CLEAR_DIGIT =>
                      -- if (lcd_enable = '0' and previous_enable_state = '1') then
                        current_digit <= DIGIT1;
                        lcd_ready <= '0';
                      -- end if;
                    when DIGIT1 =>
                      -- if (lcd_enable = '0' and previous_enable_state = '1') then
                        current_digit <= DIGIT2;
                      -- end if;
                    when DIGIT2 =>
                      -- if (lcd_enable = '0' and previous_enable_state = '1') then
                        current_digit <= DIGIT3;
                      -- end if;
                    when DIGIT3 =>
                      -- if (lcd_enable = '0' and previous_enable_state = '1') then
                        current_digit <= DIGIT4;
                      -- end if;
                    when DIGIT4 =>
                      -- if (lcd_enable = '0' and previous_enable_state = '1') then
                        current_digit <= DIGIT5;
                      -- end if;
                    when DIGIT5 =>
                      -- if (lcd_enable = '0' and previous_enable_state = '1') then
                        current_digit <= DIGIT6;
                      -- end if;
                    when DIGIT6 =>
                      -- if (lcd_enable = '0' and previous_enable_state = '1') then
                        current_digit <= DIGIT7;
                      -- end if;
                    when DIGIT7 =>
                      -- if (lcd_enable = '0' and previous_enable_state = '1') then
                        current_digit <= DIGIT8;
                        counter_pause <= '1';
                        lcd_control_state <= WAITING;
                      -- end if;
                    when DIGIT8 =>
                      -- if (lcd_enable = '0' and previous_enable_state = '1') then
                        current_digit <= DIGIT9;
                      -- end if;
                    when DIGIT9 =>
                      -- if (lcd_enable = '0' and previous_enable_state = '1') then
                        current_digit <= DIGIT10;
                      -- end if;
                    when DIGIT10 =>
                      -- if (lcd_enable = '0' and previous_enable_state = '1') then
                        current_digit <= DIGIT11;
                      -- end if;
                    when DIGIT11 =>
                      -- if (lcd_enable = '0' and previous_enable_state = '1') then
                        current_digit <= DIGIT12;
                      -- end if;
                    when DIGIT12 =>
                      -- if (lcd_enable = '0'
                          -- and previous_enable_state = '1' ) then
                          -- and NEW_INPUT = '1') then
                        -- current_digit <= CLEAR_DIGIT;
                        lcd_ready <= '1';
                        -- lcd_control_state <= WAITING;
                      -- end if;
                  end case;
                end if;




                -- if (lcd_enable = '0') then
                --   lcd_control_state <= READY2;
                -- end if;
            when WAITING =>
               -- wait
            end case;

          end if;
      end process;



      -- Process to display data on lcd depending on mode of operation
      DISPLAY_VALUE : process(I_CLK_50MHZ, I_RESET_N, SYS_PAUSE)
        begin
          if (I_RESET_N = '0') then

          elsif (rising_edge(I_CLK_50MHZ)) then
            LCD_EN <= lcd_enable;
            case( lcd_control_state ) is
              when INIT =>
                case( initialization_state ) is
                  when STEP0 =>
                    -- waiting for VCC to rise
                  when STEP1 =>
                    if (lcd_enable = '1') then
                      LCD_RS   <= '0';  -- set RS to 0
                      LCD_RW   <= '0';  -- set RW to 0
                      LCD_DATA <= "00110000";
                    end if;
                  when STEP2 =>
                    if (lcd_enable = '1') then
                      LCD_RS   <= '0';  -- set RS to 0
                      LCD_RW   <= '0';  -- set RW to 0
                      LCD_DATA <= "00110000";
                    end if;
                  when STEP3 =>
                    if (lcd_enable = '1') then
                      LCD_RS   <= '0';  -- set RS to 0
                      LCD_RW   <= '0';  -- set RW to 0
                      LCD_DATA <= "00110000";
                    end if;
                  when STEP4 =>
                    if (lcd_enable = '1') then
                      LCD_RS   <= '0';  -- set RS to 0
                      LCD_RW   <= '0';  -- set RW to 0
                      LCD_DATA <= "00111000";
                    end if;
                  when STEP5 =>
                    if (lcd_enable = '1') then
                      LCD_RS   <= '0';  -- set RS to 0
                      LCD_RW   <= '0';  -- set RW to 0
                      LCD_DATA <= "00001111";
                    end if;
                  when STEP6 =>
                    if (lcd_enable = '1') then
                      LCD_RS   <= '0';  -- set RS to 0
                      LCD_RW   <= '0';  -- set RW to 0
                      LCD_DATA <= "00000001";
                    end if;
                  when STEP7 =>
                    if (lcd_enable = '1') then
                      LCD_INITIALIZED <= '1';
                      LCD_RS   <= '0';  -- set RS to 0
                      LCD_RW   <= '0';  -- set RW to 0
                      LCD_DATA <= "00000110";

                    end if;
                end case;

                when WRITE_DIGIT =>
                  case(current_digit) is
                    when CLEAR_DIGIT =>
                      if (lcd_enable = '1') then
                        -- LCD_RS   <= '0';  -- set RS to 0
                        -- LCD_RW   <= '0';  -- set RW to 0
                        -- LCD_DATA <= "00000001";
                      end if;

                    when DIGIT1 =>
                      if (lcd_enable = '1') then
                        LCD_RS   <= '1';  -- set RS to 0
                        LCD_RW   <= '0';  -- set RW to 0
                        LCD_DATA <= addr_ascii_out(15 downto 8);
                      end if;

                    when DIGIT2 =>
                      if (lcd_enable = '1') then
                        LCD_RS   <= '1';  -- set RS to 0
                        LCD_RW   <= '0';  -- set RW to 0
                        LCD_DATA <= addr_ascii_out(7 downto 0);
                      end if;
                    when DIGIT3 =>
                      if (lcd_enable = '1') then
                        LCD_RS   <= '1';  -- set RS to 0
                        LCD_RW   <= '0';  -- set RW to 0
                        LCD_DATA <= "00100000";

                      end if;
                    when DIGIT4 =>
                      if (lcd_enable = '1') then
                        LCD_RS   <= '1';  -- set RS to 0
                        LCD_RW   <= '0';  -- set RW to 0
                        LCD_DATA <= data_ascii_out(31 downto 24);

                      end if;
                    when DIGIT5 =>
                      if (lcd_enable = '1') then
                        LCD_RS   <= '1';  -- set RS to 0
                        LCD_RW   <= '0';  -- set RW to 0
                        LCD_DATA <= data_ascii_out(23 downto 16);

                      end if;
                    when DIGIT6 =>
                      if (lcd_enable = '1') then
                        LCD_RS   <= '1';  -- set RS to 0
                        LCD_RW   <= '0';  -- set RW to 0
                        LCD_DATA <= data_ascii_out(15 downto 8);

                      end if;
                    when DIGIT7 =>
                      if (lcd_enable = '1') then
                        LCD_RS   <= '1';  -- set RS to 0
                        LCD_RW   <= '0';  -- set RW to 0
                        LCD_DATA <= data_ascii_out(7 downto 0);

                      end if;
                    when DIGIT8 =>
                      if (lcd_enable = '1') then
                        -- LCD_RS   <= '1';  -- set RS to 0
                        -- LCD_RW   <= '0';  -- set RW to 0
                        -- LCD_DATA <= "00100000";

                      end if;
                    when DIGIT9 =>
                      if (lcd_enable = '1') then
                        -- LCD_RS   <= '1';  -- set RS to 0
                        -- LCD_RW   <= '0';  -- set RW to 0
                        -- LCD_DATA <= "00100000";

                      end if;
                    when DIGIT10 =>
                      if (lcd_enable = '1') then
                        -- LCD_RS   <= '1';  -- set RS to 0
                        -- LCD_RW   <= '0';  -- set RW to 0
                        -- LCD_DATA <= "00100000";

                      end if;
                    when DIGIT11 =>
                      if (lcd_enable = '1') then
                        -- LCD_RS   <= '1';  -- set RS to 0
                        -- LCD_RW   <= '0';  -- set RW to 0
                        -- LCD_DATA <= "00100000";

                      end if;
                    when DIGIT12 =>
                      if (lcd_enable = '1'
                          and NEW_INPUT = '1') then
                            -- LCD_RS   <= '1';  -- set RS to 0
                            -- LCD_RW   <= '0';  -- set RW to 0
                            -- LCD_DATA <= "00100000";
                      end if;
                  end case;




                -- if (lcd_enable = '1') then
                --   LCD_RS   <= '1';         -- set RS to 0
                --   LCD_RW   <= '0';         -- set RW to 0
                --   LCD_DATA <= "01000110";  -- write F on current display digit
                -- end if;
              when WAITING =>
                -- wait
            end case;
          end if;
          -- Start at first index of second line
      end process;

      -- INPUT_TO_ASCII : process(I_CLK_50MHZ, I_RESET_N)
      --   begin
      --     if (I_RESET_N = '0') then
      --     elsif (rising_edge(I_CLK_50MHZ)) then
      --       case( INPUT_ADDR(3 downto 0) ) is
      --         when "0000"             => -- '0'
      --           addr_ascii_out(7 downto 0) <= "00110000";
      --         when "0001"             => -- '1'
      --           addr_ascii_out(7 downto 0) <= "00110001";
      --         when "0010"             => -- '2'
      --           addr_ascii_out(7 downto 0) <= "00110010";
      --         when "0011"             => -- '3'
      --           addr_ascii_out(7 downto 0) <= "00110011";
      --         when "0100"             => -- '4'
      --           addr_ascii_out(7 downto 0) <= "00110100";
      --         when "0101"             => -- '5'
      --           addr_ascii_out(7 downto 0) <= "00110101";
      --         when "0110"             => -- '6'
      --           addr_ascii_out(7 downto 0) <= "00110110";
      --         when "0111"             => -- '7'
      --           addr_ascii_out(7 downto 0) <= "00110111";
      --         when "1000"             => -- '8'
      --           addr_ascii_out(7 downto 0) <= "00111000";
      --         when "1001"             => -- '9'
      --           addr_ascii_out(7 downto 0) <= "00111001";
      --         when "1010"             => -- 'A'
      --           addr_ascii_out(7 downto 0) <= "01000001";
      --         when "1011"             => -- 'B'
      --           addr_ascii_out(7 downto 0) <= "01000010";
      --         when "1100"             => -- 'C'
      --           addr_ascii_out(7 downto 0) <= "01000011";
      --         when "1101"             => -- 'D'
      --           addr_ascii_out(7 downto 0) <= "01000100";
      --         when "1110"             => -- 'E'
      --           addr_ascii_out(7 downto 0) <= "01000101";
      --         when "1111"             => -- 'F'
      --           addr_ascii_out(7 downto 0) <= "01000110";
      --       end case;
      --
      --       case( INPUT_ADDR(7 downto 4) ) is
      --         when "0000"             => -- '0'
      --           addr_ascii_out(15 downto 8) <= "00110000";
      --         when "0001"             => -- '1'
      --           addr_ascii_out(15 downto 8) <= "00110001";
      --         when "0010"             => -- '2'
      --           addr_ascii_out(15 downto 8) <= "00110010";
      --         when "0011"             => -- '3'
      --           addr_ascii_out(15 downto 8) <= "00110011";
      --         when "0100"             => -- '4'
      --           addr_ascii_out(15 downto 8) <= "00110100";
      --         when "0101"             => -- '5'
      --           addr_ascii_out(15 downto 8) <= "00110101";
      --         when "0110"             => -- '6'
      --           addr_ascii_out(15 downto 8) <= "00110110";
      --         when "0111"             => -- '7'
      --           addr_ascii_out(15 downto 8) <= "00110111";
      --         when "1000"             => -- '8'
      --           addr_ascii_out(15 downto 8) <= "00111000";
      --         when "1001"             => -- '9'
      --           addr_ascii_out(15 downto 8) <= "00111001";
      --         when "1010"             => -- 'A'
      --           addr_ascii_out(15 downto 8) <= "01000001";
      --         when "1011"             => -- 'B'
      --           addr_ascii_out(15 downto 8) <= "01000010";
      --         when "1100"             => -- 'C'
      --           addr_ascii_out(15 downto 8) <= "01000011";
      --         when "1101"             => -- 'D'
      --           addr_ascii_out(15 downto 8) <= "01000100";
      --         when "1110"             => -- 'E'
      --           addr_ascii_out(15 downto 8) <= "01000101";
      --         when "1111"             => -- 'F'
      --           addr_ascii_out(15 downto 8) <= "01000110";
      --       end case;
      --
      --       case( INPUT_DATA(3 downto 0) ) is
      --         when "0000"             => -- '0'
      --           data_ascii_out(7 downto 0) <= "00110000";
      --         when "0001"             => -- '1'
      --           data_ascii_out(7 downto 0) <= "00110001";
      --         when "0010"             => -- '2'
      --           data_ascii_out(7 downto 0) <= "00110010";
      --         when "0011"             => -- '3'
      --           data_ascii_out(7 downto 0) <= "00110011";
      --         when "0100"             => -- '4'
      --           data_ascii_out(7 downto 0) <= "00110100";
      --         when "0101"             => -- '5'
      --           data_ascii_out(7 downto 0) <= "00110101";
      --         when "0110"             => -- '6'
      --           data_ascii_out(7 downto 0) <= "00110110";
      --         when "0111"             => -- '7'
      --           data_ascii_out(7 downto 0) <= "00110111";
      --         when "1000"             => -- '8'
      --           data_ascii_out(7 downto 0) <= "00111000";
      --         when "1001"             => -- '9'
      --           data_ascii_out(7 downto 0) <= "00111001";
      --         when "1010"             => -- 'A'
      --           data_ascii_out(7 downto 0) <= "01000001";
      --         when "1011"             => -- 'B'
      --           data_ascii_out(7 downto 0) <= "01000010";
      --         when "1100"             => -- 'C'
      --           data_ascii_out(7 downto 0) <= "01000011";
      --         when "1101"             => -- 'D'
      --           data_ascii_out(7 downto 0) <= "01000100";
      --         when "1110"             => -- 'E'
      --           data_ascii_out(7 downto 0) <= "01000101";
      --         when "1111"             => -- 'F'
      --           data_ascii_out(7 downto 0) <= "01000110";
      --       end case;
      --
      --       case( INPUT_DATA(7 downto 4) ) is
      --         when "0000"             => -- '0'
      --           data_ascii_out(15 downto 8) <= "00110000";
      --         when "0001"             => -- '1'
      --           data_ascii_out(15 downto 8) <= "00110001";
      --         when "0010"             => -- '2'
      --           data_ascii_out(15 downto 8) <= "00110010";
      --         when "0011"             => -- '3'
      --           data_ascii_out(15 downto 8) <= "00110011";
      --         when "0100"             => -- '4'
      --           data_ascii_out(15 downto 8) <= "00110100";
      --         when "0101"             => -- '5'
      --           data_ascii_out(15 downto 8) <= "00110101";
      --         when "0110"             => -- '6'
      --           data_ascii_out(15 downto 8) <= "00110110";
      --         when "0111"             => -- '7'
      --           data_ascii_out(15 downto 8) <= "00110111";
      --         when "1000"             => -- '8'
      --           data_ascii_out(15 downto 8) <= "00111000";
      --         when "1001"             => -- '9'
      --           data_ascii_out(15 downto 8) <= "00111001";
      --         when "1010"             => -- 'A'
      --           data_ascii_out(15 downto 8) <= "01000001";
      --         when "1011"             => -- 'B'
      --           data_ascii_out(15 downto 8) <= "01000010";
      --         when "1100"             => -- 'C'
      --           data_ascii_out(15 downto 8) <= "01000011";
      --         when "1101"             => -- 'D'
      --           data_ascii_out(15 downto 8) <= "01000100";
      --         when "1110"             => -- 'E'
      --           data_ascii_out(15 downto 8) <= "01000101";
      --         when "1111"             => -- 'F'
      --           data_ascii_out(15 downto 8) <= "01000110";
      --       end case;
      --
      --       case( INPUT_DATA(11 downto 8) ) is
      --         when "0000"             => -- '0'
      --           data_ascii_out(23 downto 16) <= "00110000";
      --         when "0001"             => -- '1'
      --           data_ascii_out(23 downto 16) <= "00110001";
      --         when "0010"             => -- '2'
      --           data_ascii_out(23 downto 16) <= "00110010";
      --         when "0011"             => -- '3'
      --           data_ascii_out(23 downto 16) <= "00110011";
      --         when "0100"             => -- '4'
      --           data_ascii_out(23 downto 16) <= "00110100";
      --         when "0101"             => -- '5'
      --           data_ascii_out(23 downto 16) <= "00110101";
      --         when "0110"             => -- '6'
      --           data_ascii_out(23 downto 16) <= "00110110";
      --         when "0111"             => -- '7'
      --           data_ascii_out(23 downto 16) <= "00110111";
      --         when "1000"             => -- '8'
      --           data_ascii_out(23 downto 16) <= "00111000";
      --         when "1001"             => -- '9'
      --           data_ascii_out(23 downto 16) <= "00111001";
      --         when "1010"             => -- 'A'
      --           data_ascii_out(23 downto 16) <= "01000001";
      --         when "1011"             => -- 'B'
      --           data_ascii_out(23 downto 16) <= "01000010";
      --         when "1100"             => -- 'C'
      --           data_ascii_out(23 downto 16) <= "01000011";
      --         when "1101"             => -- 'D'
      --           data_ascii_out(23 downto 16) <= "01000100";
      --         when "1110"             => -- 'E'
      --           data_ascii_out(23 downto 16) <= "01000101";
      --         when "1111"             => -- 'F'
      --           data_ascii_out(23 downto 16) <= "01000110";
      --       end case;
      --
      --       case( INPUT_DATA(15 downto 12) ) is
      --         when "0000"             => -- '0'
      --           data_ascii_out(31 downto 24) <= "00110000";
      --         when "0001"             => -- '1'
      --           data_ascii_out(31 downto 24) <= "00110001";
      --         when "0010"             => -- '2'
      --           data_ascii_out(31 downto 24) <= "00110010";
      --         when "0011"             => -- '3'
      --           data_ascii_out(31 downto 24) <= "00110011";
      --         when "0100"             => -- '4'
      --           data_ascii_out(31 downto 24) <= "00110100";
      --         when "0101"             => -- '5'
      --           data_ascii_out(31 downto 24) <= "00110101";
      --         when "0110"             => -- '6'
      --           data_ascii_out(31 downto 24) <= "00110110";
      --         when "0111"             => -- '7'
      --           data_ascii_out(31 downto 24) <= "00110111";
      --         when "1000"             => -- '8'
      --           data_ascii_out(31 downto 24) <= "00111000";
      --         when "1001"             => -- '9'
      --           data_ascii_out(31 downto 24) <= "00111001";
      --         when "1010"             => -- 'A'
      --           data_ascii_out(31 downto 24) <= "01000001";
      --         when "1011"             => -- 'B'
      --           data_ascii_out(31 downto 24) <= "01000010";
      --         when "1100"             => -- 'C'
      --           data_ascii_out(31 downto 24) <= "01000011";
      --         when "1101"             => -- 'D'
      --           data_ascii_out(31 downto 24) <= "01000100";
      --         when "1110"             => -- 'E'
      --           data_ascii_out(31 downto 24) <= "01000101";
      --         when "1111"             => -- 'F'
      --           data_ascii_out(31 downto 24) <= "01000110";
      --       end case;
      --     end if;
      -- end process INPUT_TO_ASCII;

      LCD_ON   <= '1';
      LCD_BLON <= '1';
      READY    <= lcd_ready;

end rtl;
