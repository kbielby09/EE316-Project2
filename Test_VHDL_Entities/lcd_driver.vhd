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

        -- Data
        INPUT_DATA : in std_logic_vector(7 downto 0);
        NEW_DATA   : in std_logic;

        -- Control Inputs
        READY       : out std_logic := '0';

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

    -- Signals for LCD display state machine
    type LCD_STATE is (
        INIT0,
        INIT1,
        INIT2,
        INIT3,
        INIT4,
        INIT5,
        INIT6,
        INIT7,
        READY1,
        WRITE_LCD,
        WAITING
    );

    signal lcd_control_state : LCD_STATE := INIT0;

    -- Signals for user output
    signal enable_counter        : unsigned(3 downto 0);
    signal lcd_enable            : std_logic;
    signal previous_enable_value : std_logic;

    signal counter_paused : std_logic := '0';

    signal sixteen_ms_count         : unsigned(19 downto 0);
    signal sixteen_ms_elapse        : std_logic := '0';
    signal five_ms_elapse           : std_logic := '0';
    signal one_hundred_micro_elapse : std_logic := '0';
    signal first_three              : std_logic := '0';
    signal forty_four_micro_elapse  : std_logic := '0';

    signal lcd_initialized          : std_logic := '0';

    -- TODO remove after testing
    signal temp_new_data            : std_logic := '1';
    signal step_six  : std_logic := '0';

    begin

      -- Process to count for approximately 230ns
      EN_COUNTER : process(I_CLK_50MHZ, I_RESET_N)
          begin
            if (I_RESET_N = '0') then
              enable_counter <= (others => '0');
              lcd_enable <= '0';
              previous_enable_value <= '0';
            elsif (rising_edge(I_CLK_50MHZ)) then
              previous_enable_value <= lcd_enable;
              if (counter_paused = '0') then
                enable_counter <= enable_counter + 1;
                lcd_enable <= '1';
                -- Check for 230ns of elapsed time
                if (enable_counter = "1100") then
                  lcd_enable <= '0';
                end if;
              elsif (counter_paused = '1') then
                lcd_enable <= '0';
                previous_enable_value <= '0';
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
            if (lcd_initialized = '0') then
              sixteen_ms_count        <= sixteen_ms_count + 1;
              forty_four_micro_elapse <= '0';

              if (sixteen_ms_count = "11000011010100000000"
                  and lcd_control_state = INIT0) then
                sixteen_ms_elapse <= '1';
                sixteen_ms_count <= (others => '0');

              elsif (sixteen_ms_count = "111101000010010000"
                     and lcd_control_state = INIT1) then
                five_ms_elapse <= '1';
                sixteen_ms_count <= (others => '0');

              elsif (sixteen_ms_count = "1001110111010"
                     and lcd_control_state = INIT2) then
                  one_hundred_micro_elapse <= '1';
                  sixteen_ms_count <= (others => '0');

              elsif (sixteen_ms_count = "100010011000"
                     and (lcd_control_state = INIT3
                          or lcd_control_state = INIT4
                          or lcd_control_state = INIT5
                          or lcd_control_state = INIT6
                          or lcd_control_state = INIT7)) then
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
            lcd_control_state <= INIT0;
            lcd_initialized   <= '0';
          elsif (rising_edge(I_CLK_50MHZ)) then
            case( lcd_control_state ) is
              when INIT0 =>
                if (sixteen_ms_elapse = '1') then
                  lcd_control_state <= INIT1;
                end if;

              when INIT1 =>
                if (five_ms_elapse = '1') then
                  lcd_control_state <= INIT2;
                end if;

              when INIT2 =>
                if (one_hundred_micro_elapse = '1') then
                  lcd_control_state <= INIT3;
                end if;

              when INIT3 =>
                if (forty_four_micro_elapse = '1') then
                  lcd_control_state <= INIT4;
                end if;

              when INIT4 =>
                if (forty_four_micro_elapse = '1') then
                  lcd_control_state <= INIT5;
                end if;

              when INIT5 =>
                if (forty_four_micro_elapse = '1') then
                  lcd_control_state <= INIT6;
                end if;

              when INIT6 =>
                if (forty_four_micro_elapse = '1') then
                  lcd_control_state <= INIT7;
                end if;

              when INIT7 =>
                if (forty_four_micro_elapse = '1') then
                  lcd_control_state <= READY1;
                  lcd_initialized   <= '1';
                end if;

             when READY1 =>
                if (lcd_enable = '1' and previous_enable_value = '0') then
                  lcd_control_state <= WRITE_LCD;
                end if;

            when WRITE_LCD =>
              if (lcd_enable = '0' and previous_enable_value = '1') then
                lcd_control_state <= WAITING;
              end if;

            when WAITING =>
              if (NEW_DATA = '1'
              -- if (temp_new_data  = '1'
                  and lcd_enable = '0'
                  and previous_enable_value = '0'
                  and enable_counter = "1111") then
                lcd_control_state <= READY1;
              end if;
            end case;
          end if;
      end process;

      -- Process to display data on lcd depending on mode of operation
      DISPLAY_VALUE : process(I_CLK_50MHZ, I_RESET_N)
        begin
          if (I_RESET_N = '0') then

          elsif (rising_edge(I_CLK_50MHZ)) then
            LCD_EN <= lcd_enable;
            case( lcd_control_state ) is
              when INIT0 =>
                    -- waiting for VCC to rise
                  when INIT1 =>
                      LCD_RS   <= '0';  -- set RS to 0
                      LCD_RW   <= '0';  -- set RW to 0
                      LCD_DATA <= "00110000";

                  when INIT2 =>
                      LCD_RS   <= '0';  -- set RS to 0
                      LCD_RW   <= '0';  -- set RW to 0
                      LCD_DATA <= "00110000";

                  when INIT3 =>
                      LCD_RS   <= '0';  -- set RS to 0
                      LCD_RW   <= '0';  -- set RW to 0
                      LCD_DATA <= "00110000";

                  when INIT4 =>
                      LCD_RS   <= '0';  -- set RS to 0
                      LCD_RW   <= '0';  -- set RW to 0
                      LCD_DATA <= "00111000";

                  when INIT5 =>
                      LCD_RS   <= '0';  -- set RS to 0
                      LCD_RW   <= '0';  -- set RW to 0
                      LCD_DATA <= "00001111";

                  when INIT6 =>
                      LCD_RS   <= '0';  -- set RS to 0
                      LCD_RW   <= '0';  -- set RW to 0
                      LCD_DATA <= "00000001";

                  when INIT7 =>
                      LCD_RS   <= '0';  -- set RS to 0
                      LCD_RW   <= '0';  -- set RW to 0
                      LCD_DATA <= "00000110";

              when READY1 =>
                READY          <= '1';
                LCD_RS         <= '1';         -- set RS to 0
                LCD_RW         <= '0';         -- set RW to 0
                counter_paused <= '0';

              when WRITE_LCD =>
                if (lcd_enable = '1') then
                  LCD_DATA <= "01000110";
                end if;

             when WAITING =>
               temp_new_data <= '0';
               counter_paused <= '1';

            end case;
          end if;
      end process;

      LCD_ON   <= '1';
      LCD_BLON <= '1';

end rtl;
