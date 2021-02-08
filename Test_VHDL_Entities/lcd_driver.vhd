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

        -- Control Inputs
        SYS_PAUSE    : in std_logic;
        PWM_GEN_MODE : in std_logic;

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
        INIT,
        CLEAR,
        RETURN_HM,
        ENTRY
    );

    signal lcd_control_state : LCD_STATE;

    -- Signals for user output
    signal enable_counter    : unsigned(3 downto 0);
    signal lcd_enable        : std_logic;
    -- signal lcd_display_out   : std_logic_vector( downto 0);
    signal addr_ascii_out    : std_logic_vector(15 downto 0);

    begin

      -- TODO move to separate entity
      -- Process to count for approximately 230ns
      EN_COUNTER : process(I_CLK_50MHZ, I_RESET_N)
          begin
            if (I_RESET_N = '0') then
              enable_counter <= (others => '0');
            elsif (rising_edge(I_CLK_50MHZ)) then
              enable_counter = enable_counter + 1;
              lcd_enable <= '1';
              -- Check for 230ns of elapsed time
              if (enable_counter = "1100") then
                lcd_enable <= '0';
                enable_counter <= (others => '0');
              end if;
            end if;
      end process EN_COUNTER;

      -- Process to change the state of the LCD
      DISPLAY_STATE : process(I_CLK_50MHZ, I_RESET_N, SYS_PAUSE, PWM_GEN_MODE)
        begin
          if (I_RESET_N = '0') then
            lcd_control_state <= INIT;
          elsif (rising_edge(I_CLK_50MHZ)) then
            if (SYS_PAUSE = '0') then

            else

            end if;
          end if;
      end process;

      -- Process to display data on lcd depending on mode of operation
      DISPLAY_VALUE : process(I_CLK_50MHZ, I_RESET_N)
        begin

      end process;

      INPUT_TO_ASCII : process(I_CLK_50MHZ, I_RESET_N)
        begin
          if (I_RESET_N) then
          elsif (rising_edge(I_CLK_50MHZ)) then
            case( INPUT_ADDR(3 downto 0) ) is
              when "0000"             => -- '0'
                addr_ascii_out(7 downto 0) <= "110000";
              when "0001"             => -- '1'
                addr_ascii_out(7 downto 0) <= "110001";
              when "0010"             => -- '2'
                addr_ascii_out(7 downto 0) <= "110010";
              when "0011"             => -- '3'
                addr_ascii_out(7 downto 0) <= "110011";
              when "0100"             => -- '4'
                addr_ascii_out(7 downto 0) <= "110100";
              when "0101"             => -- '5'
                addr_ascii_out(7 downto 0) <= "110101";
              when "0110"             => -- '6'
                addr_ascii_out(7 downto 0) <= "110110";
              when "0111"             => -- '7'
                addr_ascii_out(7 downto 0) <= "110111";
              when "1000"             => -- '8'
                addr_ascii_out(7 downto 0) <= "111000";
              when "1001"             => -- '9'
                addr_ascii_out(7 downto 0) <= "111001";
              when "1010"             => -- 'A'
                addr_ascii_out(7 downto 0) <= "1000001";
              when "1011"             => -- 'B'
                addr_ascii_out(7 downto 0) <= "1000010";
              when "1100"             => -- 'C'
                addr_ascii_out(7 downto 0) <= "1000011";
              when "1101"             => -- 'D'
                addr_ascii_out(7 downto 0) <= "1000100";
              when "1110"             => -- 'E'
                addr_ascii_out(7 downto 0) <= "1000101";
              when "1111"             => -- 'F'
                addr_ascii_out(7 downto 0) <= "1000110";
            end case;

            case( INPUT_ADDR(7 downto 4) ) is
              when "0000"             => -- '0'
                addr_ascii_out(15 downto 8) <= "110000";
              when "0001"             => -- '1'
                addr_ascii_out(15 downto 8) <= "110001";
              when "0010"             => -- '2'
                addr_ascii_out(15 downto 8) <= "110010";
              when "0011"             => -- '3'
                addr_ascii_out(15 downto 8) <= "110011";
              when "0100"             => -- '4'
                addr_ascii_out(15 downto 8) <= "110100";
              when "0101"             => -- '5'
                addr_ascii_out(15 downto 8) <= "110101";
              when "0110"             => -- '6'
                addr_ascii_out(15 downto 8) <= "110110";
              when "0111"             => -- '7'
                addr_ascii_out(15 downto 8) <= "110111";
              when "1000"             => -- '8'
                addr_ascii_out(15 downto 8) <= "111000";
              when "1001"             => -- '9'
                addr_ascii_out(15 downto 8) <= "111001";
              when "1010"             => -- 'A'
                addr_ascii_out(15 downto 8) <= "1000001";
              when "1011"             => -- 'B'
                addr_ascii_out(15 downto 8) <= "1000010";
              when "1100"             => -- 'C'
                addr_ascii_out(15 downto 8) <= "1000011";
              when "1101"             => -- 'D'
                addr_ascii_out(15 downto 8) <= "1000100";
              when "1110"             => -- 'E'
                addr_ascii_out(15 downto 8) <= "1000101";
              when "1111"             => -- 'F'
                addr_ascii_out(15 downto 8) <= "1000110";
            end case;
          end if;
      end process INPUT_TO_ASCII;

end rtl;
